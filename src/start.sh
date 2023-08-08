echo "Setting $CRON cron to run" >> "/var/log/simple-gdrive-backups.log"

echo "$CRON /backup-runner.sh >> /var/log/simple-gdrive-backups.log" > /etc/crontabs/root 
crontab /etc/crontabs/root 
touch /var/log/cron.log

crond && tail -f "/var/log/simple-gdrive-backups.log"
# tail -f /var/log/cron.log
