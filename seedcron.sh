#!/bin/bash
# Add a cron which automatically restarts this sQuorum Seeder every 48 hours
# Add the following to the crontab (i.e. crontab -e)
# (crontab -l ; echo "30 */48 * * * /root/squorum-seeder/seedcron.sh") | crontab -
# @reboot /root/squorum-seeder/seedcron.sh 

# add logging to check if cron is working as planned
echo -e "`date +%m.%d.%Y_%H:%M:%S` : Executing seedcron.sh (every 2 days, cron) \n"  | tee -a /root/squorum-seeder/seedcron.log

# clear out all but the last 50 log entries
# count number of lines in the file, save to variable
LINES=$(wc -l /root/squorum-seeder/seedcron.log | awk '{ print $1 }')
# determine how many lines to remove
EXTRA=$(( $LINES - 50 ))
# delete range of lines 1 through difference above
if (( $EXTRA >= 1 ))
then sed -i "1,${EXTRA}d" /root/squorum-seeder/seedcron.log
fi

# identify and kill running task 'dnsseed' then pause for 2 seconds
kill $(ps aux | grep '[d]nsseed' | awk '{print $2}')
sleep 2

# restart dns-seeder binary
sudo /root/squorum-seeder/dnsseed -h sqrseed.nodevalet.io -n squorum.nodevalet.io -p 53 -m akcryptoguy@gmail.com

# first step is we need to identify if dnsseed is running
# ps -a | grep dnsseed

# second step is we kill it the dnsseed if it is already running
#kill $(ps aux | grep '[d]nsseed' | awk '{print $2}')

// not sure; maybe this would work better?
nano /etc/systemd/system/seed.service

[Unit]
Description=sQuorum dns seeder
After=network.target

[Service]
WorkingDirectory=/root/squorum-seeder
ExecStart=/root/squorum-seeder/dnsseed -h sqrseed.nodevalet.io -n squorum.nodevalet.io -p 53 -m akcryptoguy@gmail.com
Restart=on-failure
RestartSec=10
User=root
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=squorum-seeder

[Install]
WantedBy=multi-user.target

save & exit
systemctl daemon-reload
systemctl enable seed
systemctl start seed
//