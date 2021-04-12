# suricata-utils
<br>
This project contains documentation and scripts to manage Suricata, alongside with a script to automatize the configuration process and a script modified from https://github.com/chrisjd20/Snorpy/blob/5d2d30cf7751a59c44ddcc197ec31ffbbc2602af/snorpy.py to ease the creation of Suricata rules. It is mainly aimed towards the use of Suricata in IPS mode. <br>
<br>
Install Suricata:

```
For apt based systems (like Ubuntu), use the script install_suricata_from_apt.sh
On Fedora, just use dnf install suricata
If you have special requirements, use install_suricata_from_source_code.sh
```
Configure some Suricata folders and "emerging threats" alerts:
```
Use configure_suricata.sh script, it basically runs suricata-update; if suricata-update is not installed, comment suricata-update line and uncomment the other lines.
```
After installation and after suricata-update, use config_suricata.py after having configured your suricata_conf.json (most times you can keep default values; the python script takes 2 or 3 parameters: the full path of the yaml file to modify, the json configuration file, and optionally a "backup" filename path to store the old values of the yaml) OR open suricata.yaml ( /etc/suricata/suricata.yaml ) and do the configuration manually (NOTE: config_suricata.py won't do the last point in the following list, to avoid overwriting):
```
- Configure IP configuration (HOME_NET, EXTERNAL_NET can be kept default or set to any but more accurate means more performance)
- Configure ports configuration (HTTPS_PORTS, SHELLCODE_PORTS can be set to !22)
- Enable http-log (enabled: no -> enabled: yes)
- Make sure pcap-log is disabled (it would occupy too much space, we're going to use Suricata as IPS)
- Enable drop (enabling it doesn't put Suricata in IPS mode, it's just to make Suricata log dropped packets when in IPS mode)
- In unix-command, set enabled: yes (needed to make the socket active, in order to reload suricata rules dynamically)
- Make sure 'stream' options in advanced settings' section have these values: memcap > 32mb, checksum-validation yes, inline yes.
- Check default-rule-path, and to rule-files add in a new indented line 'local.rules' (you will need to create this file in the directory specified as default-rule-path; suricata.rules is only for alerts)
- Create local.rules file in the directory specified by default-rule-path (usually /etc/suricata/rules or /var/lib/suricata/rules)
```
Add rules:
```
Just append one or more rules to local.rules file you created before.
Example: drop tcp any any -> any any (msg:"facebook is blocked"; content:"facebook.com"; http_header; nocase; classtype:policy-violation; sid:1;)
Another (test with Python SimpleHTTPServer on port 8000): drop http any any -> $HOME_NET 8000 (msg:"python requests is blocked"; content:"python-requests"; http_user_agent;)
Test this one with: curl --user-agent "python-requests" url
Note: SimpleHTTPServer hangs if packet is dropped (you will think that it's going to drop all the other packets; just hit Ctrl-C to make it work as usual, because it doesn't handle exceptions as web frameworks do, it just uses sockets).
```
(Optional) Configure crontab before configuring the firewall (i.e. before starting Suricata in IPS mode):
```
crontab -e
Add this line:
*/2 * * * * <path>/check_suricata_run_reset_fw.sh >/dev/null 2>&1
It will check that Suricata is up every 2 minutes, and if Suricata isn't up, it will flush iptables' NFQUEUE chain.
Look at crontab log: grep CRON /var/log/syslog
Look at installed crontabs: crontab -l
Warning: check SHELL and PATH variables in /etc/crontab
Very important warning: as from the following paragraph, you have to check if you have iptables on your system; if this is not the case, you have to check your equivalent, and modify check_suricata_run_reset_fw.sh with another command to reset the firewall. Anyway, if you don't have iptables, probably you have ufw.
```
Start Suricata (WARNING: your SSH connection could hang):
```
Run safe_suricata_IPS.sh script, it will start Suricata daemon and then it will use iptables-apply to safely create NFQUEUE chain (reading from nfq_drop.rules), with a timeout of 30 seconds; again, if you don't have iptables on your system, check your equivalent: you have to create two NFQUEUE both with number 0, one for INPUT and the other one for OUTPUT.
If you want to do some tests on your VM, keep in mind that you need to make requests from another host in order to make Suricata drop them: Suricata will not drop on localhost (this is probably related to iptables, not to Suricata).
```
Stop Suricata (WARNING: not necessary for the reloading of rules):
```
Run stop_suricata.sh script, it will read the PID of Suricata process and kill it, remove a running Suricata file (if you don't remove that file, you won't be able to restart Suricata) and flush iptables.
```
Reload rules:
```
Run reload_rules.sh script, it will use suricatasc Python module to communicate with Suricata socket.
```
Check logs:
```
/var/log/suricata/suricata.log
/var/log/suricata/stats.log
/var/log/suricata/http.log
/var/log/suricata/drop.log
/var/log/suricata/fast.log
```
To make some operations easier, avoiding the SSH login on the server for some operations, there are 3 utility scripts:
```
copy_remote.sh is to copy the folder containing scripts for Suricata installation, management and configuration.
grep_logs.sh is to download the folder containing all logs.
upload_rules.sh is to let you edit local.rules file locally, then upload it to the server and reload the rules without requiring you to do it manually (you just have to run the script after updating local.rules).
There is a plot twist about upload_rules.sh: you may need root privileges to do the SCP of local.rules to the remote host; in this case, pass "root" as user parameter to the script.
```
