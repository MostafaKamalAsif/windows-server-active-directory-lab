# Lessons Learned

1. **Fix DNS before anything else.** Domain join, Kerberos and GPO processing all depend on correct DNS. Most "AD problems" in this lab were DNS problems.
2. **A DC registers all its adapters.** Extra NAT/bridged adapters polluted the zone with unusable addresses. Keep one adapter on the DC, or disable DNS registration on the others.
3. **Clients must use the DC for DNS.** Pointing CLIENT01 at a public resolver breaks domain discovery.
4. **`nslookup` showing `Server: Unknown` is not an error by itself.** It only means no reverse (PTR) record exists for the DNS server's IP.
5. **Security filtering needs Read for Authenticated Users.** Removing `Authenticated Users` entirely stops user GPOs from processing; keep Read, remove Apply.
6. **Group changes need a new logon.** A user's token is built at sign-in, so sign out and in before testing a security-filtered GPO.
7. **Prove it, don't assume it.** `gpresult /r /scope user` and `whoami /groups` are the evidence that a policy applied for the right reason.
8. **Never commit secrets.** Scripts prompt for passwords; the `.gitignore` blocks keys, credentials files and VM images.
9. **Permissions belong on groups, via AGDLP.** Accounts go into global groups, global groups into domain local groups, and only the domain local group appears on the folder.
10. **Check inheritance on the folders you protect.** The default `C:\` entries give `Users` read access; a department folder is only private once inheritance is disabled.
11. **Access-based enumeration hides what users should not know exists.** It is a share setting, separate from NTFS permissions.
12. **A generic "Windows cannot access" message is weak evidence.** Capture the error code or an `Access is denied` result from `dir`, plus `whoami`, so the proof is unambiguous.
