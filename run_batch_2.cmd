@echo off
setlocal
cd /d "%~dp0"
set "BROWSER=%~1"
if "%BROWSER%"=="" set "BROWSER=chrome"
py -m robot --outputdir results_batch2 --variable BROWSER:%BROWSER% 017_drop_activity_permanently.robot 018_create_empty_free_exploration_path_offline.robot 018_create_empty_free_exploration_path.robot 019_create_empty_auto_triggered_path_offline.robot 019_create_empty_auto_triggered_path.robot 020_create_empty_guided_path_offline.robot 020_create_empty_guided_path.robot 021_add_activity_to_path_offline.robot 021_add_activity_to_path.robot 022_sign_up.robot 023_sign_in.robot 024_synchronize_activity.robot 025_generate_text_augmentation.robot 026_generate_image_augmentation.robot 027_generate_audio_augmentation.robot 028_load.robot 029_tag.robot 030_text_updates_augmentation_offline.robot 030_text_updates_augmentation.robot 031_import.robot 032_load_import.robot 033_filter_basic.robot 034_duplicate.robot 035_search_and_find_success.robot 036_search_and_find_fail.robot 037_pairs.robot 038_layers.robot 039_layers_layering.robot 040_verify_language_changes.robot 041_audio_tool.robot 042_restore_path.robot 043_update_propagation_on_import.robot 044_verify_language_change_offline.robot
pause
