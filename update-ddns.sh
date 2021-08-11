#!/bin/bash

#
# Set dynamic DNS based on local IP (IPv4 & IPv6) in Cloudflare.
#
# NOTE: This requires some setup before use!
#
# You need to get your Auth Key (for account) and Zone ID (for domain), then create the subdomains.
#
# In Cloudflare:
# * get your Auth Key. This is under My Profile > API Keys > Global API Key.
# In Cloudflare, under the domain you want to use:
# * get your Zone ID. This is under Overview > API > Zone ID.
# * add a DNS entry (A and/or AAAA) and give it an IP address. Toggle Proxy status off ("DNS only").
#
# Notes:
# * This relies on the domains "icanhazip.com" and "resolver1.opendns.com" for
#   retrieving your IP address and looking up the existing DNS settings.
# * if Cloudflare changes their API, this script will probably break.
# * You can append "1" on end of command to see Cloudflare responses, i.e. "update-ddns.sh 1"
#
# 2021-08-11
# * switched script to bash
# * put some things into functions
# * now automatically gets domain id
# * add debug option to see responses (in case of errors)
# * updated notes
# * updated script formatting
#
# 2020-05-18
# * add toggles to enable/disable IPv4 or IPv6
#
# 2019-07-29
# * first version
# * updates both IPv4 and IPv6
#
# Nicholas Caito
# xenomorph@gmail.com
# http://xenomorph.net
#

# ----- Required Variables -----

# account email
EMAIL="your-email@example.com"

# domain name to update
DDNSDOM="your-domain.example.com"

# account auth key
AUTHKEY="abc123xxxYOURxxxAUTHKEYxxx123abc"

# zone id of domain
ZONEID="abc123xxxYOURxxxZONEIDxxx123abc"

# which to update (1=check)
UPDATE4=1
UPDATE6=1

# ----- System Variables -----

# show responses
DEBUG=$1
# echo command
E="/bin/echo -e"

# ----------

# get current, local IPv4 and IPv6 address
if [ $UPDATE4 = "1" ]; then
  CURRENTIP4=$(curl -s -4 https://icanhazip.com)
fi
if [ $UPDATE6 = "1" ]; then
  CURRENTIP6=$(curl -s -6 https://icanhazip.com)
fi

# check DNS for IPv4 and IPv6 address (doesn't work if domain name is proxied)
if [ $UPDATE4 = "1" ]; then
  DNSIP4=$(dig -4 +short $DDNSDOM A @resolver1.opendns.com)
fi
if [ $UPDATE6 = "1" ]; then
  DNSIP6=$(dig -6 +short $DDNSDOM AAAA @resolver1.opendns.com)
fi

# -----

update_ipv4() { # update IPv4

if [[ $UPDATE4 = "1" ]]; then
  $E "Current IPv4 Address: $CURRENTIP4"

  if [[ $CURRENTIP4 = "$DNSIP4" ]]; then
    $E "$DDNSDOM is already set to that IPv4 address in DNS. Skipping update."
  else

  $E -n "Getting IPv4 DNS ID for $DDNSDOM... "

  GETRECORDID4=`curl -w "\n" -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONEID/dns_records?name=$DDNSDOM&type=A" \
   -H "X-Auth-Email: $EMAIL" \
   -H "X-Auth-Key: $AUTHKEY" \
   -H "Content-Type: application/json"`

  RECORDID4=`$E $GETRECORDID4 | grep -oP '(?<="id":")[^"]*'`

  if [[ $DEBUG = "1" ]]; then
    $E "\n$GETRECORDID4\n"
  else
    $E "($RECORDID4)"
  fi

  $E -n "Updating IPv4 (A) address in Cloudflare: "

  DOUPDATEIPV4=`curl -w "\n" -s -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONEID/dns_records/$RECORDID4" \
   -H "X-Auth-Email: $EMAIL" \
   -H "X-Auth-Key: $AUTHKEY" \
   -H "Content-Type: application/json" \
   --data "{\"type\":\"A\",\"name\":\"$DDNSDOM\",\"content\":\"$CURRENTIP4\",\"proxied\":false}"`

  UPDATEIPV4=`$E $DOUPDATEIPV4 | grep -oP '(?<="success":)[^,"]*'`

  if [[ $DEBUG = "1" ]]; then
    $E "\n$DOUPDATEIPV4\n"
  else
    if [[ $UPDATEIPV4 = "true" ]] ; then
      $E "Success!"
    else
      $E "FAILED!"
    fi
  fi

  fi # end check if ip is already in dns
fi # end if ip update check

} # end update_ipv4()


update_ipv6() { # update IPv6

if [[ $UPDATE6 = "1" ]]; then
  $E "Current IPv6 Address: $CURRENTIP6"

  if [[ $CURRENTIP6 = "$DNSIP6" ]]; then
    $E "$DDNSDOM is already set to that IPv6 address in DNS. Skipping update."
  else

  $E -n "Getting IPv6 DNS ID for $DDNSDOM... "

  GETRECORDID6=`curl -w "\n" -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONEID/dns_records?name=$DDNSDOM&type=AAAA" \
   -H "X-Auth-Email: $EMAIL" \
   -H "X-Auth-Key: $AUTHKEY" \
   -H "Content-Type: application/json"`

  RECORDID6=`$E $GETRECORDID6 | grep -oP '(?<="id":")[^"]*'`

  if [[ $DEBUG = "1" ]]; then
    $E "\n$GETRECORDID6\n"
  else
    $E "($RECORDID6)"
  fi

  $E -n "Updating IPv6 (AAAA) address in Cloudflare: "

  DOUPDATEIPV6=`curl -w "\n" -s -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONEID/dns_records/$RECORDID6" \
   -H "X-Auth-Email: $EMAIL" \
   -H "X-Auth-Key: $AUTHKEY" \
   -H "Content-Type: application/json" \
   --data "{\"type\":\"AAAA\",\"name\":\"$DDNSDOM\",\"content\":\"$CURRENTIP6\",\"proxied\":false}"`

  UPDATEIPV6=`$E $DOUPDATEIPV6 | grep -oP '(?<="success":)[^,"]*'`

  if [[ $DEBUG = "1" ]]; then
    $E "\n$DOUPDATEIPV6\n"
  else
    if [[ $UPDATEIPV6 = "true" ]] ; then
      $E "Success!"
    else
      $E "FAILED!"
    fi
  fi

  fi # end check if ip is already in dns
fi # end if ip update check

} # end update_ipv6()

update_ipv4;

update_ipv6;

# EoF
