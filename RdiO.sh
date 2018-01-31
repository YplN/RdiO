#!/bin/bash

#echo "Ceci est un test">>test.cfg
#for WORD in `cat test.cfg`
#do
#    echo $WORD
#done


CONFIG_FILE=conf.cfg
INIT_FILE=init.cfg

resetdata()
{
	# Wipe data
	> $CONFIG_FILE

	# Restaure data
	while IFS= read -r var
	do
  		echo "$var" >> $CONFIG_FILE
	done < $INIT_FILE
}

setdata()
{
	if [ $# = 3 ]
	then
		`sed -n -i 'p;'$1'a '$2  $3`
	else
		echo "Error in arguments of setdata"
	fi	
}

replacedata()
{
	if [ $# = 3 ]
	then
		`sed -i $1"s/.*/"$2"/ " $3`
	else
		echo "Error in arguments of setdata"
	fi	
}

getdata()
{
	if [ $# = 2 ]
	then
		echo `sed -n $1'p' < $2`
	else
		echo "Error in arguments of getdata"
	fi	
	
}

getradioname()
{
	let "id_radio = 2 * $1"
	name=$(getdata $id_radio $CONFIG_FILE)
	echo $name
}

getradiourl()
{
	let "id_radio = 2 * $1 + 1"
	url=$(getdata $id_radio $CONFIG_FILE)
	echo $url
}

addradioat()
{	
	#We check if the radio does not already exist
	exists_name=$(radioexists $1)
	exists_url=$(radioexists $2)
	
	if [ "$exists_name" = true ] || [ "$exists_url" = true ]
	then
		echo "Error... The radio already exists..."
		exit 1
	fi
	
	nb_radio=$(getdata 1 $CONFIG_FILE)
	let "nb_radio = nb_radio + 1"
	replacedata 1 $nb_radio $CONFIG_FILE
	setdata $1 $3 $CONFIG_FILE
	setdata $1 $2 $CONFIG_FILE
}

radioexists()
{

	nb_radio=$(getdata 1 $CONFIG_FILE)
	i=1
	in=false

	while [ "$i" -le "$nb_radio" ] && [ "$in" = false ]
	do
		let "id_url = 2 * i + 1"
		let "id_name = 2 * i"
		name_radio=$(getdata $id_name $CONFIG_FILE)
		url_radio=$(getdata $id_url $CONFIG_FILE)
		
		if [ "$name_radio" = "$1" ] || [ "$url_radio" = "$1" ]
		then 
			in=true
			echo true
		fi 
		let "i = i + 1" 
	done
	
	let "i = i - 1"
 
	if [ "$in" = false ]
	then
		echo false
	fi
}
	

addradio()
{

	#We check if the radio does not already exist
	exists_name=$(radioexists $1)
	exists_url=$(radioexists $2)

	if [ "$exists_name" = true ] || [ "$exists_url" = true ]
	then
		echo "Error... The radio already exists..."
		exit 1
	fi

	echo Hey

	# We update the number of radios
	nb_radio=$(getdata 1 $CONFIG_FILE)
	let "nb_radio = nb_radio + 1"
	replacedata 1 $nb_radio $CONFIG_FILE

	# We calcul the new last line
	let "line_id = 2 * nb_radio"
	let "last_line_id = line_id - 1"

	#We have to add a new line
	last_line_data=$(getdata $last_line_id $CONFIG_FILE)
	last_line_data=$last_line_data'\n'	
	setdata $last_line_id $last_line_data $CONFIG_FILE
	
	#We put the new infos
	replacedata $line_id $1 $CONFIG_FILE
	setdata $line_id $2 $CONFIG_FILE
}

printradiochoices()
{
	nb_radio=$(getdata 1 $CONFIG_FILE)
	echo -e "List of the Rdios: "
	for (( i=1; i<=$nb_radio; i++ ))
	do
		name_radio=$(getradioname $i)
		echo -e '\t' $i ". " $name_radio 
#$url_radio 
	done
	
}

streamradio()
{
	radio_name=$(getradioname $1)
	radio_url=$(getradiourl $1)
	echo -e "Streaming "$radio_name"... \n"
	`mpv $radio_url >/dev/null 2>&1`
}


editradio()
{
	echo TODO
}

try()
{

	for (( i=0; i<=$1; i++ ))
	do
	prog=""
		for (( j=0; j<i; j++ ))
		do
			prog=$prog"="
		done
		prog=$prog"I"
		for (( j=i; j<=$1; j++ ))
		do
			prog=$prog"="
		done
	echo -e "\e[1A\r "$prog
	sleep 0.2
	done
	#echo -e "\n"
	
#https://stackoverflow.com/questions/11283625/bash-overwrite-last-terminal-line
}

test_id="FIP"
test_url="http://direct.fipradio.fr/live/fip-midfi.mp3"

try 20
#printradiochoices
#read choice
#streamradio $choice

#resetdata

exit 1

if [ $# -eq 0 ]
then 
	echo "Type --franceinter or -in to stream France Inter."
	echo "Type --franceculture or -fc to stream Franceculture."
	echo -e "Type --franceinfo or -fi to stream France Info.\n"
	echo "Type quit or q to quit"
	
	read radio

else 
	case $1 in
		"--franceinter" | "-in")
			echo "STREAMING France Inter"
			mpv http://direct.franceinter.fr/live/franceinter-midfi.mp3 
			echo "Good bye ;)"
			exit 1
			;;
		"--franceinfo" | "-fi")
			echo "STREAMING France Info"
			mpv http://direct.franceinfo.fr/live/franceinfo-midfi.mp3
			echo "Good bye ;)"
			exit 1
			;;
		"--franceculture" | "-fc")
			echo "STREAMING France Culture"
			mpv http://direct.franceculture.fr/live/franceculture-midfi.mp3
			echo "Good bye ;)"
			exit 1
			;;
		"quit" | "q")
			echo "Good bye ;)"
			exit 1
			;;
		*)
			;;
	esac
	ok=true
fi

#echo $radio

ok=false

while [ "$ok" = false ] 
do
	#echo $radio
	if [ "$radio" != "--franceinter" ] && [ "$radio" != "-in" ] && [ "$radio" != "--franceculture" ] && [ "$radio" != "-fc" ] && [ "$radio" != "--franceinfo" ] && [ "$radio" != "-fi" ] && [ "$radio" != "quit" ] && [ "$radio" != "q" ]
	then
		echo "Argument not valid..." 
		echo "Type --franceinter or -in to stream France Inter."
		echo "Type --franceculture or -fc to stream Franceculture."
		echo "Type --franceinfo or -fi to stream France Info."
		echo "Type quit or q to quit"
		read radio
	else
		ok=true
	fi

	case $radio in
		"--franceinter" | "-in")
			echo "STREAMING France Inter"
			mpv http://direct.franceinter.fr/live/franceinter-midfi.mp3
			echo "Good bye ;)"
			exit 1 
			;;
		"--franceinfo" | "-fi")
			echo "STREAMING France Info"
			mpv http://direct.franceinfo.fr/live/franceinfo-midfi.mp3
			echo "Good bye ;)"
			exit 1
			;;
		"--franceculture" | "-fc")
			echo "STREAMING France Culture"
			mpv http://direct.franceculture.fr/live/franceculture-midfi.mp3
			echo "Good bye ;)"
			exit 1
			;;
		"quit" | "q")
			echo "Good bye ;)"
			exit 1
			;;
		*)
			;;
	esac
done
