#!/bin/bash


iptables -F
iptables -X
iptables -Z
#-----------------------------------------------------------------------------------------------
iptables -P INPUT DROP
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -A OUTPUT -p icmp -j ACCEPT
#iptables -A INPUT -p icmp -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -p all -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p all -s 10.1.0.0/16 -j ACCEPT
iptables -t nat -A POSTROUTING -s 10.1.0.0/16 -j MASQUERADE
iptables -A INPUT -s 118.174.30.242/32 -j ACCEPT
iptables -A INPUT -s 54.254.162.90/32 -p tcp --dport 22 -j ACCEPT
#-----------------------------------------------------------------------------------------------

