# step 0: filter flows
$source_file_name = "language_heritage_pipeline"
$input_path = ".\flows\yiddish-language-chatbot.json"


# step 1: update flow properties
$source_file_name = $source_file_name + "_expire"
$output_path_1 =  ".\temp\" + $source_file_name + ".json"
$default_expiration_time = 60
$expiration_times =  ".\edits\expiration_times.json"
node ..\parenttext-deployment\idems-chatbot-repo\scripts\update_expiration_time.js $input_path $expiration_times $default_expiration_time $output_path_1
Write-Output "Updated expiration"
<#

#step 4T: add translation 

$languages =  $languages
$2languages = $2languages
$deployment_ = $deployment_
$transl_output_folder = ".\parenttext-" + $deployment + "-repo\temp"

$input_path_T = $output_path_2
for ($i=0; $i -lt $languages.length; $i++) {
	$lang = $languages[$i]
    $2lang = $2languages[$i]

    #step T: get PO files from translation repo and merge them into a single json
    $transl_repo = "..\PLH-Digital-Content\translations\parent_text\" + $2lang+ "\"
    $intern_transl = $transl_repo +  $2lang + "_messages.po"
    $local_transl = $transl_repo +  $2lang+ "_" + $deployment_ + "_additional_messages.po"

    $json_intern_transl = ".\parenttext-"+ $deployment +"-repo\temp\temp_transl\"+ $lang+ "\"  +$2lang + "_messages.json"
    node ..\idems_translation\common_tools\index.js convert $intern_transl $json_intern_transl

    $json_local_transl = ".\parenttext-"+ $deployment +"-repo\temp\temp_transl\"+ $lang+ "\" +$2lang+ "_" + $deployment +"_additional_messages.json"
    node ..\idems_translation\common_tools\index.js convert $local_transl $json_local_transl

    $json_translation_file_path = ".\parenttext-"+ $deployment +"-repo\temp\temp_transl\"+ $lang+ "\" + $2lang+ "_all_messages.json"
    node ..\idems_translation\common_tools\concatenate_json_files.js $json_local_transl $json_intern_transl $json_translation_file_path 


    $source_file_name = $source_file_name + "_" + $lang
    
    node ..\idems_translation\chatbot\index.js localize $input_path_T $json_translation_file_path $lang $source_file_name $transl_output_folder
   
    $input_path_T = $transl_output_folder + "\" + $source_file_name +".json"
    Write-Output ("Created localization for " + $lang)
}


# step 4QA: integrity check

$InputFile = $transl_output_folder + "\" +  $source_file_name +".json"
$OutputDir = ".\parenttext-"+ $deployment +"-repo\temp\temp_transl"
$JSON9 = "9_has_any_words_check"
$JSON9Path = $OutputDir + '\' + $JSON9 + '.json'
$LOG10 = "10 - Log of changes after has_any_words_check"
$JSON11 = "11_fix_arg_qr_translation"
$JSON11Path = $OutputDir + '\' + $JSON11 + '.json'
$LOG12 = "12 - Log of changes after fix_arg_qr_translation"
$LOG13 = "13 - Log of erros in file found using overall_integrity_check"
$LOG14 = $OutputDir + "\Excel Acceptance Log.xlsx"
    
Node ..\idems_translation\chatbot\index.js has_any_words_check $InputFile $OutputDir $JSON9 $LOG10
Node ..\idems_translation\chatbot\index.js fix_arg_qr_translation $JSON9Path $OutputDir $JSON11 $LOG12
Node ..\idems_translation\chatbot\index.js overall_integrity_check $JSON11Path $OutputDir $LOG13 $LOG14

Write-Output "Completed integrity check"
#>


# step 4: add quick replies to message text and translation
$add_selectors = "yes"
$input_path_4 = $output_path_1
$source_file_name = $source_file_name + "_no_QR"
$select_phrases_file = ".\edits\select_phrases.json"
$output_path_4 = ".\temp\"
$output_name_4 = $source_file_name 
node ..\idems_translation\chatbot\index.js move_quick_replies $input_path_4 $select_phrases_file $output_name_4 $output_path_4 $add_selectors
Write-Output "Removed quick replies"


