#!/bin/bash

CONFIG_FILE=conf.cfg
INIT_FILE=init.cfg
let "TERMINAL_SIZE =`tput cols` - 2"


# Reset the CONFIG FILE
# No input
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

# Write at a specific line of a file
# $1:n°line $2:data $3:file
setdata()
{
	if [ $# = 3 ]
	then
		`sed -n -i 'p;'$1'a '$2  $3`
	else
		echo "Error in arguments of setdata"
	fi	
}


# Diff avec setdata?
# Replace data at a specific line of a file
# $1:n°line $2:data $3:file
replacedata()
{
	if [ $# = 3 ]
	then
		`sed -i $1"s/.*/"$2"/ " $3`
	else
		echo "Error in arguments of setdata"
	fi	
}

# Echo the data contained in a specific line of a file
# $1:n°line $2:data $3:file
getdata()
{
	if [ $# = 2 ]
	then
		echo `sed -n $1'p' < $2`
	else
		echo "Error in arguments of getdata"
	fi	
	
}


# Replace a specific radio data into another one
# $1:n°radio $2:name $3:url
replaceradio()
{
	
	if [ $# = 3 ]
	then
		let "id_radio_name = 2 * $1"
		let "id_radio_url = 2 * $1 + 1"
		replacedata $id_radio_name $2 $CONFIG_FILE
		replacedata $id_radio_url $3 $CONFIG_FILE	
	else
		echo "Error in arguments of replacedata"
	fi
}

# Echo the number of radio in CONFIG FILE
# No input
getnbradio()
{
	nb=$(getdata 1 $CONFIG_FILE)
	echo $nb
}

# Echo the name of a specific radio
# $1:n°radio
getradioname()
{
	let "id_radio = 2 * $1"
	name=$(getdata $id_radio $CONFIG_FILE)
	echo $name
}

# Echo the url of a specific radio
# $1:n°radio
getradiourl()
{
	let "id_radio = 2 * $1 + 1"
	url=$(getdata $id_radio $CONFIG_FILE)
	echo $url
}

# Seems useless
# Add a new radio at a specific place
# $1:position $2: name $3:url
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

# Echo true/false if the radio with the same name/url already exists
# $1: data (name or url)
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


#Echo true/false if the input is a number within a good range (1<=n<=#radio)
#$1:data
isvalidradio()
{
	nb_radio=$(getnbradio)
	if [ $(isnumber $1) = true ] && [ "$1" -le "$nb_radio" ] && [ "$1" -ge 1 ]
	then
		echo true
	else
		echo false
	fi
}


#Edit Radio : Choose part
# No Input
printeditradiochoose()
{
	echo -e "To edit a radio, first select which one you want to modify or c to cancel"
	printradiochoices
	
	ok=false
	
	while [ $ok = false ]
	do
		read choice
		
		if [ $(isvalidradio $choice) = true ]
		then
			ok=true
			printeditradio
			editradio choice
		else
			echo -e "Error in passing argument..."
		fi
	done	
	
}

# Edit Radio: Add the new radio
# No input
printeditradio()
{
	echo -e "To edit a the selected radio, type radio_name radio_url or c to cancel"
	echo -e "Tip radio url can be found online, for exemple on https://fluxradios.blogspot.fr/" 
}
	

# Write in CONFIG FILE the new radio 
# $1: name $2: url
addradioindata()
{
	#We check if the radio does not already exist
	exists_name=$(radioexists $1)
	exists_url=$(radioexists $2)

	if [ "$exists_name" = true ] || [ "$exists_url" = true ]
	then
		echo "Error... The radio already exists..."
		exit 1
	fi

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

# Echo the list of the saved radios
# No input
printradiochoices()
{
	nb_radio=$(getdata 1 $CONFIG_FILE)
	echo -e "List of your Rdios: "
	for (( i=1; i<=$nb_radio; i++ ))
	do
		name_radio=$(getradioname $i)
		echo -e '\t' $i ". " $name_radio 
	done
	
}

# Print the list of the settings
# No input
printsettings()
{
	echo -e "Settings: "
	echo -e '\t' "- Type [a]dd to add a new station."
	echo -e '\t' "- Type [e]dit to edit the data of a station."
	echo -e '\t' "- Type [r]eset to reset the data."
	echo -e '\t' "- Type [q]uit to quit.\n"
}

#Print the message asking to chose the station
# No input
printchoose()
{
	echo -e "Type the number of the station you want in the list, or type [s]ettings."
}

#Print Tip to add new radio
# No input
printaddmenu()
{
	echo -e "To add a new station, type radio_name radio_url or c to cancel"
	echo -e "Tip radio url can be found online, for exemple on https://fluxradios.blogspot.fr/" 
}


#Function to add a radio
# No input
addradio()
{
	printaddmenu
	read data
	i=0
	for info in $data
	do
		case $i in
			"0")
				name_radio=$info
				;;
			"1")
				url_radio=$info
				;;
			*)
				echo -e "Error with arguments... "
				addradio 
				exit 1		
		esac
		let i+=1
	done
	

	# only name
	if [ $i -eq 1 ]
	then
		if [ "$name_radio" = "c" ]
		then		
			echo -e "Canceled."			
			exit 1
		else
			echo -e "Error with arguments... "
			addradio 
			exit 1
		fi
	fi
	
	echo -e "Adding radio " $name_radio " with url " $url_radio " in "$CONFIG_FILE"..."
	addradioindata $name_radio $url_radio	
	checkdata
	echo -e "Radio added !"
}


# Start the streaming of the radio. 
# $1: N° radio
# IMPORTANT : Return the PID of mvp
streamradio()
{
	radio_name=$(getradioname $1)
	radio_url=$(getradiourl $1)

	mpv $radio_url  >/dev/null 2>&1 &
	#echo the PID that we have to kill to stop the radio
	echo $!
}

#A bit useless
#Function to edit the radio
# No input
startedit()
{
	printeditradiochoose
}


# Edit the radio in the CONFIG FILE
# No input
editradio()
{
	read data
	i=0
	for info in $data
	do
		case $i in
			"0")
				name_radio=$info
				;;
			"1")
				url_radio=$info
				;;
			*)
				echo -e "Error with arguments... "
				addradio 
				exit 1		
		esac
		let i+=1
	done
	

	# only name
	if [ $i -eq 1 ]
	then
		if [ "$name_radio" = "c" ]
		then		
			echo -e "Canceled."			
			exit 1
		else
			echo -e "Error with arguments... "
			addradio 
			exit 1
		fi
	fi
	
	echo -e "Modifying radio into " $name_radio " with url " $url_radio " in "$CONFIG_FILE"..."
	replaceradio $1 $name_radio $url_radio	
	checkdata
	echo -e "Radio modified !"
}

# Check that CONFIG FILE is ok
# No input
checkdata()
{
	echo TODO
}


# Function to reset data
# No input
reset()
{
	echo "This operation will reset your data. Continue? (y/n)"
	ok=true	

	while [ "$ok" = true ]
	do
		read choice
		case $choice in
				"y" | "Y")
					echo -e "Fine. Let's clean this mess."
					resetdata
					echo -e "Done."
					ok=false
					;;
				"n" | "N")
					ok=false
					echo -e "Canceled. Fiouf."
					;;
				*)
					echo -e "Input not valid... Type y if you want to wipe your radios, n otherwise."
					;;
		esac
	done
}


#Print choose
# No input
choose()
{
	printradiochoices
	printchoose
}

# Kikoo progressbar and eventualy kill the process of mpv
# $1: size of the bar [$2: PID of the process]
movingprogressbar()
{
	if [ -t 0 ]; then stty -echo -icanon -icrnl time 0 min 0; fi
	
	let "size = $1 + 7"
	sleep_time=0.03
	prog=""
	for (( i=0; i<$1; i++ ))
	do
		prog=$prog"="
	done

	count=8
	keypress=''
	while [ "x$keypress" = "x" ]; do
  		let count+=1
		if [ $count -gt $size ] 
		then
			count=7
		fi
		sleep $sleep_time
		echo -e "\e[1A\r" $prog | sed s/./I/$count
		keypress="`cat -v`"
	done
	
	if [ -t 0 ]; then stty sane; fi
	
	if [ $# -gt 1 ]
	then
		kill $2
	fi

#https://stackoverflow.com/questions/11283625/bash-overwrite-last-terminal-line
	
}


# Kikoo progressbar and eventualy kill the process of mpv
# $1: size of the bar [$2: PID of the process]
movingprogressbar2()
{
	if [ -t 0 ]; then stty -echo -icanon -icrnl time 0 min 0; fi
	
	let "size = $1 + 7"
	sleep_time=0.045
	pattern="¸,ø¤º°º¤ø,¸"
	pattern_size=11
	
	for (( i=0; i<$1; i++ ))
	do
		let "p = i % pattern_size"
		line=$line${pattern:p:1}
	done

	fullline=$line
	
	let "t1 = $1 - 1"
	
	keypress=''
	while [ "x$keypress" = "x" ]; do
  		sleep $sleep_time 

		fullline=${fullline:1:$t1}${fullline:0:1}

		echo -e "\e[1A\r" $fullline
		keypress="`cat -v`"
	done
	
	if [ -t 0 ]; then stty sane; fi
	
	if [ $# -gt 1 ]
	then
		kill $2
	fi


#https://stackoverflow.com/questions/11283625/bash-overwrite-last-terminal-line
	
}


#Because we're not sauvages
# No input
welcome()
{

	clear

	echo -e "Welcome to..."
	echo -e "\t  __           __               "
	echo -e "\t | _|  ____   |_ |  ____        "
	echo -e "\t | |  |  _ \   | | |  _ \  ___  "
	echo -e "\t | |  | |_) |  | | | | | |/ _ \ "
	echo -e "\t | |  |  _ <   | | | |_| | (_) |"
	echo -e "\t | |  |_| \_\  | | |____/ \___/ "
	echo -e "\t |__|         |__|              \n"
}

# No, we're not.
# No input
bye()
{
	echo -e "Thank you for using RdO ! <3"
	echo -e "See you later !"
}

#Check if the data is a number
#$1:data
isnumber()
{
	case $1 in
	    ''|*[!0-9]*) echo false ;;
	    *) echo true ;;
	esac
}


## tests stuff #######
test_id="FIP"
test_url="http://direct.fipradio.fr/live/fip-midfi.mp3"
######################





######################
###       RDo      ###
######################



welcome
keypress=''

while [ "$keypress" != "q" ]; do
	nb_radio=$(getnbradio)
	choose
	read keypress

	if [ $(isvalidradio $keypress) = true ]
	then
		radio_name=$(getradioname $keypress)
		radio_url=$(getradiourl $keypress)
		PID_stream=$(streamradio $keypress &)
	
		echo -e "Streaming "$radio_name"... "
		echo -e "Type any key to interrupt, q to quit.\n"
		movingprogressbar2 $TERMINAL_SIZE $PID_stream
	elif [ "$keypress" = "s" ] || [ "$keypress" = "settings" ]
	then
		printsettings
		read keypress

		case $keypress in
			"a" | "add")
				addradio
				;;
			"e" | "edit")
				startedit
				;;
			"r" | "reset")
				reset
				;;
			"q" | "quit")
				bye
				exit 1
				;;	
			*)
				keypress=''
				;;
		esac
	fi		
done

bye

