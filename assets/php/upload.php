<?php

$file_id='filer';
$status='';

//$date = date('Y_m_d_H:i:s');
//$date = date('Y_m_d_H:i');
//dont need seconds, a reupload in under a minute of the same file must be a mistake by user.

//$filename="../upload_data/" . $date . "_" . $_FILES[$file_id]['name'];
$filename="../../wd/input/tmp_uploads/" . $_FILES[$file_id]['name'];

$tmpfile=$_FILES[$file_id]['tmp_name'];


if(!$_FILES[$file_id]['name']) {
    	return;
  }
  /*copy file over to tmp directory */
if(move_uploaded_file($tmpfile, $filename)){
	json_encode($filename);
}

?>
