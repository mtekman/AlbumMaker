<?php 

echo "<html>";
/* THIS IS NEEDED TO ENABLE OUTPUT_BUFFERING IN FIREFOX. IF THERE'S THE 
 * SLIGHTEST WHIFF OF AN ERROR IT WILL NOT BUFFER THE PAGE DESPITE ALL
 * php.info flags */
echo '<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">';
echo "<head>";
echo "<style>";
echo "
/*#zips {
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
}*/
";

echo "</style>";
echo "</head>";

echo "Album: ".htmlspecialchars($_POST["album_name"])."<br>";
echo "Author: ".htmlspecialchars($_POST["author_name"])."<br>";
echo "Theme: ".htmlspecialchars($_POST["theme_name"])."<br>";

$tmp_AA_name=$_POST["AA_filename"];
echo "Album Art:" . htmlspecialchars($tmp_AA_name) . "<br>";
echo "<br>";

$ident="songs";

//Dirs
$wd="../../wd";
$tmpuplDir="$wd/input/tmp_uploads";
$uploadDir="$wd/input/toProcess";
$outputDir="$wd/output/";

//Input files
$listfile="$uploadDir/List.txt";
$ytubfile="$tmpuplDir/Youtube.txt";

$files = glob("$uploadDir/{,.}*", GLOB_BRACE); // get all file names
foreach($files as $file){ // iterate files
  if(is_file($file))
    unlink($file); // delete file
}

//Move AlbumArt to AA.jpg, if it exists..
if (strlen(trim($tmp_AA_name))>=1) rename("$tmpuplDir/$tmp_AA_name", "$uploadDir/AA.jpg");

//Write List.txt for audio pipeline
file_put_contents($listfile, $_POST["json_name"]);
if (!file_exists($listfile)) die("<h2>Error:Could not make song list</h2>");


//Write Youtube.txt for audio pipeline
file_put_contents($ytubfile, $_POST["json_name_youtube"]);
if (!file_exists($ytubfile)) die("<h2>Error:Could not make youtube list</h2>");

//Prime nonbuffering stdout
ob_implicit_flush(true); 
ob_end_flush();		//Tell PHP to flush stdout

$descriptorspec = array(
   0 => array("pipe", "r"), 		// stdin is a pipe that the child will read from
   1 => array("pipe", "w"), 		// stdout is a pipe that the child will write to
   2 => array("pipe", "w") 			// stderr is a pipe that the child will read from
);



//Move files from tmp_uploads/ to toProcess/, and download and convert youtube files
echo "<div id='preprocess'>";
echo "<h3>Pre-Processing</h3>";
$cmd = "$wd/input/pre_process.sh $listfile $ytubfile $tmpuplDir $uploadDir";
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
echo "</pre></div>";


///        Begin pipeline processing
echo "<div id='results'>";

$cmd = "$wd/audio_pipeline.sh $listfile $uploadDir $outputDir 2> /dev/null";
echo "<h2>Audio Pipeline</h2><br>";
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
	$zips=glob("$outputDir/*");
	foreach ($zips as $zip){
		echo "<a href='" . $zip . "'>" . basename($zip) . "</a><br>";
	}
}
echo "</div>";
echo "</html>";
