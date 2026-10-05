"""Classify every MIXAP test case for Safari compatibility.

Walks each NNN_*.robot suite with robot.api, recursing into the keywords of
ressources.robot and the suite's own *** Keywords *** (including keywords
passed as arguments to runners like "Wait Until Keyword Succeeds"), and
simulates the browser session across the tests of a suite, since tests in one
file share one browser and later tests inherit the network state (offline /
throttled) set by earlier ones.

Usage (from the repo root):
    python tools/safari_compatibility.py            # print summary counts
    python tools/safari_compatibility.py --markdown SAFARI_COMPATIBILITY.md
    python tools/safari_compatibility.py --check    # verify tags in the .robot files match

The per-test result drives the tags used by the suite:
    chrome-only            test is skipped on Safari (see "safari-skip:<reason>")
    safari-skip:<reason>   why - one of SKIP_REASONS below
    safari-unverified      runs on Safari but has not been executed on Safari yet
"""

import argparse
import glob
import json
import re
import sys
from collections import Counter, defaultdict

from robot.api import TestSuiteBuilder
from robot.running import ResourceFileBuilder
from robot.utils import normalize


def N(name):
    return normalize(name, ignore='_')


SKIP_REASONS = {
    'cdp-network': 'uses Chrome DevTools Protocol network emulation (Go Offline / Set Network Speed)',
    'cdp-state': 'continues a browser session that an earlier test took offline or throttled via CDP',
    'offline-suite': 'suite exercises offline behaviour, which needs CDP network emulation',
    'concurrent-browsers': 'needs two concurrent browser sessions; safaridriver allows only one',
    'microphone': 'records from the microphone; Safari has no fake microphone',
    'camera-todo': 'needs a camera snap; the Safari upload sequence for this activity type is not yet determined',
    'camera-detection': 'asserts marker detection, which needs a live camera feed',
    'onboarding-camera': 'onboarding tour steps target the camera capture controls',
    'session-of-skipped': 'continues the browser session of a test that is skipped on Safari',
}

SKIP_GUARD = 'Skip Chrome-Only Test On Safari'

CDP = {N(x) for x in ['Go Offline', 'Go Online', 'Set Network Speed', 'Reset Network Speed']}
OPEN = {N(x) for x in ['Open Web Application', 'Open Web Application with alias',
                       'Open Web Application without closing', 'Open Web Application Without Fake Media']}
CLOSE = {N(x) for x in ['Close Browser', 'Close All Browsers']}
CAMERA = {N('Snap the background'), N('Provide Marker Image')}
UPLOAD = {N('Choose File'), N('Choose File Robust')}
DRAG = {N('Drag And Drop'), N('Mouse Down')}
# Keywords whose own bodies are treated as opaque: their browser branches would
# otherwise make every caller look like it uploads a file / closes the browser.
OPAQUE = CAMERA | UPLOAD | OPEN | {N('Open MIXAP Browser')}
TYPE_HELPERS = {
    N('Create empty augmented activity'): 'Augmented activity',
    N('Create empty validation'): 'Search and Find',
    N('Create basic search and find activity'): 'Search and Find',
    N('Create failed search and find activity'): 'Search and Find',
    N('Create basic layers activity'): 'Information layers',
    N('Create basic layers activity without validation'): 'Information layers',
    N('Create basic pairs activity'): 'Pair Association',
}
# Activity types whose marker-upload sequence is evidenced in this repo
# (051_empty_animated_augment.robot and "Create failed search and find activity").
FALLBACK_TYPES = {'Augmented activity', 'Search and Find'}

# Suite-level decisions that the keyword walk cannot infer on its own.
SUITE_OVERRIDES = {
    '035_search_and_find_success.robot': 'camera-detection',
    '070_onboarding_teacher.robot': 'onboarding-camera',
    '073_onboarding_search_and_find.robot': 'onboarding-camera',
}
OFFLINE_SUITE = re.compile(r'(_offline|^0(4[4-8]|5[4-9]|6[0-5])_)')


def _arg_value(arg):
    arg = str(arg)
    return arg.split('=', 1)[1] if arg.startswith('activity_type=') else arg


def _walk(body, kwmap, feats, stack, ctx):
    for item in body:
        if getattr(item, 'type', '') != 'KEYWORD':
            if getattr(item, 'body', None) is not None:
                _walk(item.body, kwmap, feats, stack, ctx)
            continue
        name = item.name or ''
        n = N(name)
        args = [str(a) for a in item.args]
        caller = stack[-1] if stack else '(test body)'
        if n in OPEN:
            feats['events'].append('open')
        if n in CLOSE:
            feats['events'].append('close')
        if n in CDP:
            feats['cdp'].add(name)
            feats['events'].append('cdp')
        if n in (N('Switch Browser'), N('Open Web Application with alias')):
            feats['concurrent'] = True
        if n == N('Select Activity Type') and args:
            ctx['type'] = _arg_value(args[0])
        if n in TYPE_HELPERS:
            ctx['type'] = TYPE_HELPERS[n]
        if n == N('Provide Marker Image') and args:
            ctx['type'] = _arg_value(args[0])
        if n in CAMERA:
            feats['camera'].add(ctx.get('type') or '?')
        elif any("text()='Snap'" in a for a in args):
            feats['camera'].add((ctx.get('type') or '?') + ' (inline snap)')
        if n in UPLOAD:
            feats['upload'].add(caller)
        if n in DRAG:
            feats['drag'].add(caller)
        if any('CircleIcon' in a for a in args):
            feats['mic'] = True
        if n in OPAQUE:
            continue
        for target in [n] + [N(a) for a in args]:
            kw = kwmap.get(target)
            if kw is not None and target not in [N(s) for s in stack]:
                _walk(kw.body, kwmap, feats, stack + [kw.name], ctx)


def classify(root='.'):
    resource = ResourceFileBuilder().build(f'{root}/ressources.robot')
    shared = {N(k.name): k for k in resource.keywords}
    rows = []
    for path in sorted(glob.glob(f'{root}/[0-9][0-9][0-9]_*.robot')):
        fname = path.replace('\\', '/').split('/')[-1]
        suite = TestSuiteBuilder().build(path)
        kwmap = dict(shared)
        kwmap.update({N(k.name): k for k in suite.resource.keywords})
        ctx, tests = {}, []
        for test in suite.tests:
            feats = dict(events=[], cdp=set(), concurrent=False, camera=set(),
                         upload=set(), drag=set(), mic=False)
            _walk(test.body, kwmap, feats, [], ctx)
            tests.append((test, feats))
        concurrent = any(f['concurrent'] for _, f in tests)
        cdp_state, skipped_opener = False, None
        suite_rows = []
        for test, feats in tests:
            inherits = not feats['events'] or feats['events'][0] != 'open'
            depends = inherits and cdp_state
            reasons = []
            if concurrent:
                reasons.append('concurrent-browsers')
            if feats['cdp']:
                reasons.append('cdp-network')
            elif depends:
                reasons.append('cdp-state')
            if feats['mic']:
                reasons.append('microphone')
            if any(c not in FALLBACK_TYPES for c in feats['camera']):
                reasons.append('camera-todo')
            if not reasons and inherits and skipped_opener:
                reasons.append('session-of-skipped')
            suite_rows.append(dict(
                file=fname, test=test.name, cdp=sorted(feats['cdp']), depends_on_cdp=depends,
                camera=sorted(feats['camera']), upload=sorted(feats['upload']),
                drag=sorted(feats['drag']), concurrent=concurrent, reasons=reasons))
            for event in feats['events']:
                if event in ('open', 'close'):
                    cdp_state, skipped_opener = False, None
                else:
                    cdp_state = True
            if reasons and not (feats['events'] and feats['events'][-1] == 'close'):
                skipped_opener = skipped_opener or test.name
        whole = SUITE_OVERRIDES.get(fname) or ('offline-suite' if OFFLINE_SUITE.search(fname) else None)
        for row in suite_rows:
            if whole:
                row['reasons'] = (['concurrent-browsers'] if concurrent else []) + [whole]
            row['status'] = ('SKIP' if row['reasons'] else
                             'RUN-WITH-FALLBACK' if (row['camera'] or row['upload'] or row['drag']) else 'RUN')
        rows.extend(suite_rows)
    return rows


def expected_tags(rows):
    """Return {file: (suite_tags, {test: test_tags})} as applied in the .robot files."""
    by_file = defaultdict(list)
    for row in rows:
        by_file[row['file']].append(row)
    result = {}
    for fname, frows in by_file.items():
        if all(r['status'] == 'SKIP' for r in frows):
            common = set(frows[0]['reasons']).intersection(*(r['reasons'] for r in frows))
            if common:
                suite_reasons = [f'safari-skip:{x}' for x in frows[0]['reasons'] if x in common]
                rest = {r['test']: [f'safari-skip:{x}' for x in r['reasons'] if x not in common] for r in frows}
                result[fname] = (['chrome-only'] + suite_reasons, rest)
            else:
                result[fname] = (['chrome-only'], {r['test']: [f'safari-skip:{x}' for x in r['reasons']] for r in frows})
        elif all(r['status'] != 'SKIP' for r in frows):
            result[fname] = (['safari-unverified'], {r['test']: [] for r in frows})
        else:
            result[fname] = ([], {r['test']: (['chrome-only'] + [f'safari-skip:{x}' for x in r['reasons']]
                                              if r['status'] == 'SKIP' else ['safari-unverified']) for r in frows})
    return result


def check(rows, root='.'):
    problems = []
    for fname, (suite_tags, tests) in expected_tags(rows).items():
        suite = TestSuiteBuilder().build(f'{root}/{fname}')
        for test in suite.tests:
            want = set(suite_tags) | set(tests[test.name])
            if set(test.tags) != want:
                problems.append(f'{fname} :: {test.name}: has {sorted(test.tags)}, expected {sorted(want)}')
            if 'chrome-only' in want and N(test.setup.name or '') != N(SKIP_GUARD):
                problems.append(f'{fname} :: {test.name}: missing "Test Setup    {SKIP_GUARD}"')
    return problems


def markdown(rows):
    counts = Counter(r['status'] for r in rows)
    unverified = sum(r['status'] != 'SKIP' for r in rows)
    reasons = Counter(x for r in rows for x in r['reasons'])
    by_file = defaultdict(Counter)
    for r in rows:
        by_file[r['file']][r['status']] += 1
    yes = lambda b: 'yes' if b else ''
    out = [
        '<!-- Generated by tools/safari_compatibility.py - regenerate instead of editing the table by hand. -->',
        '',
        '## Summary',
        '',
        f'{len(rows)} test cases in {len(by_file)} suite files.',
        '',
        '| Safari status | Tests |',
        '|---|---|',
        f"| RUN | {counts['RUN']} |",
        f"| RUN-WITH-FALLBACK | {counts['RUN-WITH-FALLBACK']} |",
        f"| SKIP (`chrome-only`) | {counts['SKIP']} |",
        f'| `safari-unverified` (every non-SKIP test) | {unverified} |',
        '',
        '### Skip reasons',
        '',
        'A skipped test can carry more than one reason.',
        '',
        '| Tag | Tests | Reason |',
        '|---|---|---|',
    ]
    for key, text in SKIP_REASONS.items():
        out.append(f'| `safari-skip:{key}` | {reasons[key]} | {text} |')
    out += ['', '### Per suite', '', '| File | RUN | RUN-WITH-FALLBACK | SKIP |', '|---|---|---|---|']
    for fname, c in by_file.items():
        out.append(f"| {fname} | {c['RUN']} | {c['RUN-WITH-FALLBACK']} | {c['SKIP']} |")
    out += ['', '## Per test', '',
            '| File | Test | Uses CDP | Depends on CDP state | Camera snap | File upload | Drag and drop '
            '| Two browsers | Safari status | Reason |',
            '|---|---|---|---|---|---|---|---|---|---|']
    for r in rows:
        reason = '; '.join(SKIP_REASONS[x] for x in r['reasons'])
        out.append(' | '.join([
            f"| {r['file']}", r['test'].replace('|', '\\|'), ', '.join(r['cdp']), yes(r['depends_on_cdp']),
            ', '.join(r['camera']), ', '.join(r['upload']), ', '.join(r['drag']), yes(r['concurrent']),
            r['status'], reason]) + ' |')
    return '\n'.join(out) + '\n'


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('--markdown', metavar='FILE', help='replace the generated part of FILE (after the marker line)')
    parser.add_argument('--json', action='store_true', help='print the raw classification as JSON')
    parser.add_argument('--check', action='store_true', help='verify the tags in the .robot files')
    args = parser.parse_args()
    rows = classify()
    if args.json:
        print(json.dumps(rows, ensure_ascii=False, indent=1))
        return 0
    if args.markdown:
        marker = '<!-- BEGIN GENERATED -->'
        try:
            with open(args.markdown, encoding='utf-8') as f:
                head = f.read().split(marker)[0]
        except FileNotFoundError:
            head = ''
        with open(args.markdown, 'w', encoding='utf-8', newline='\n') as f:
            f.write(head + marker + '\n' + markdown(rows))
    if args.check:
        problems = check(rows)
        for p in problems:
            print(p)
        print(f'{len(problems)} tag mismatch(es)')
        return 1 if problems else 0
    counts = Counter(r['status'] for r in rows)
    print(f"{len(rows)} tests: " + ', '.join(f'{k}={v}' for k, v in sorted(counts.items())))
    return 0


if __name__ == '__main__':
    sys.exit(main())
