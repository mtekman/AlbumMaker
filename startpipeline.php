<?php 

echo "<html>";
/* THIS IS NEEDED TO ENABLE OUTPUT_BUFFERING IN FIREFOX. IF THERE'S THE 
 * SLIGHTEST WHIFF OF AN ERROR IT WILL NOT BUFFER THE PAGE DESPITE ALL
 * php.info flags */
echo '<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">';
echo "<head>";
echo "<style>";
echo "
#zips {
	text-align:left;
	border: 2px dashed #d5d0e0; 
	margin-top:10px;
	background-color:#6C5555;
	border-radius: 10px 10px 10px 10px;
	padding-left:20px;
	padding-bottom:20px;
}

#results {
	text-align:center;
	border: 2px dashed #d5d0e0; 
	margin-top:10px;
	background-color:#6C8E74;
	border-radius: 10px 10px 10px 10px;
}

.stderr {
	color:#991111;
	text-align:left;
}
";

echo "</style>";
echo "</head>";

echo "Album: ".htmlspecialchars($_POST["album_name"])."<br>";
echo "Author: ".htmlspecialchars($_POST["author_name"])."<br>";
echo "Theme: ".htmlspecialchars($_POST["theme_name"])."<br>";
echo "Album Art:" . htmlspecialchars($_FILES["AA"]["name"]) . "<br>";

echo "<br>";

$ident="songs";
$uploadDir="uploadFiles";


system("rm -rf $uploadDir");
mkdir($uploadDir);

for ($i=0; $i < count($_FILES[$ident]["tmp_name"]) ; $i++ )
{
	$error_msg = $_FILES[$ident]["error"][$i];
	$file_name = $_FILES[$ident]["name"][$i];
	$tmp_name = $_FILES[$ident]["tmp_name"][$i];

	if ($error_msg !=0 ) {
		echo "Error:" . $file_name . " did not upload<br>";
		continue;
	}

	if (!move_uploaded_file($tmp_name, "$uploadDir/$file_name")){
		echo "Error: did not move " . $tmp_name . " to " . $uploadDir/$file_name . "<br>";
	}
}


//Move AlbumArt to AA.jpg, if it exists..
move_uploaded_file($_FILES["AA"]["tmp_name"], "$uploadDir/AA.jpg");

$listfile="$uploadDir/List.txt";
file_put_contents($listfile, $_POST["json_name"]);
if (!file_exists($listfile)) die("<h2>Error:Could not make list file</h2>");


echo "<div id='results'>";
///        Begin pipeline processing
ob_implicit_flush(true); 
ob_end_flush();		//Tell PHP to flush stdout

$outputdir="output";

$cmd = "./audio_pipeline.sh $listfile $uploadDir $outputdir 2> /dev/null";
echo "<h2>Audio Pipeline</h2><br>";

$descriptorspec = array(
   0 => array("pipe", "r"), 		// stdin is a pipe that the child will read from
   1 => array("pipe", "w"), 		// stdout is a pipe that the child will write to
   2 => array("pipe", "w") 			// stderr is a pipe that the child will read from
);
flush();
$process = proc_open($cmd, $descriptorspec, $pipes, realpath('./'), array());
echo "<pre>";



if (is_resource($process)) {
	while ($s = fgets($pipes[1])) {
		print $s;
		ob_flush();
		flush();
	}
	echo "<span class='stderr' >";
	while ($s = fgets($pipes[2])) {
		print $s;
		ob_flush();
		flush();
	}
	echo "</span>";
}

echo "</pre>";
echo "</div>";

echo "<div id='zips'>";
if (proc_close($process)==0){
	echo "<h2>Output Zips</h2>";
	$zips=glob("output/*.zip");
	foreach ($zips as $zip){
//		print $zip;
		echo "<a href='" . $zip . "'>" . basename($zip) . "</a><br>";
	}
}
echo "</div>";

echo "</html>";
