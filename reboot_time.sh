#!/bin/sh

# supported on firmware 17.8.128.63+

# set as a scheduled task to run on boot

sleep 5400 # system fires this script at boot, so start the countdown when the script is called
reboot_managed /sbin/reboot 'custom 30-min reboot'
sleep 60
flatfsd -b # hard reboot in case the reboot_managed call above fails
