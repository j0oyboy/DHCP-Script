# DHCP Server Automation Script

## Overview
This PowerShell script automates the installation, configuration, and management of a DHCP server on a Windows machine. It provides an interactive menu for tasks such as installing the DHCP role, creating scopes, configuring options, and managing security settings.

## Features
- Install the DHCP server role
- Verify installation status
- Start and manage the DHCP service
- Add the DHCP server to the security group
- Create and manage DHCP scopes
- Configure scope options (gateway, DNS server, exclusions)
- Remove DHCP configurations

## Prerequisites
- Windows Server with administrative privileges
- PowerShell execution policy set to allow script execution
  ```powershell
  Set-ExecutionPolicy RemoteSigned -Scope Process
  ```
- The script must be run with administrator privileges

## Installation
1. Clone this repository:
   ```sh
   git clone https://github.com/j0oyboy/DHCP-Script.git
   ```
2. Navigate to the script folder:
   ```sh
   cd DHCP-Script
   ```
3. Run the script in PowerShell:
   ```powershell
   .\dhcp_script.ps1
   ```

## Menu Options
| Option | Description |
|--------|-------------|
| 1 | Install DHCP server role |
| 2 | Check DHCP service installation status |
| 3 | Start the DHCP service |
| 4 | Add DHCP server to security group |
| 5 | Create a DHCP scope |
| 6 | Create an exclusion range |
| 7 | Configure scope options (gateway, DNS) |
| 8 | Open the GitHub repository |
| 9 | Exit the script |

## Removing DHCP Configurations
To remove a DHCP scope:
```powershell
Remove-DhcpServerv4Scope -ScopeId <ScopeID> -Confirm:$false
```
To remove an exclusion range:
```powershell
Remove-DhcpServerv4ExclusionRange -ScopeId <ScopeID> -StartRange <StartIP> -EndRange <EndIP> -Confirm:$false
```

## License
This project is open-source and available under the MIT License.

## Author
Developed by **Joy**

For any issues, feel free to create an issue on [GitHub](https://github.com/j0oyboy).

