# pullMyBackups
pullMyBackups.sh is a Bash script for unattended pulling of multiple remote backups over SSH. It's designed to run with root privileges from a daily cronjob and pull multiple remote backups from multiple remote Linux servers.

For each backup set, a configuration file with a .conf extension must be created inside the conf.d subdirectory. See conf.d/example.conf.README for an example.

Dependencies: Bash, GNU coreutils, rsync, ssh, gzip. With some modifications, it should also work for other shells and/or systems.

Tested on: Debian GNU/Linux 8.4 amd64

## Cronjob setup for root
Suppose you extracted the pullMyBackups tar.gz file in "/opt/". First, give the script execute permissions:
```bash
# chmod +x /opt/pullMyBackups/pullMyBackups.sh
```

Now you can create a cronjob that will run every day at e.g. 4:00am with this one-liner:
```bash
# crontab -l | { cat; echo '00 4 * * * /opt/pullMyBackups/pullMyBackups.sh'; } | crontab -
```
