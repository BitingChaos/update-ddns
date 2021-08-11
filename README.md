# update-ddns

## Cloudflare DDNS Update Script

This updates a dynamic DNS entry on Cloudflare based the local IP address (IPv4 & IPv6).

**Note that this requires some setup before use!**

In Cloudflare, you need to get your Auth Key (for your account) and Zone ID (for the domain), then create a subdomain that you wish to update dynamically.

To get your Auth Key, go to My Profile > API Keys > **Global API Key**.

To get your Zone ID, click on the domain you want to use and go to Overview > API > **Zone ID**.

Add a DNS record (A and/or AAAA) and give it an IP address. Toggle Proxy status off ("DNS only").

Once you've done all the setup, update the script with your email address (EMAIL), dns record name (DDNSDOM), Global API Key (AUTHKEY) and Zone ID (ZONEID).

**Notes:**

This script relies on the domains "icanhazip.com" and "resolver1.opendns.com" for retrieving your IP address and looking up the existing DNS settings. If either site is down, this script may not work.

If Cloudflare changes their API for retreiving DNS ID or updating a domain, this script will probably break.

When running the script, it will simply give a "Success" or "Failed" message. You can append "1" on the end of the command (i.e. "update-ddns.sh 1") to see Cloudflare responses.

I have this script copied to my Raspberry Pi, with an entry like this this in my crontab:
```
# every 30 minutes, check IP / update DDNS
*/30 * * * * /usr/bin/chronic /opt/scripts/update-ddns.sh
```
