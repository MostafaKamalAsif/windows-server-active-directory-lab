# Group Policy Configuration

## Policy

- GPO: `IT-Block-ControlPanel`
- Link: IT OU
- Path: **User Configuration → Policies → Administrative Templates → Control Panel → Prohibit access to Control Panel and PC settings**
- Setting: **Enabled**

## Security filtering

1. In Active Directory Users and Computers, create a **Global Security** group named `IT-ControlPanel-Restricted`.
2. Add only the intended IT users to the group.
3. In Group Policy Management, select the GPO → **Scope** → **Security Filtering**.
4. Add `IT-ControlPanel-Restricted` and remove `Authenticated Users` from the *Apply* filtering list.
5. Under **Delegation → Advanced**, retain **Read** for `Authenticated Users` but not **Apply group policy**. The restricted group needs both Read and Apply.
6. Sign out and sign in after group membership changes, then refresh policy.

## Test commands

```cmd
gpupdate /force
gpresult /r /scope user
whoami /groups
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoControlPanel
control.exe
```

`NoControlPanel` set to `0x1` indicates that the restriction is configured in the current user's policy registry location. Other GPOs may also affect the result.
