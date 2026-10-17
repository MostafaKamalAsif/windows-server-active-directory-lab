# Active Directory Setup

## Environment

- Domain controller: `DC01`
- Domain: `lab.example.com`
- Windows Server 2022 roles: Active Directory Domain Services and DNS
- Organizational units: `IT`, `HR`, `Finance`

## Client join

1. Configure CLIENT01 DNS as `192.168.163.10`.
2. Verify domain controller discovery:

   ```cmd
   nltest /dsgetdc:lab.example.com /force
   ```

3. Open `sysdm.cpl` → **Computer Name** → **Change**.
4. Join `lab.example.com` using an authorized domain account.
5. Restart and sign in with a domain user.

## Validation

```cmd
whoami
echo %LOGONSERVER%
```

Use **Active Directory Users and Computers** on DC01 to confirm the CLIENT01 computer object and user accounts. Do not commit account passwords to GitHub.
