#! /usr/bin/env bash

usage ()
{
	printf "ilf - I lost (a) file\n"
	echo   "---------------------"
	printf "Use ilf to find files which were created in a specific time window.\n\n"

	printf "Available commands: \n"
	printf "\t -f, --folder:\t\tSpecify the folder to search.\n"
	printf "\t\t\t\tIf not specified, searches current folder.\n"

	printf "\t -s, --start-date:\tOnly lists files newer than the start date.\n"
	printf "\t\t\t\tFormat must be DD MMM YYYY (e.g. 01 jan 2021).\n"

	printf "\t -e, --end-date:\tOnly lists files older than the end date.\n"
	printf "\t\t\t\tFormat is the same as for the start date.\n"

	printf "\t -r, --regex:\t\tUse regex expression to filter files.\n"
	printf "\t\t\t\te.g. *.csv will only list files with csv file extension.\n"

	printf "\t -h, --help:\t\tList available arguments.\n"

	echo "Examples:"
	echo "* Find all files in all sub-folders of /home/user/Documents created in august 2021"
	printf "\t$ ./ilf -f /home/user/Documents -s \"01 aug 2021\" -e \"31 aug 2021\"\n\n" 

	echo "* Find all jupyter notebooks." 
	printf "\t$ ./ilf -f / -r *.ipynb"

	printf "\n(c) Christoph Fischer, 2021\n\n"
}

# User input variables
START_DATE=
END_DATE=
FOLDER=$PWD
REGEX=

# Parse command line input
while [[ "$1" != "" ]]; do
	case $1 in
		-f | --folder )		shift
					FOLDER=$1 # Read folder name
					;;
		-s | --start-date )	shift
					START_DATE=$1 # Read start date
					;;
		-e | --end-date )	shift
					END_DATE=$1 # Read end date
					;;
		-r | --regex )		shift
					REGEX=$1 # Read regex expression 
					;;
		-h | --help )		usage
					exit -1
					;;
		* )			echo "Unknown command ${1}"
					exit -1
	esac
	shift
done

# Ask user if no command line input is present
if [[ ! $START_DATE && ! $END_DATE && ! $REGEX ]]; then
	echo "Entering interactive mode. Use -h to list all possible commands."
	printf "\n"

	echo "Which folder do you want to search? (hit enter to search the current folder)"
	read FOLDER

	if [[ ! $FOLDER ]]; then
		echo "Searching current folder."
		FOLDER=$PWD
	fi


	echo "Please enter the start date for the search (hit Enter to not set a start date)"
	echo "The date must have the format DD MMM YYYY (e.g. 01 jan 2021)"
	read START_DATE

	if [[ ! $START_DATE ]]; then
		echo "No start date set."
	fi


	echo "Please enter the end date for the search (hit Enter to not set an end date)"
	read END_DATE

	if [[ ! $END_DATE ]]; then
		echo "No end date set."
	fi


	echo "Do you want to filter for some file type? (hit Enter to list all files)"
	read REGEX
	
	if [[ ! $REGEX ]]; then
		echo "Listing all files."
	fi

fi

# Decide what file to look for
echo "Searching in ${FOLDER}"
if [[ $START_DATE && $END_DATE ]]; then
	# Normal search
	find $FOLDER -type f -newermt "$START_DATE" -and ! -newermt "$END_DATE" -regex ".*$REGEX" 2>/dev/null
elif [[ $START_DATE &&  ! $END_DATE ]]; then
	# Only start date but no end date
	find $FOLDER -type f -newermt "$START_DATE" -regex ".*$REGEX" 2>/dev/null
elif [[ ! $START_DATE && $END_DATE ]]; then
	# Only end date but no start date
	find $FOLDER -type f ! -newermt "$END_DATE" -regex ".*$REGEX" 2>/dev/null
else
	echo "Warning no start and end date were given."
	find $FOLDER -type f -regex ".*$REGEX" 2>/dev/null
fi
