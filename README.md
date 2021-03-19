# suricata-utils
<br>
This project contains documentation and scripts to manage Suricata, alongside with a script to automatize the configuration process and a script modified from https://github.com/chrisjd20/Snorpy/blob/5d2d30cf7751a59c44ddcc197ec31ffbbc2602af/snorpy.py to ease the creation of Suricata rules. It is mainly aimed towards the use of Suricata in IPS mode. <br>
<br>
--<br>
Install Suricata:<br>
For apt based systems (like Ubuntu), use the script install_suricata_from_apt.sh<br>
On Fedora, just use dnf install suricata<br>
If you have special requirements, use install_suricata_from_source_code.sh<br>
-- <br>
Configure some Suricata folders and "emerging threats" alerts:<br>
Use configure_suricata.sh script, it basically runs suricata-update; if suricata-update is not installed, comment suricata-update line and uncomment the other lines.<br>
--<br>
After installation and after suricata-update, use config_suricata.py after having configured your suricata_conf.json (most times you can keep default values; the python script takes 2 or 3 parameters: the full path of the yaml file to modify, the json configuration file, and optionally a "backup" filename path to store the old values of the yaml) OR open suricata.yaml ( /etc/suricata/suricata.yaml ) and do the configuration manually (NOTE: config_suricata.py won't do the last point in the following list, to avoid overwriting):<br>
- Configure IP configuration (HOME_NET, EXTERNAL_NET can be kept default or set to any but more accurate means more performance)<br>
- Configure ports configuration (HTTPS_PORTS, SHELLCODE_PORTS can be set to !22)<br>
- Enable http-log (enabled: no -> enabled: yes)<br>
- Make sure pcap-log is disabled (it would occupy too much space, we're going to use Suricata as IPS)<br>
- Enable drop (enabling it doesn't put Suricata in IPS mode, it's just to make Suricata log dropped packets when in IPS mode)<br>
- In unix-command, set enabled: yes (needed to make the socket active, in order to reload suricata rules dynamically)<br>
- Make sure 'stream' options in advanced settings' section have these values: memcap > 32mb, checksum-validation yes, inline yes.<br>
- Check default-rule-path, and to rule-files add in a new indented line 'local.rules' (you will need to create this file in the directory specified as default-rule-path; suricata.rules is only for alerts)<br>
- Create local.rules file in the directory specified by default-rule-path (usually /etc/suricata/rules or /var/lib/suricata/rules)<br>
--<br>
Add rules:<br>
Just append one or more rules to local.rules file you created before.<br>
Example: drop tcp any any -> any any (msg:"facebook is blocked"; content:"facebook.com"; http_header; nocase; classtype:policy-violation; sid:1;)<br>
Another (test with Python SimpleHTTPServer on port 8000): drop http any any -> $HOME_NET 8000 (msg:"python requests is blocked"; content:"python-requests"; http_user_agent;)<br>
Test this one with: curl --user-agent "python-requests" url<br>
Note: SimpleHTTPServer hangs if packet is dropped (you will think that it's going to drop all the other packets; just hit Ctrl-C to make it work as usual, because it doesn't handle exceptions as web frameworks do, it just uses sockets).<br>
--<br>
Configure crontab before configuring the firewall (i.e. before starting Suricata in IPS mode):<br>
crontab -e<br>
Add this line:<br>
*/2 * * * * <path>/check_suricata_run_reset_fw.sh >/dev/null 2>&1<br>
It will check that Suricata is up every 2 minutes, and if Suricata isn't up, it will flush iptables.<br>
Look at crontab log: grep CRON /var/log/syslog<br>
Look at installed crontabs: crontab -l<br>
Warning: check SHELL and PATH variables in /etc/crontab<br>
Very important warning: as from the following paragraph, you have to check if you have iptables on your system; if this is not the case, you have to check your equivalent, and modify check_suricata_run_reset_fw.sh with another command to reset the firewall. Anyway, if you don't have iptables, probably you have ufw.<br>
--<br>
Start Suricata (WARNING: your SSH connection could hang):<br>
Run suricata_IPS.sh script, it will issue two iptables commands and then start Suricata daemon; again, if you don't have iptables on your system, check your equivalent: you have to create two NFQUEUE both with number 0, one for INPUT and the other one for OUTPUT.<br>
--<br>
Stop Suricata (WARNING: not necessary for the reloading of rules):<br>
Run stop_suricata.sh script, it will read the PID of Suricata process and kill it, remove a running Suricata file (if you don't remove that file, you won't be able to restart Suricata) and flush iptables.<br>
--<br>
Reload rules:<br>
Run reload_rules.sh script, it will use suricatasc Python module to communicate with Suricata socket.<br>
--<br>
Check logs:<br>
/var/log/suricata/suricata.log<br>
/var/log/suricata/stats.log<br>
/var/log/suricata/http.log<br>
/var/log/suricata/drop.log<br>
/var/log/suricata/fast.log<br>
