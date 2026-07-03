#!/bin/bash
# ------------------------------------------------------------
# db2_stop_safe.sh
# Simplified DB2 instance stop:
# - If ANY database is active OR ANY connections exist -> EXIT (do nothing)
# - Else -> db2stop
#
# Run as DB2 instance owner.
# ------------------------------------------------------------

set -o pipefail

LOG="/tmp/db2_stop_safe_$(date +%Y%m%d_%H%M%S).log"

log() { echo "$(date '+%F %T') : $*" | tee -a "$LOG"; }

# Load db2profile if needed
if ! command -v db2 >/dev/null 2>&1; then
  if [[ -f "${HOME}/sqllib/db2profile" ]]; then
    # shellcheck disable=SC1090
    . "${HOME}/sqllib/db2profile"
  fi
fi

if ! command -v db2 >/dev/null 2>&1; then
  echo "ERROR: db2 command not found. Run as instance owner and source db2profile."
  exit 1
fi

log "============================================================"
log "DB2 Stop If Idle - START"
log "User: $(id -un)  Host: $(hostname -f 2>/dev/null || hostname)"
log "Log : ${LOG}"
log "============================================================"

# If db2sysc not running, nothing to stop
if ! pgrep -f "db2sysc" >/dev/null 2>&1; then
  log "db2sysc not running. Instance appears already stopped. Exiting."
  exit 0
fi

# 1) Check active databases
log "[CHECK] Active databases:"
ACTIVE_RAW="$(db2 list active databases 2>&1)"
echo "$ACTIVE_RAW" | tee -a "$LOG"

if echo "$ACTIVE_RAW" | grep -qE "Database name[[:space:]]+=[[:space:]]+"; then
  log "Active database(s) detected. Will NOT stop instance."
  exit 2
fi

# 2) Check active connections (instance-wide)
log "[CHECK] Active applications / connections:"
APPS_RAW="$(db2 list applications 2>&1)"
echo "$APPS_RAW" | tee -a "$LOG"

if echo "$APPS_RAW" | grep -qi "Application handle"; then
  log "Active connection(s) detected. Will NOT stop instance."
  exit 3
fi

# 3) Stop DB2
log "[STOP] No active DBs and no active connections. Running: db2stop"
db2stop 2>&1 | tee -a "$LOG"
RC=${PIPESTATUS[0]}

if [[ $RC -ne 0 ]]; then
  log "ERROR: db2stop returned non-zero exit code: $RC"
  exit $RC
fi

log "SUCCESS: DB2 instance stopped."
exit 0
