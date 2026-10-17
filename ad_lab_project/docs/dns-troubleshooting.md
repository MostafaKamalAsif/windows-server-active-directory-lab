# DNS Troubleshooting

## Symptoms observed

- Multiple network adapters registered unwanted IP addresses for DC01.
- Old VirtualBox IP addresses remained as stale A records.
- `nslookup` displayed `Server: Unknown` despite resolving some records; this can occur when the DNS server has no matching reverse PTR record.

## Resolution steps performed

1. Configured DC01 host-only IP `192.168.163.10`.
2. Removed stale A records (`192.168.56.10`, `10.0.2.15`, `192.168.100.10`, `192.168.118.128`) after identifying them as outdated.
3. Disabled the unwanted NAT adapter during the lab.
4. Refreshed DNS and Netlogon registrations and checked DNS health.

## Checks

```cmd
nslookup dc01.lab.example.com 192.168.163.10
nslookup -type=SRV _ldap._tcp.dc._msdcs.lab.example.com 192.168.163.10
nltest /dsgetdc:lab.example.com /force
dcdiag /test:dns /v
```

The LDAP SRV record resolves to `dc01.lab.example.com` on TCP port 389. The DNS diagnostic test was reported as passing. `Server: Unknown` by itself is not proof of an Active Directory DNS failure.
