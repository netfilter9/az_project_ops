# SOURCE SYSTEM – BACKUP PROCEDURE
# Verify database status and archive logging:
db2 connect to <DBNAME>
db2 get db cfg for <DBNAME> | grep LOGARCH

# Take online database backup (recommended):
db2 backup db <DBNAME> online to /db2backup compress include logs

# Validate backup image:
db2ckbkp /db2backup/*.001

# TARGET SYSTEM – RESTORE PROCEDURE
# Start DB2 instance:
db2start

# Restore database:
db2 restore db <DBNAME> from /db2backup

# If restoring to custom paths, use redirected restore:
db2 restore db <DBNAME> from /db2backup redirect generate script restore_redirect.sql

# Edit restore_redirect.sql to map data and log paths, then execute:
db2 -tvf restore_redirect.sql

# Rollforward & Activation
# Rollforward database to end of logs:
db2 rollforward db <DBNAME> to end of logs and stop

# Activate database:
db2 activate db <DBNAME>

# POST-RESTORE CONFIGURATION
# Update log archive method for Azure (example filesystem-based):
db2 update db cfg for <DBNAME> using LOGARCHMETH1 DISK:/db2arch

# Verify database configuration:
db2 get db cfg for <DBNAME>

# COMMANDS FOR VALIDATION
# OS-level (run as root)
hostname
cat /etc/os-release
uname -a
cat /etc/security/limits.conf
lsblk
df -hT
mount
cat /etc/fstab
ip a

# DB2-level (as DB2 instance owner)		
db2level
db2ls
db2set -all
db2 get dbm cfg
db2 list db directory
db2 get db cfg for <DBNAME>