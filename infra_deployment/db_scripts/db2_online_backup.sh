#!/bin/bash
# ------------------------------------------------------------
# db2_online_backup.sh
# DB2 Online Backup Script – Full or Incremental (SAP-friendly)
#
# Usage:
#   ./db2_online_backup.sh <DBNAME> {FULL|INCR}
# Example:
#   ./db2_online_backup.sh D01 FULL
# ------------------------------------------------------------

set -o pipefail

DBNAME="$1"
BACKUP_TYPE="$2"

# --- Configuration (adjust if needed) ---
BACKUP_DIR="/db_dump"
LOG_DIR="/db2/db2d01/logs"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOGFILE="${LOG_DIR}/${DBNAME}_online_${BACKUP_TYPE}_${TIMESTAMP}.log"

usage() {
  echo "Usage: $0 <DBNAME> {FULL|INCR}"
}

fail() {
  echo "ERROR: $*" | tee -a "${LOGFILE}"
  exit 1
}

# --- Validate parameters ---
if [[ -z "${DBNAME}" || -z "${BACKUP_TYPE}" ]]; then
  usage
  exit 1
fi

if [[ "${BACKUP_TYPE}" != "FULL" && "${BACKUP_TYPE}" != "INCR" ]]; then
  usage
  exit 1
fi

# --- Ensure directories exist ---
mkdir -p "${BACKUP_DIR}" "${LOG_DIR}" || { echo "ERROR: cannot create ${BACKUP_DIR} or ${LOG_DIR}"; exit 1; }

echo "=============================================" | tee -a "${LOGFILE}"
echo "DB2 Online Backup شروع / Start" | tee -a "${LOGFILE}"
echo "DBNAME      : ${DBNAME}" | tee -a "${LOGFILE}"
echo "TYPE        : ${BACKUP_TYPE}" | tee -a "${LOGFILE}"
echo "BACKUP_DIR  : ${BACKUP_DIR}" | tee -a "${LOGFILE}"
echo "LOGFILE     : ${LOGFILE}" | tee -a "${LOGFILE}"
echo "TIMESTAMP   : ${TIMESTAMP}" | tee -a "${LOGFILE}"
echo "USER        : $(id -un)" | tee -a "${LOGFILE}"
echo "HOST        : $(hostname -f 2>/dev/null || hostname)" | tee -a "${LOGFILE}"
echo "=============================================" | tee -a "${LOGFILE}"

# --- Ensure DB2 CLI is available (db2profile) ---
if ! command -v db2 >/dev/null 2>&1; then
  # Try common profile location for instance owner
  if [[ -f "${HOME}/sqllib/db2profile" ]]; then
    # shellcheck disable=SC1090
    . "${HOME}/sqllib/db2profile"
  fi
fi

command -v db2 >/dev/null 2>&1 || fail "db2 command not found. Run as DB2 instance owner and ensure db2profile is sourced."

# --- Check database exists in local catalog ---
echo "[CHECK] DB exists in local catalog..." | tee -a "${LOGFILE}"
if ! db2 list db directory | awk -v db="${DBNAME}" '
  $0 ~ /Database alias/ {alias=$NF}
  $0 ~ /Database name/  {name=$NF}
  END { }
' >/dev/null 2>&1; then
  :
fi

# more direct check:
if ! db2 list db directory | grep -qE "Database (alias|name)[[:space:]]+=[[:space:]]+${DBNAME}\b"; then
  # In some SAP cases, alias may differ. We still require the alias passed to exist.
  if ! db2 list db directory | grep -qE "Database alias[[:space:]]+=[[:space:]]+${DBNAME}\b"; then
    fail "Database alias '${DBNAME}' not found in local database directory. Run 'db2 list db directory' to confirm."
  fi
fi
echo "OK: Database alias '${DBNAME}' found." | tee -a "${LOGFILE}"

# --- Check log archiving enabled (required for ONLINE backup) ---
echo "[CHECK] Log archiving enabled (LOGARCHMETH1/2 not OFF)..." | tee -a "${LOGFILE}"
LOGARCH=$(db2 get db cfg for "${DBNAME}" | egrep -i "First log archive method|Second log archive method" | tee -a "${LOGFILE}")

if echo "${LOGARCH}" | grep -qi "LOGARCHMETH1).*=\s*OFF" && echo "${LOGARCH}" | grep -qi "LOGARCHMETH2).*=\s*OFF"; then
  fail "Log archiving is OFF (LOGARCHMETH1 and LOGARCHMETH2). ONLINE backup is not allowed. Enable log archiving first."
fi
echo "OK: Log archiving appears enabled." | tee -a "${LOGFILE}"

# --- Check DB state: try activate + connect (ensures DB isn't in bad state for online backup) ---
echo "[CHECK] Connect to '${DBNAME}'..." | tee -a "${LOGFILE}"
db2 "connect to ${DBNAME}" >> "${LOGFILE}" 2>&1 || fail "Unable to connect to database '${DBNAME}'. Check DB status and instance health."
db2 "connect reset" >> "${LOGFILE}" 2>&1 || true
echo "OK: Database can be connected." | tee -a "${LOGFILE}"

# --- Build backup command ---
if [[ "${BACKUP_TYPE}" == "FULL" ]]; then
  DB2_CMD=(db2 backup db "${DBNAME}" online to "${BACKUP_DIR}" compress include logs)
else
  DB2_CMD=(db2 backup db "${DBNAME}" online incremental to "${BACKUP_DIR}" compress include logs)
fi

echo "[RUN] ${DB2_CMD[*]}" | tee -a "${LOGFILE}"
"${DB2_CMD[@]}" >> "${LOGFILE}" 2>&1
RC=$?

if [[ ${RC} -ne 0 ]]; then
  fail "Backup failed with return code ${RC}. Check log: ${LOGFILE}"
fi

echo "SUCCESS: DB2 ${BACKUP_TYPE} ONLINE backup completed for ${DBNAME}." | tee -a "${LOGFILE}"

# --- Post: show latest history entry ---
echo "[INFO] Backup history (latest):" | tee -a "${LOGFILE}"
db2 list history backup all for "${DBNAME}" >> "${LOGFILE}" 2>&1 || true

exit 0
