# Screenshot evidence

| File | Shows |
|---|---|
| `server-manager.png` | DC01 in Server Manager, joined to `lab.example.com` |
| `active-directory-domain.png` | The `lab.example.com` domain |
| `organizational-units.png` | IT, HR and Finance OUs |
| `domain-user-and-security-group.png` | Users and security groups in the IT OU |
| `dns-a-and-srv-records.png` | DC A record and LDAP SRV record |
| `client-domain-verification.png` | CLIENT01 joined to the domain (`systeminfo`, `whoami`, `%LOGONSERVER%`) |
| `control-panel-gpo-configuration.png` | The Control Panel GPO setting |
| `gpo-security-filtering.png` | Security filtering on the GPO |
| `gpo-applied-proof.png` | `gpresult` showing the GPO applied |
| `file-server-groups.png` | `GG_IT_Users` and `DL_IT_Modify` in the IT OU |
| `agdlp-membership.png` | Membership chain `IT-staff` → `GG_IT_Users` → `DL_IT_Modify` |
| `file-share.png` | `CompanyData` shared as `\\DC01\CompanyData` |
| `ntfs-permissions.png` | Advanced security settings on `C:\CompanyData` |
| `access-denied.png` | Attempt to open the HR folder from CLIENT01 |
| `mapped-network-drive.png` | `Z:` drive mapped to the share, showing only the HR folder |

Before adding new screenshots, check they do not expose passwords, product keys, recovery keys, personal accounts or other sensitive information.
