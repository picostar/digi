#!/bin/sh
# log all of the current modem's details in one syslog
idx="$(modem idx)"
[ -n "$idx" ] || idx=0
log_message='modem_log_type=custom'
# get modem/SIM info (maker, model, iccid, etc.)
#   on 18.1 or lower firmware, use this instead:
#   for keypair in $(runt dump network.modem.$idx.modem); do
for keypair in $(runt dump mm.modem.$idx.modem); do
  log_message="$log_message~$keypair"
done
# get modem status details (rssi, rsrp, band, etc.)
#  on 18.1 or lower firmware, use this instead:
#  for keypair in $(runt dump network.modem.$idx.status); do
for keypair in $(runt dump mm.modem.$idx.status); do
  log_message="$log_message~$keypair"
done
# add duration of the active modem connection and the current date/time
bearer="$(modem cli | grep -o "Bearer\/.*" | cut -f2 -d '/' | tr -d ",' ")"
if [ -n "$bearer" ]; then
  duration="$(modem cli -b "$bearer" | grep -i 'duration' | cut -f2 -d':' | cut -f2 -d"'")"
  log_message="$log_message~duration=$duration"
fi
# add config interface name and date
bidx=$(runt keys mm.bearer | head -n 1)
[ -n "$bidx" ] && config=$(runt get mm.map.bidx.$bidx)
[ -n "$config" ] || config=$(runt get mm.map.idx.$idx)
log_message="$log_message~${config:+config=$config~}~date=$(date)"
accns_log w modem "$log_message"



iptables -I FORWARD -p icmp --icmp-type 20 -j ACCEPT
iptables -I FORWARD -p icmp --icmp-type 21 -j ACCEPT

# adjust MTU of aView tunnel traffic for cellular overhead
cell_aview_route=$(ip route | grep "192.168.211.50.*dev wwan" | sed 's/mtu.*//g')
if [ "$cell_aview_route" !=  '' ]; then
  ip route change $cell_aview_route mtu 1318
  iptables -t mangle -I INPUT -p tcp --tcp-flags SYN,RST SYN -m tcpmss --mss 1319:1536 -j TCPMSS --set-mss 1318
fi