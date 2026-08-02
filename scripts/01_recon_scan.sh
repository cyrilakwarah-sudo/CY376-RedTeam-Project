#!/bin/bash
#
# 01_recon_scan.sh
# CY376 Red Team Project — Reconnaissance Automation
#
# Purpose: Runs the Nmap service/version scan against the target host
#          and saves timestamped output for evidence and repeatability.
#
# Usage:   ./01_recon_scan.sh <target-ip>
# Example: ./01_recon_scan.sh 172.16.232.131
#
# Author:  Cyril Akwara Adolwine (FCM.41.018.033.23)

set -euo pipefail

TARGET="${1:-172.16.232.131}"
OUTDIR="../evidence/scans"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTFILE="${OUTDIR}/nmap_${TARGET}_${TIMESTAMP}.txt"

mkdir -p "$OUTDIR"

echo "[*] Starting reconnaissance scan against $TARGET"
echo "[*] Output will be saved to $OUTFILE"

nmap -sV -sC "$TARGET" | tee "$OUTFILE"

echo "[*] Scan complete. Results saved to $OUTFILE"
