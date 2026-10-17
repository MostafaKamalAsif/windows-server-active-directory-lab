# Next Steps

Ideas to extend this lab, roughly in order of value:

| Idea | What it teaches |
|---|---|
| Add a second DC (`DC02`) | Replication, `repadmin /replsummary`, FSMO roles, DNS redundancy |
| DHCP on DC01 or a member server | Scopes, reservations, DHCP options for DNS |
| Reverse lookup zone and PTR records | Clean `nslookup` output, complete DNS |
| File server with share + NTFS permissions | Group-based access (AGDLP), access-based enumeration |
| Password and account lockout policy | Fine-grained password policy, security baselines |
| Windows Firewall and security baseline GPOs | Hardening with Group Policy |
| Windows LAPS | Unique local admin passwords per computer |
| Delegate OU permissions | Least privilege, helpdesk delegation |
| Backup and restore test | System State backup, authoritative restore |
| Export GPOs with `Backup-GPO` and commit them | GPO version control and portability |
