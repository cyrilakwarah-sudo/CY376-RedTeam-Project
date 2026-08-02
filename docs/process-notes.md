# Process Notes

Working notes kept during the CY376 Red Team project. These record the
reasoning behind key decisions made during the assessment, separate from
the formal report.

## Environment Setup

- Chose VMware Fusion over VirtualBox since it was already installed and
  both target VM images (Kali, Metasploitable2) publish official VMware
  disk images — no conversion needed.
- Initial mistake: left both VMs on default NAT ("Share with my Mac")
  network mode. Corrected before powering on Metasploitable2 by switching
  both VMs to "Private to my Mac" (host-only) mode. Verified isolation
  before any scanning began.
- Confirmed connectivity with `ping` before running any scans, to rule
  out network misconfiguration as a source of false negatives later.

## Recon Phase

- Ran `nmap -sV -sC` rather than a default scan to get service versions
  and default script output in one pass — version info was essential for
  identifying which CVEs applied.
- Full port range was not scanned (`-p-`) due to time constraints; the
  default top-1000-ports scan was sufficient to surface multiple critical
  findings, so this was judged an acceptable scope decision for the
  assessment window.

## Vulnerability Selection Reasoning

- UnrealIRCd 3.2.8.1 was prioritised first because the exact version
  string in the Nmap banner is a direct, unambiguous match for the known
  backdoored release — low risk of a failed/incorrect exploit attempt.
- Samba 3.0.20-Debian was selected second, both to diversify vulnerability
  classes covered (supply-chain backdoor vs. genuine input-validation
  defect) and because CVE-2007-2447 is a well-documented, reliable
  Metasploit module.
- Considered but did not pursue: Tomcat/Coyote manager interface on port
  8180 (would require credential brute-forcing, higher time cost for
  uncertain payoff) and VNC on 5900 (weak auth, but lower report value
  given two RCE findings already achieved root).

## Issues Encountered

- First exploit attempt on UnrealIRCd failed validation because LHOST
  was not set — Metasploit requires an explicit listener address for
  reverse-shell payloads even when RHOSTS is correctly configured.
  Resolved by setting LHOST to the Kali VM's own host-only IP.
- GitHub push initially failed with "Invalid username or token" — GitHub
  no longer accepts account passwords for CLI Git operations. Resolved
  by generating a Personal Access Token (repo scope) and using it in
  place of the password at the credential prompt.

## Evidence Handling

- Screenshots captured directly from the terminal session on both the
  Kali VM and the macOS host, then transferred and renamed descriptively
  before being committed (e.g. `unrealircd-exploit-root-shell.png`)
  rather than left as default `IMG_####` filenames, for traceability.
