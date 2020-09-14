#!/bin/bash

banner()
{
	echo "   ______________________________________________"
	echo -e "  \e[0;m|\e[0;32mAircrack Boost Script\e[0;35m 1.1 © 2015\t\t \e[0;m|"
	echo -e "  \e[0;m|\e[0;32mAuthor  : \e[0;34mHardeep Singh\t\t\t \e[0;m|"
	echo -e "  \e[0;m|\e[0;32mWebsite : \e[0;34mhttp://www.rootsh3ll.com\t\t \e[0;m|"
	echo -e "   ----------------------------------------------\n"
}

help_fn()
{
	echo -e "  \e[0;32mUsage\e[0;m   : $0 \e[0;34m[wordlist] [.cap file] [SSID] \n"
	echo -e "  \e[0;32mOption\e[0;m  :\n \e[0;31m   -h\e[0;m\t  : Help menu"
	echo -e "  \e[0;31m  -r \e[0;m\t  : Read from stdin \e[0;34m (Drag n Drop)\n"
	exit
}

dependepcies_check()
{
	if [[ $(whoami) != "root" ]]; then
		echo "Try running script as root"
		echo "Example: sudo ./$0"
		exit
	elif [[ ! $(which cowpatty) ]]; then
		sudo apt-get install cowpatty;
		clear
	elif [[ ! $(which pyrit) ]]; then
		sudo apt-get install pyrit;
		clear
	fi
}

menu()
{
	echo -e "\n \e[2;32mHit \e[0;31mCTRL+C\e[0;32m to exit"
	echo -e " \e[0;34mGenerate PMKs using : "
	echo -e " \n\e[0;31m1. Pyrit\e[0;34m (Fast)"
	echo -e " \n\e[0;31m2. GenPMK\e[0;34m (Slow)"
#	echo -e " \n\e[0;31m3. Airolib\e[0;34m (SQLite3 support)"
	echo -n -e "\n \e[0;34mChoice : \e[0;32m"
	read choice
}

stdin()
{
	echo -e "\e[0;32mEnter path\e[0;m or Simply \e[0;32mDrag n drop\e[0;m\n"
	read -p "Wordlist  : " word
	read -p ".cap file : " cap
	read -p "SSID      :  " ssid
	word=$(echo $word | awk -F "'" '{print $2}')
	cap=$(echo $cap | awk -F "'" '{print $2}')
	menu
	pmk "$word" "$cap" "$ssid"
}

start_fn()
{
	if [ "$1" = "--help" -o "$1" = '-h' ]; then
		help_fn
	elif [ "$1" = "-r" ]; then
		banner
		stdin
	elif [ -z "$1" ]; then
		banner
		help_fn
	elif [ -f "$1" -a -f "$2" ]; then
		if [ -z "$3" ]; then
			help_fn
		else
			banner
			menu
			pmk "$@"
		fi
	else
		help_fn
	
 	fi
}

pmk() 
{
	
	word=$(readlink -f "$word")
	date_start=$(date +%s)
	case $choice in

		1) cd "$(readlink -f "$(dirname "$cap")" )"
		   pwd
		   echo -e "\n\e[0;31mOutput filename : \e[0;34mPYRIT_$ssid\e[0;31m"
		   pyrit -o "$dir/PYRIT_$ssid" -i "$word" -e "$ssid" passthrough			# Pyrit
		   execution_time
		   echo -e "\nCracking will now begin: "
		   cowpatty -d "PYRIT_$ssid" -r "$cap" -s "$ssid";;
		
		2) echo -e "\n\e[0;31mOutput filename : \e[0;34mGENPMK_$ssid\e[0;31m"
		   genpmk -f "$word" -d "GENPMK_$ssid" -s "$ssid"					# genPMK
		   execution_time
		   echo -e "\nCracking will now begin: "
		   cowpatty -d "GENPMK_$ssid" -r "$cap" -s "$ssid";;

		*) clear
		   echo -e "\e[1;31mEnter a valid option"
		   start_fn "$@";;
	esac
}

time_fn()
{
	tm=$(expr $date_end - $date_start)
	if [ $tm -gt 60 -a $tm -lt 3600 ]; then
		echo "$(expr $tm / 60 ) Minutes "
	elif [ $tm -gt 3600 ]; then
		echo "$(expr $tm / 60 ) Hours"
	else
		echo "$tm Seconds"
	fi
}

#dot()
#{
#	echo -n . ; sleep 0.2
#	echo -n . ; sleep 0.2
#	echo -n . ; sleep 0.2
#}

trap clean_up 2
clean_up()
{
	#clear
	echo -e "\n\n\e[0;31m(^C) \e[0;34mExiting"
#	echo "Exiting..! " ;
#	echo -n 3 ; dot 
#	echo -n 2 ; dot
#	echo -n 1 ; sleep 0.5
#	echo -e "\n\e[1;34mBye.!\n"
	sleep 0.5
	exit
}

execution_time()
{
	date_end=$(date +%s)
	echo -e "\n \e[1;31mExecution time :  $(time_fn)"
	echo -e "\n\e[0;34m [*] Done!\e[0m"
}
####################MAIN FUNCTION####################
dir=$(pwd)
## Tools install check!

word="$1" ; cap="$2" ; ssid="$3"
dependepcies_check
start_fn "$@"
