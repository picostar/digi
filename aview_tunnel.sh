


# workaround for devices on firmware 18.4.54.22 or lower to log their primary
# WAN interface to aView when they have a mgmt priority set

send_mgmt_intf_update() {
  ubus call eventd reset
  action reload accns_status_ipsec
}

reset_tunnel() {
  accns_log w config "custom: aView IPSec tunnel dropping incoming traffic. Restarting tunnel..."
  cat /var/log/messages > /var/log/messages.0
  echo '' > /var/log/messages
  /sbin/ipsec stop
  sleep 5
  /sbin/ipsec start
  sleep 10
  accns_log w config "custom: aView IPSec tunnel restarted"
  send_mgmt_intf_update
}

send_mgmt_intf_update


# workaround for a rare issue where the device doesn't update it's local
# tunnel IP address, resulting in device dropping incoming packets from the
# aView tunnel IPSec server

ip_addr_string='[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}'
dropped_tunnel_dst=$(grep -m 1 "DROP.*SRC=192.168.211.50" /var/log/messages | grep -o "$ip_addr_string" | cut -f2 -d'=')
aview_tunnel_ip=$(/sbin/ipsec status | grep -om1 "aview.*$ip_addr_string ===" | grep -o "$ip_addr_string")

route_exists='y' #assume the route is there, then check
[ "$aview_tunnel_ip" ] && ! ip addr | grep -q "$aview_tunnel_ip" && route_exists='n'
if [ "$route_exists" = 'n' ]; then
  accns_log w config "custom script resetting aView tunnel due to missing route"
  reset_tunnel
fi

if [ -n "$dropped_tunnel_dst" ] && [ "$dropped_tunnel_dst" = "$aview_tunnel_ip" ]; then
  accns_log w config "custom script resetting aView tunnel due to mismatched local tunnel IP"
  reset_tunnel
fi

# adjust MTU of aView tunnel traffic for cellular overhead
cell_aview_route=$(ip route | grep "192.168.211.50.*dev wwan" | sed 's/mtu.*//g')
if [ "$cell_aview_route" !=  '' ]; then
  ip route change $cell_aview_route mtu 1318
  iptables -t mangle -I INPUT -p tcp --tcp-flags SYN,RST SYN -m tcpmss --mss 1319:1536 -j TCPMSS --set-mss 1318
fi


