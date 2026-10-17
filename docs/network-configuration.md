# Network Configuration

## VMware network

- **VMnet1:** Host-only, `192.168.163.0/24`
- **DC01:** `192.168.163.10/24`, DNS `192.168.163.10`
- **CLIENT01:** `192.168.163.20/24`, DNS `192.168.163.10`
- **Default gateway:** Not required for communication within this isolated subnet.

The server previously had a NAT interface at `192.168.118.128`; this was disabled during troubleshooting to avoid unwanted DNS address registration.

## Tests

```cmd
ipconfig /all
ping 192.168.163.10
nslookup dc01.lab.example.com 192.168.163.10
```

Both virtual machines must be attached to the same VMnet1 host-only network for this topology. In routed production networks, clients and domain controllers can reside in different subnets if routing, DNS, and firewall rules permit communication.
