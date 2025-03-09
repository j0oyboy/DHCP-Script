# DHCP Server Automation Script

## Overview
This PowerShell script automates the installation, configuration, and management of a DHCP server on a Windows machine. It provides an interactive menu for tasks such as installing the DHCP role, creating scopes, configuring options, and managing security settings.


![Screenshot 2025-03-09 180226](https://github.com/user-attachments/assets/b390c958-302c-473e-8830-f58f28c07b2c)


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
3. Navigate to the script folder:
   
   ```sh
   cd DHCP-Script\V3 Last Version
   ```
5. Run the script in PowerShell:
   
   ```powershell
   .\dhcp_script.ps1
   ```

## Menu Options
| Option | Description |
|--------|-------------|
| 1 | Install DHCP server role |
| 2 | Check DHCP installation status |
| 3 | Start the DHCP service  |
| 4 | Add DHCP server to security group |
| 5 | Create a DHCP scope |
| 6 | Create an exclusion range |
| 7 | Configure Scope Options |
| 8 |  Remove DHCP Configuration |
| 9 | View Active Scopes and Configuration |
| 10 | Exit the script |

## License
This project is open-source and available under the MIT License.

## Author
Developed by **Souhaib**

For any issues, feel free to create an issue on [GitHub](https://github.com/j0oyboy).

