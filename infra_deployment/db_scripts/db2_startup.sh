#!/bin/bash
# ------------------------------------------------------------
# db2_startup.sh
# DB2 startup script
# ------------------------------------------------------------

LOG="/tmp/db2_startup_$(date +%Y%m%d_%H%M%S).log"
log(){ echo "$(date '+%F %T') : $*" | tee -a "$LOG"; }

. $HOME/sqllib/db2profile

log "Starting DB2 instance"
db2start >> "$LOG" 2>&1 || exit 1

sleep 5

if pgrep -f db2sysc >/dev/null; then
  log "DB2 instance started successfully"
else
  log "ERROR: db2sysc not running"
  exit 2
fi

log "Listing DB directory"
db2 list db directory >> "$LOG" 2>&1

exit 0
