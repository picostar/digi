
#!/bin/sh

# Minimum firmware version: 17.5.108.6

# Test the LAN connection with a ping test.  Keep a count of failed tests.
# If this test fails for four times in a row, then reset the LAN interface

# Adjustable settings
fail_count_file='/tmp/custom_cell_test_fail_count.txt'  # local file that stores the number of consecutive failed tests
fail_count_limit='4'                                    # number of concurrent failures that can occur before resetting
fail_count_limit='8'                                    # number of concurrent failures that can occur before rebooting


test_failed() {
  try=$((try+1))
  echo "$try" > "$fail_count_file"
  accns_log w config "custom: LAN test failed ($1 - try $try)"
}


test_passed() {
  rm -f "$fail_count_file"
  try=0
  # Note: uncomment the following line if you want to log successful tests
  #accns_log w config "custom: LAN test to $1 passed"
}


try=$(cat "$fail_count_file" 2> /dev/null) try=${try:-0}


# make sure $try is an integer. set to zero if not case $try in
  ''|*[!0-9]*)
    try=0
    ;;
esac


# do the connectivity test
lan_ip_addr="$(runt get network.interface.lan.ipv4.address)"
lan_interface="$(runt get network.interface.lan.device)"

# Skip the test if we don't have a LAN IP address if [ "$lan_ip_addr" = '' ]; then
  test_passed "no LAN IP address to ping"
  exit
fi

if ping -q -c 1 -W 10 -s 1 "$lan_ip_addr" > /dev/null; then
  test_passed "$lan_ip_addr"
elif [ "$lan_interface" != '' ]; then
  ip link set dev "$lan_interface" up
  sleep 3
  if ping -q -c 1 -W 10 -s 1 "$lan_ip_addr" > /dev/null; then
    test_passed "$lan_ip_addr"
  else 
    test_failed "ping failure to $lan_ip_addr"
  fi
else
  test_failed "ping failure to $lan_ip_addr with no LAN link"
fi


# reset if failed test count is greater than specified limit if [ "$try" -ge "$fail_count_limit" ]; then
  # note, that we don't reset the fail count. If we fail next attempt, try to reset again.
  config set network.interface.lan.enable false
  sleep 5
  config set network.interface.lan.enable true fi

# reboot if failed test count is greater than specified limit2 if [ "$try" -ge "$fail_count_limit2" ]; then
  # note, that the reboot clears out the counter for failed consecutive tests
  sleep 5
  reboot_managed /sbin/reboot "custom LAN test failed"
fi



# notes
# cat /etc/config/dhcp.leases
# config set network.interface.lan.enable false
# 