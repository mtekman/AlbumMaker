#!/bin/bash


if [ $# != 3 ];then
	echo "Produces two zip files with correct tags
usage: `basename $0` List.txt mp3_folder output_folder_zips
"
	exit
fi

listfile=$1
mp3fold=$2
out_fold=$3

obs_fold="obfuscated"
mkdir -p $obs_fold
mkdir -p $out_fold

[[ "$out_fold" =~ "out" ]] && rm $out_fold/*

dos2unix $listfile 1>&2

IFS=$'\n\t'

theme=""
theme_author=""
week_name=""

echo ""

while read line; do
	[[ "$line" =~ "#" ]] && continue

	if [[ "$line" =~ "Name:" ]]; then
		week_name=`echo $line | awk -F ':' '{print $NF}' | sed -e 's/^ *//g' -e 's/ *$//g'`
		continue
	elif [[ "$line" =~ "Theme:" ]]; then
		theme=`echo $line | awk -F ':' '{print $NF}' | sed -e 's/^ *//g' -e 's/ *$//g'`
		continue
	elif [[ "$line" =~ "Author:" ]];then
		theme_author=`echo $line | awk -F ':' '{print $NF}' | sed -e 's/^ *//g' -e 's/ *$//g'`
		continue
	fi


	# Song names
	author=$(echo $line | awk '{print $1}' | sed -e 's/^ *//g' -e 's/ *$//g')
	number=$(echo $line | awk '{print $2}' | sed -e 's/^ *//g' -e 's/ *$//g')

	file=$(echo $line | awk '{for(i=3; i<NF; i++){printf $i" ";}print $NF;}')

	artist=$(echo $file | awk -F'-' '{print $1}')
	track=$(echo $file | awk -F'-' '{print $2}' | awk -F '.' '{print $1}')

	active_file=$mp3fold/$file

	echo -en $number" "$file": normalizing..."
	normalize-audio $active_file 1>&2
	echo -en "X,    adding tags..."
	
	#Strip file of all meta
	eyeD3 --remove-all $active_file 1>&2
	
	obs_file=$obs_fold/"Song $number".mp3
	cp $active_file $obs_file

	#Add meta to real file
	eyeD3 \
         -t "$track" -a "$artist" -n $number\
	 -A "$week_name [$author]"\
	 --comment=eng:"$theme_author":"$theme"\
	 --add-image $mp3fold/AA.jpg:OTHER\
	$active_file 1>&2
	echo -en " REAL "
	
	# Add meta to obfuscated file
	eyeD3 \
	 -A "$week_name"\
	 --comment=eng:"$theme_author":"$theme"\
	 --add-image $mp3fold/AA.jpg:OTHER\
	$obs_file 1>&2
	echo -en " CYPHER\n"

done < $listfile

chmod a+wrx $mp3fold 1>&2
chmod a+wrx $obs_fold 1>&2

echo -e "\nMaking Real Zips"
z_dec="`echo $week_name\"_DECYPHERED\" | sed 's/\ /\_/g'`.zip"
zip -j $z_dec $mp3fold/*.mp3
mv $z_dec $out_fold/ 2>&1

echo -e "\nMaking Cypher Zips"
z_dec2="`echo $week_name | sed 's/\ /\_/g'`.zip"
zip -j $z_dec2 $obs_fold/*.mp3
mv $z_dec2 $out_fold/ 2>&1

chmod a+wrx $out_fold/*.zip
[[ "$obs_fold" =~ "obf" ]] && rm -rf $obs_fold
[[ "$mp3fold" =~ "upload" ]] && rm $mp3fold/*

echo -e "\n~~~~~~~~~~~~~~~~[FINIT]~~~~~~~~~~~~~~~~"
