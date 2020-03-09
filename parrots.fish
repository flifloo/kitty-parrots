#!/bin/fish
set path /tmp/ 
set sock parrot
if [ -n "$argv" ]
	if [ $argv[1] = "-h" ] || [ $argv[1] = "--help" ]
		echo "HALP !"
		exit 0
	else if [ $argv[1] = "-b" ] || [ $argv[1] = "--background" ]
		set -e argv[1]
		parrots $argv &
		exit 0;
	else if [ $argv[1] = "-d" ] || [ $argv[1] = "--delete" ]
		eval "echo 1 > {$path}{$sock}_kill"
		exit 0;
	end
end

argparse --name=parrots -x "s,l" "c/current" "s/sleep=" "l/lock" "i/instant" "n/number=" "d-debug" -- $argv
if [ -n "$_flag_lock" ]
	xtrlock &
end
if [ -n "$_flag_number" ]
	set num $_flag_number
else
	set num 6
end

if [ -n "$_flag_debug" ]
	set debug ""
else
	set debug "> /dev/null 2> /dev/null"
end

eval "rm $path$sock $debug"
if [ -n "$_flag_current" ]
	end
end

eval "kitty @ $listen goto-layout Grid $debug"
for i in (seq 2 $num)
	eval "kitty @ $listen new-window --title parrot$i terminal-parrot $debug"
end

if [ -n "$_flag_lock" ]
	while [ (jobs | grep xtrlock) ]
		sleep 0.2
	end
else if [ -n "$_flag_sleep" ]
	sleep $_flag_sleep
else
	while [ ! -f {$path}{$sock}_kill ]
		sleep 0.1
	end
	eval "rm {$path}{$sock}_kill $debug"
end

for i in (seq $num -1 1)
	eval "kitty @ $listen close-window -m title:parrot$i $debug"
end
exit 0
