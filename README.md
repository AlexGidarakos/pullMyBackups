# pullMyBackups
pullMyBackups.sh is a Bash script for unattended pulling of multiple remote backups over SSH. It's designed to run with root privileges from a daily cronjob and pull multiple remote backups from multiple remote Linux servers.

For each backup set, a configuration file with a .conf extension must be created inside the conf.d subdirectory. See conf.d/example.conf.README for an example.

Dependencies: Bash, GNU coreutils, rsync, ssh, gzip. With some modifications, it should also work for other shells and/or systems.

Tested on: Debian GNU/Linux 8.4 amd64

## Key-based (password-less) SSH authentication for root
For unattended operation, you must configure both the local and the remote system appropriately.

On the local system:
```bash
# vi /root/.ssh/config
```

Example content of /root/.ssh/config. Change as needed:
```
# Add a remote host
Host server1
    HostName server1.example.com
    Port 51048
```

Again, on the local system:
```bash
# ssh-copy-id server1
# ssh server1
# exit
```

When you run the "ssh-copy-id" program, it will ask you the remote root password in order to login and send the local public key to the remote host. If you get a "Permission denied, please try again" error message, it's possible that the remote system is configured to only accept key-based SSH connections. Remember that you were just asked to enter a password, so this first connection attempt is in fact password-based. In this case, you must temporarily configure the remote system to accept password-based SSH connections, try the "ssh-copy-id" again and then revert your temporary changes.

## Cronjob setup for root
Suppose you extracted the pullMyBackups tar.gz file in "/opt/". First, give the script execute permissions:
```bash
# chmod +x /opt/pullMyBackups/pullMyBackups.sh
```

Now you can create a cronjob that will run every day at e.g. 4:00am with this one-liner:
```bash
# crontab -l | { cat; echo '00 4 * * * /opt/pullMyBackups/pullMyBackups.sh'; } | crontab -
```
