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

## Reproducible fix (PowerShell)

List the A records registered for the DC, remove the stale ones, then re-register:

```powershell
# What is registered today?
Get-DnsServerResourceRecord -ZoneName lab.example.com -Name dc01 -RRType A

# Remove a stale record (repeat for each outdated IP)
Remove-DnsServerResourceRecord -ZoneName lab.example.com -Name dc01 -RRType A -RecordData 192.168.56.10 -Force

# Re-register DNS and Netlogon (SRV) records, then re-check
ipconfig /registerdns
nltest /dsregdns
dcdiag /test:dns /v
```

To stop the DC registering an unwanted adapter again, disable that adapter, or clear **Register this connection's addresses in DNS** on its IPv4 DNS settings (Advanced → DNS tab).

## Root cause

A domain controller registers **every** IPv4 address on every enabled adapter. Moving the VM between VirtualBox and VMware, and keeping a NAT adapter enabled, left old addresses in the zone. Clients can then be handed an unreachable DC address, which causes slow or failed logons and domain join errors.

## Optional: fix `Server: Unknown`

Create a reverse lookup zone for `163.168.192.in-addr.arpa` and a PTR record for `192.168.163.10`, so `nslookup` shows the server name.
