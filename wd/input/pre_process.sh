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

IFS=$'\r\n'

echo ""

# Move tmp_uploads to toProcess
while read line; do
	[[ "$line" =~ "#" ]] && continue

	if [[ "$line" =~ "Name:" ]]; then continue
	elif [[ "$line" =~ "Theme:" ]]; then continue
	elif [[ "$line" =~ "Author:" ]];then continue
	fi

	# Song names
	file=$(echo -e $line | awk -F"\t" '{print $NF}')
	active_file=$indir/$file
	
	if [ -f $active_file ];then
		cp $active_file $outdir/$file
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
	
	#If already exists, move it
	if [ -f $outname ]; then
		echo "  already exists..."
		continue
	fi
	if [ -f $newname ]; then
		echo "  already exists...moving"
		cp $newname $outname
		continue
	fi
	
	echo "        Retrieve Youtube -->";
	$(youtube-dl "$link" -c -q --extract-audio --audio-format=aac -o $tmpname".flv")
	#outputs "tmp.aac"
	
	if ! [[ "$ext" =~ "aac" ]];then
		echo "            ---> to $ext";
		$(ffmpeg -v quiet -i $tmpname".aac" -f wav - 2>/dev/null | lame - "$newname" 2>/dev/null);
		echo IF:"$filename " >&2 #$link $ext $tmpname $newname $outname" >&2
	fi
	
	cp $newname $outname
	echo "~~~ DONE ~~~~"
#	rm $newname $tmpname".aac" $tmpname".flv" 2>/dev/null
	
done < $ytubfile

#rm $ytubfile
