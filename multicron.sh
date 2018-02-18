#!/bin/bash

# The shell script requires two files on disk, stored in hidden directory in the user directory.
mkdir -p ~/.multicron
# The lst file contains absolute paths to each of the user's crontab file.
lstfile=~/.multicron/crontabs.lst
touch ~/.multicron/crontabs.lst
# The merged crontab file contains all of the user's crontab files merged together.
# This file is created after a restart command.
crontabfile=~/.multicron/merged.crontab

# Check that a command was passed in the command line arguments.
# If not, exit with failure.
if [ $# -eq 0 ]
then
	echo "Error: expected command in first argument."
	echo "Command must be one of: activate <file_path>, deactivate <file_path>, restart."
	exit 1
fi

# Read in the command
command=$1

# In the case of an activate or deactivate command, a valid file is required to be passed as
# an extra command line argument. Check this first.
if [ $command = "activate" ] || [ $command = "deactive" ]
then
	# First check something was passed.
	if [ $# -eq 1 ]
	then
		echo "Error: command $command requires a file to be passed as an argument."
		echo "Usage: $command <file_path>."
		exit 1
	fi
	# Then check that what was passed is a file that exists and that the user can read.
	if [ ! -r $2 ]
	then
		echo "Error: $2 is not a file or you do not have permission to read it."
		exit 1
	fi
fi

# Execute the relevant command.

if [ $command = "activate" ]
then
	abspath=`realpath $2`
	# Check if the file is already in the list of crontabs; if not, add it.
	if grep -Fxq "$abspath" $lstfile
	then
		echo "Crontab file $abspath is already active."
	else
		echo "$abspath" >> ~/.multicron/crontabs.lst
		echo "Crontab file $abspath activated."
	fi
	# After adding the crontab file, restart the master crontab.
	command="restart"
fi

if [ $command = "deactivate" ]
then
	abspath=`realpath $2`
	# Check if the file is already in the list of crontabs; if it is, remove it.
	if grep -Fxq "$abspath" $lstfile
	then
		sed -i "\:$abspath:d" $lstfile
		echo "Crontab file $abspath deactivated."
	else
		echo "Crontab file $abspath is already inactive."
	fi
	# After removing the crontab file, restart the master crontab.
	command="restart"
fi

if [ $command = "restart" ]
then
	echo "Restarting the master crontab."
	# Reset the master crontab file.
	echo "" > $crontabfile
	# Iterate through each file name in the lst file.
	while read line; do
		# If the user can read the file, place it in the master file.
		if [ -r $line ]
		then
			echo "# Original file: $line" >> $crontabfile
			cat $line >> $crontabfile
			echo "" >> $crontabfile
			echo "Added $line to master crontab file."
		# Otherwise remove it from the list.
		else
			echo "File $line does not exist or you do not have permission to read it; removing."
			sed -i "\:$line:d" $lstfile
		fi
	done < $lstfile
	# Run crontab and exit.
	crontab $crontabfile
	echo "Ran crontab on master crontab file $crontabfile."
	echo "Done"
	exit 0
fi

# If we got this far, a valid argument must not have been passed.
echo "Error: unknown command '$1'."
echo "Command must be one of: activate <file_path>, deactivate <file_path>, restart."
exit 1
