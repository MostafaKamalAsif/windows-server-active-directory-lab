# Windows Server 2022 Active Directory & Group Policy Lab

A hands-on system administration lab built with **VMware Workstation Pro**, **Windows Server 2022**, and **Windows 11 Pro**. This project demonstrates centralized identity management, DNS troubleshooting, domain joining, and targeted Group Policy deployment.

## Lab objectives

- Deploy Active Directory Domain Services (AD DS) and DNS.
- Create and manage organizational units (OUs), domain users, and security groups.
- Join a Windows 11 Pro client to the domain.
- Validate DNS records and domain controller discovery.
- Apply and troubleshoot a user-based Group Policy with security filtering.

## Lab environment

| Component | Configuration |
|---|---|
| Hypervisor | VMware Workstation Pro |
| Domain controller | DC01 — Windows Server 2022 |
| Domain / forest | `lab.example.com` (isolated lab domain) |
| DC roles | AD DS, DNS |
| DC IP | `192.168.163.10/24` |
| Client | CLIENT01 — Windows 11 Pro |
| Client IP | `192.168.163.20/24` |
| VMware network | VMnet1 — Host-only (`192.168.163.0/24`) |
| Client DNS | `192.168.163.10` |
| OUs | IT, HR, Finance |

> The lab uses a private, host-only network. These addresses and domain names are illustrative lab settings, not production recommendations.

## Network topology

```text
              VMware VMnet1 (Host-only)
                  192.168.163.0/24
                          |
              +-----------+-----------+
              |                       |
    +-------------------+   +-------------------+
    | DC01              |   | CLIENT01          |
    | Windows Server    |   | Windows 11 Pro    |
    | 192.168.163.10    |   | 192.168.163.20    |
    | AD DS + DNS       |   | DNS: .163.10      |
    +-------------------+   +-------------------+
```

## Implementation summary

1. Installed Windows Server 2022 and promoted `DC01` to a domain controller for `lab.example.com`.
2. Configured the host-only network, static IPv4 addressing, and AD-integrated DNS.
3. Created the IT, HR, and Finance OUs and domain user accounts.
4. Verified the DC host A record, LDAP SRV record, and domain controller discovery.
5. Removed stale DNS A records left from earlier VM/network configurations.
6. Installed Windows 11 Pro, configured its DNS to point to DC01, and joined it to the domain.
7. Created a GPO named `IT-Block-ControlPanel` linked to the IT OU.
8. Configured **User Configuration → Policies → Administrative Templates → Control Panel → Prohibit access to Control Panel and PC settings**.
9. Created the `IT-ControlPanel-Restricted` security group and used GPO security filtering to target selected users.
10. Tested the policy using a domain user session and Windows Group Policy diagnostic commands.

## Verification commands

On the client or domain controller, as appropriate:

```powershell
ipconfig /all
nslookup dc01.lab.example.com 192.168.163.10
nslookup -type=SRV _ldap._tcp.dc._msdcs.lab.example.com 192.168.163.10
nltest /dsgetdc:lab.example.com /force
whoami
gpupdate /force
gpresult /r /scope user
```

On DC01, DNS health was also checked with:

```powershell
dcdiag /test:dns /v
```

## Group Policy: security filtering

**Goal:** Restrict Control Panel for members of `IT-ControlPanel-Restricted`, without restricting other IT OU users through this GPO.

- **GPO link:** IT OU
- **Security Filtering:** `IT-ControlPanel-Restricted` (Read + Apply Group Policy)
- **Authenticated Users:** Read only, without Apply Group Policy, to support user GPO processing
- **User setting:** Prohibit access to Control Panel and PC settings = Enabled

Group membership changes may require users to sign out and sign back in. `gpresult /r /scope user` can confirm which policies were applied or filtered out.

## Screenshots

Add your own screenshots to the `screenshots/` folder, then update this section. Suggested evidence:

- ADUC showing the IT, HR, and Finance OUs
- DNS Manager showing the relevant A and SRV records
- Windows 11 joined to `lab.example.com`
- GPO configuration and security filtering
- `gpresult` and the Control Panel restriction test

Do not include passwords, recovery keys, product keys, or private credentials in screenshots.

## Documentation

- [Network configuration](docs/network-configuration.md)
- [Active Directory setup](docs/active-directory-setup.md)
- [DNS troubleshooting](docs/dns-troubleshooting.md)
- [Group Policy configuration](docs/group-policy-configuration.md)

## Skills demonstrated

Windows Server 2022 · Active Directory DS · DNS · Windows 11 Domain Join · Group Policy · Security Groups · VMware Networking · PowerShell · Troubleshooting

## Disclaimer

This is a learning lab, not a production deployment. No VM images, ISO files, credentials, or license keys are included.
