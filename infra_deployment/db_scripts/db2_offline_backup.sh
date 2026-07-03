#!/bin/bash
# ------------------------------------------------------------
# db2_offline_backup.sh
# DB2 Offline Backup Script (Per-DB, no db2stop)
#
# Changes vs previous:
# - DOES NOT run db2stop / db2start (does not stop the instance)
# - Deactivates ONLY the target database
# - If DB is active or connections exist, it exits and prints connection details
#
# Usage:
#   ./db2_offline_backup.sh <DB_NAME>
# Example:
#   ./db2_offline_backup.sh D01
# ------------------------------------------------------------

set -o pipefail

DB_NAME="$1"

# --- Config (adjust as needed) ---
BACKUP_DIR="/db_backup/offline"
LOG_DIR="/var/log"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOGFILE="${LOG_DIR}/db2_offline_backup_${DB_NAME}_${TIMESTAMP}.log"

log() { echo "$(date '+%Y-%m-%d %H:%M:%S') : $*" | tee -a "$LOGFILE" ; }
fail_exit() { log "ERROR: $*"; exit 1; }

usage() {
  echo "Usage: $0 <DB_NAME>"
}

if [[ -z "${DB_NAME}" ]]; then
  usage
  exit 1
fi

mkdir -p "${BACKUP_DIR}" "${LOG_DIR}" || { echo "ERROR: cannot create backup/log directory"; exit 1; }

log "============================================================"
log "DB2 OFFLINE BACKUP (NO db2stop) - START"
log "DB_NAME    : ${DB_NAME}"
log "BACKUP_DIR : ${BACKUP_DIR}"
log "LOGFILE    : ${LOGFILE}"
log "USER       : $(id -un)"
log "HOST       : $(hostname -f 2>/dev/null || hostname)"
log "TIMESTAMP  : ${TIMESTAMP}"
log "============================================================"

# --- Ensure db2 command available ---
if ! command -v db2 >/dev/null 2>&1; then
  if [[ -f "${HOME}/sqllib/db2profile" ]]; then
    # shellcheck disable=SC1090
    . "${HOME}/sqllib/db2profile"
  fi
fi
command -v db2 >/dev/null 2>&1 || fail_exit "db2 command not found. Run as DB2 instance owner and ensure db2profile is sourced."

# --- Check DB exists in local catalog ---
log "[CHECK] DB exists in local catalog..."
if ! db2 list db directory | grep -qE "Database alias[[:space:]]+=[[:space:]]+${DB_NAME}\b"; then
  fail_exit "Database alias '${DB_NAME}' not found in local database directory. Run 'db2 list db directory' to confirm."
fi
log "OK: Database alias '${DB_NAME}' found."

# --- Helper: show connection details for this DB (best-effort) ---
show_connections() {
  log "[INFO] Active connections for database ${DB_NAME}:"
  db2 "list applications for database ${DB_NAME}" 2>&1 | tee -a "$LOGFILE"
}

# --- Pre-check: if DB is active, exit (do not proceed) ---
ACTIVE_OUT=$(db2 "list active databases" 2>&1)
echo "$ACTIVE_OUT" | tee -a "$LOGFILE"

if echo "$ACTIVE_OUT" | grep -qE "Database name[[:space:]]+=[[:space:]]+${DB_NAME}\b"; then
  log "Database '${DB_NAME}' is ACTIVE."
  show_connections
  fail_exit "Offline backup will NOT proceed. Please ensure '${DB_NAME}' is inactive and no connections exist."
fi

# --- Check for connections (best-effort) ---
CONN_OUT=$(db2 "list applications for database ${DB_NAME}" 2>&1)
echo "$CONN_OUT" | tee -a "$LOGFILE"

# Heuristic: if output includes at least one "Application handle" line, we consider it active connections.
if echo "$CONN_OUT" | grep -qi "Application handle"; then
  log "Connections detected for '${DB_NAME}'."
  fail_exit "Offline backup will NOT proceed. Please terminate connections and deactivate the DB first."
fi

# --- Attempt to deactivate DB (idempotent / safe) ---
log "[ACTION] Deactivate database '${DB_NAME}' (target DB only)..."
db2 "deactivate db ${DB_NAME}" >> "$LOGFILE" 2>&1

# Re-check after deactivate
ACTIVE_OUT2=$(db2 "list active databases" 2>&1)
echo "$ACTIVE_OUT2" | tee -a "$LOGFILE"

if echo "$ACTIVE_OUT2" | grep -qE "Database name[[:space:]]+=[[:space:]]+${DB_NAME}\b"; then
  log "Database '${DB_NAME}' is still ACTIVE after deactivate attempt."
  show_connections
  fail_exit "Offline backup will NOT proceed. Please manually resolve connections/activation and retry."
fi

log "OK: Database '${DB_NAME}' is inactive."

# --- OFFLINE BACKUP ---
log "[RUN] db2 backup db ${DB_NAME} to ${BACKUP_DIR} compress"
db2 "backup db ${DB_NAME} to ${BACKUP_DIR} compress" >> "$LOGFILE" 2>&1 || fail_exit "Offline backup failed."

log "Offline backup completed successfully."
log "DB2 OFFLINE BACKUP - COMPLETE"
exit 0
