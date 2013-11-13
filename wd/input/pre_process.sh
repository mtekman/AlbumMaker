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

IFS=$'\n\r'

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
	filename=$(echo $line | awk -F"\t" '{print $NF}')
	[ "$filename" = "" ] && continue
	echo "$filename:"
	
	link=$(echo $line | awk -F"\t" '{print $1}');
	ext=$(echo `basename $filename` | awk -F '.' '{print $NF}');
	
	tmpname="$indir/tmp"
	newname="$indir/$filename"
	outname="$outdir/$filename"
	
	echo "        ---> Youtube";
	youtube-dl "$link" -c -q --extract-audio --audio-format=aac -o $tmpname".flv"
	#outputs "tmp.aac"
	
	if ! [[ "$ext" =~ "aac" ]];then
		#convert using mencoder, more stable seek opts than ffmpeg (though I love ffmpeg :(   )
		#mencoder -ovc frameno -oac mp3lame -lameopts cbr:br=256 -of rawaudio -o download.mp3 -audiofile download.aac download.flv
		
		echo "            ---> to $ext";
		avconv -i $tmpname".aac" -v quiet -q:a 0 "$newname";
	else
		if [ -f $tmpname".aac" ];then
			mv $tmpname".aac" $newname
		else
			echo "\nCANT FIND: $tmpname.aac";
		fi
	fi
	
	cp $newname $outname
	echo "~~~ DONE ~~~~"
	rm $newname $tmpname".aac" $tmpname".flv" 2>/dev/null

done < $ytubfile

rm $ytubfile
