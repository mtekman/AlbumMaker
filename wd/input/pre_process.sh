#!/bin/bash

if [ $# != 4 ];then
	echo "Moves temporary audio files to static processing folder, and downloads+converts youtube videos and moves them into the static processing folder

usage: `basename $0`   List.txt   YoutubeFile.txt   tmp_files_folder   static_proc_folder
" >&2
	exit
fi

listfile=$1
ytubfile=$2

indir=$3
outdir=$4

dos2unix $listfile 1>&2

#OLDIFS=$IFS
IFS=$'\r\n'

echo ""

# Move tmp_uploads to toProcess
while read line; do
	[[ "$line" =~ "#" ]] && continue

	if [[ "$line" =~ "Name:" ]]; then
		continue
	elif [[ "$line" =~ "Theme:" ]]; then
		continue
	elif [[ "$line" =~ "Author:" ]];then
		continue
	fi

	# Song names
	file=$(echo -e $line | awk -F"\t" '{print $NF}')
	active_file=$indir/$file
	
	if [ -f $active_file ];then
		mv $active_file $outdir/$file
		echo "priming $file"
	fi
done < $listfile


# Convert Youtube
while read line; do
	# Song names
	words=$(echo $line | wc -w)
	[ "$words" = "0" ] && continue

	filename=$(echo $line | awk -F"\t" '{print $NF}')
	echo "$filename:"
	
	link=$(echo $line | awk -F"\t" '{print $1}');
	ext=$(echo `basename $filename` | awk -F '.' '{print $NF}');
	
	tmpname="$indir/tmp"
	newname="$indir/$filename"
	outname="$outdir/$filename"
	
<<<<<<< HEAD
	echo "        ---> Youtube";
	youtube-dl "$link" -c -q --extract-audio --audio-format=aac -o $tmpname".flv"
	#outputs: "$tmpname.aac"
=======
#	echo "        Retrieve Youtube -->";
	$(youtube-dl "$link" -c -q --restrict-filenames --extract-audio --audio-format=aac -o $tmpname".flv")
	#outputs "tmp.aac"
>>>>>>> 9686149bd3d98b4842e6d8b4bd757b910cbdb939
	
	if ! [[ "$ext" =~ "aac" ]];then
		#convert using mencoder, more stable seek opts than ffmpeg (though I love ffmpeg :(   )
		#mencoder -ovc frameno -oac mp3lame -lameopts cbr:br=256 -of rawaudio -o download.mp3 -audiofile download.aac download.flv
		
<<<<<<< HEAD
		echo "            ---> to $ext";
		#avconv -i $tmpname".aac" -v quiet -q:a 0 "$newname";   # Seeking issue persists, likelt libav-extras at fault.
		# Using Lame pipe
		ffmpeg -v quiet -i $tmpname".aac" -f wav - | lame -V 3 - "$newname"
=======
#		echo "            ---> to $ext";
		$(ffmpeg -v quiet -i $tmpname".aac" -f wav - 2>/dev/null | lame - "$newname" 2>/dev/null);
		echo IF:"$filename " >&2 #$link $ext $tmpname $newname $outname" >&2

>>>>>>> 9686149bd3d98b4842e6d8b4bd757b910cbdb939
		
	else
#		if [ -f $tmpname".aac" ];then
#			mv $tmpname".aac" $newname
#		else
#			echo "\nCANT FIND: $tmpname.aac";
#		fi
		echo ELSE:"$filename " >&2 #$link $ext $tmpname $newname $outname" >&2
	fi
	
	cp $newname $outname
	echo "~~~ DONE ~~~~"
	rm $newname $tmpname".aac" $tmpname".flv" 2>/dev/null
	
	#echo $line >&2

done < $ytubfile

#rm $ytubfile
