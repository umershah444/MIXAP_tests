#!/usr/bin/env bash
# Run the suite on Safari (macOS only), one test file after another.
#
# Safari allows only ONE WebDriver session per machine, so unlike the Chrome
# batch runners (run_batch_*.cmd / run_all_batches.cmd) this never runs
# batches in parallel - a single robot invocation executes the suites
# sequentially.
#
# Tests that cannot run on Safari are tagged "chrome-only" and are excluded
# here; see SAFARI_COMPATIBILITY.md for the reason behind each one.
#
# One-time setup (see README.md, "Running on Chrome vs Safari"):
#   sudo safaridriver --enable
#   Safari > Settings > Advanced > "Show features for web developers", then
#   Develop > Allow Remote Automation
#
# Usage (from anywhere - it always runs from the repo root, since the tests
# reference assets as ${EXECDIR}/assets/...):
#   ./run_safari.sh                              # every NNN_*.robot file
#   ./run_safari.sh 001_open_app.robot 014_home_interface_checking.robot
#
# Results go to results_safari/.

set -u

if [ "$(uname)" != "Darwin" ]; then
    echo "run_safari.sh: Safari WebDriver only runs on macOS." >&2
    exit 1
fi

cd "$(dirname "$0")"

if [ "$#" -eq 0 ]; then
    set -- [0-9][0-9][0-9]_*.robot
fi

python3 -m robot \
    --outputdir results_safari \
    --variable BROWSER:safari \
    --exclude chrome-only \
    --exclude skip \
    "$@"
