# Multicron: enabling multiple user crontab files

By default each user on a Linux system has one crontab file.
If a user enables a new crontab file through the `crontab` command,
the cron instructions in the old crontab file are dropped.
This script enables users to have multiple crontab files.

## Installation

Download `multicron.sh` to your machine and make it executable:
```
$ chmod +x multicron.sh
```
You may consider placing multicron in one of the directories given by your `$PATH` variable 
(run `echo $PATH` at the command prompt) so that you can use multicron by
just typing `multicron.sh` regardless of the directory you are in.

## Usage

Crontab files are either *active* or *innactive*.
When a crontab file is active, the instructions inside will be executed by Cron.
To activate a crontab file, type:

```
$ multicron.sh activate <path to file>
```

To deactivate a crontab file, execute:

```
$ multicron.sh deactivate <path to file>
```

If you make changes to an already active crontab file, it is necessary to restart multicron
in order for those changes to be seen by cron:
```
$ multicron.sh restart
```

Note that if you run an `activate` or `deactivate` command, multicron is automatically restarted.

## How it works

The multicron script uses two files stored in `~/.multicron/`.

The file `crontabs.lst` contains a list of absolute paths to the crontab files you have activated.
Activating a new crontab involves appending the absolute path of the crontab to this file (if needed); while
deactivating a crontab involves removing the absolute path of the crontab from this file (if it's present).

The second file is `merged.crontab`.
When multicron restarts, it adds the contents of each file listed in `crontabs.lst` to this file.
It then involves the `crontab` command on `merged.crontab`.

