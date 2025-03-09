# DHCP Management Script
chcp 65001 > $null

function Custom-Window(){
    chcp 65001 > $null
    
    # Change the windows Title
    $host.UI.RawUI.WindowTitle = "DHCP Management Tool by Souhaib"

    # Change the Window Size
    [Console]::SetWindowSize(98, 38)

    # Change the BackGround  and Foreground Color
    $host.UI.RawUI.BackgroundColor = "Black"
    $host.UI.RawUI.ForegroundColor = "Cyan"
}

Custom-Window

# Check if running as admin at the beginning
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "`n This script requires administrator privileges to manage DHCP services." -ForegroundColor Red
    Write-Host "`n Please restart the script as an administrator." -ForegroundColor Yellow
    Start-Sleep -Seconds 3
    exit
}

# Function to center text in the console
function Center-Text($text) {
    $width = [console]::WindowWidth
    $padLeft = [math]::Max(0, ($width - $text.Length) / 2)
    return (' ' * $padLeft) + $text
}

# Function to show a notification with colored text
function Show-Notification($message, $color = "White") {
    Write-Host "`n $message" -ForegroundColor $color
    Start-Sleep -Seconds 2
}

# Initialize variables to store scope information
$ScopeName = ""
$SubnetIp = ""
$SubnetMask = ""
$StartRange = ""
$EndRange = ""
$StartExcl = ""
$EndExcl = ""
$gatewayIp = ""
$dnsServer = ""

$Banner = @(
    " ",
    " ███╗   ███╗ █████╗ ███╗   ██╗ █████╗  ██████╗ ███████╗    ██████╗ ██╗  ██╗ ██████╗██████╗ ",
    " ████╗ ████║██╔══██╗████╗  ██║██╔══██╗██╔════╝ ██╔════╝    ██╔══██╗██║  ██║██╔════╝██╔══██╗",
    " ██╔████╔██║███████║██╔██╗ ██║███████║██║  ███╗█████╗      ██║  ██║███████║██║     ██████╔╝",
    " ██║╚██╔╝██║██╔══██║██║╚██╗██║██╔══██║██║   ██║██╔══╝      ██║  ██║██╔══██║██║     ██╔═══╝ ",
    " ██║ ╚═╝ ██║██║  ██║██║ ╚████║██║  ██║╚██████╔╝███████╗    ██████╔╝██║  ██║╚██████╗██║     ",
    " ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝    ╚═════╝ ╚═╝  ╚═╝ ╚═════╝╚═╝     ",
    "                                                                             	   SERVER",
    " "
)

$menu = @(
    " ",
    " ╔══════════════════════════════════════════════╗",
    " ║ 1. Install DHCP Service                      ║",
    " ║                                              ║",
    " ║ 2. Check DHCP Installation Status            ║",
    " ║                                              ║",
    " ║ 3. Start/Stop DHCP Service                   ║",
    " ║                                              ║",
    " ║ 4. Add DHCP Server to Security Group         ║",
    " ║                                              ║",
    " ║ 5. Create DHCP Scope                         ║",
    " ║                                              ║",
    " ║ 6. Create Exclusion Range                    ║",
    " ║                                              ║",
    " ║ 7. Configure Scope Options                   ║",
    " ║                                              ║",
    " ║ 8. Remove DHCP Configuration                 ║",
    " ║                                              ║",
    " ║ 9. View Active Scopes and Configuration      ║",
    " ║                                              ║",
    " ║ 10. Exit Script                              ║",
    " ╚══════════════════════════════════════════════╝",
    " "
)

$option7 = @(
    " ",
    "╔═══════════════════════════════╗",
    "║  1. Add Default Gateway       ║",
   " ║                               ║",
    "║  2. Add DNS Server            ║",
   " ║                               ║",
    "║  3. Add Domain Name           ║",
   " ║                               ║",
    "║  4. Add Lease Duration        ║",
   " ║                               ║",
    "║  0. Return to Main Menu       ║"
    "╚═══════════════════════════════╝",
    " "
)

function Test-AdminPrivileges {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-IPAddress {
    param ([string]$IPAddress)
    
    $IPRegex = "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$"
    return $IPAddress -match $IPRegex
}

function Show-Menu {
    Clear-Host
    
    # Display banner
    foreach ($line in $Banner) {
        Write-host ( Center-text $line )  -ForegroundColor DarkRed
    } 
    
    # Display menu
    foreach ($line in $menu) {
        Write-Host  ( Center-text $line ) -ForegroundColor Yellow
    }
}

While ($true) {
    Show-Menu
    
    # Get user choice
    Write-Host ""
    Write-Host ""
    $choice = Read-Host " ►  Enter your choice"

    Switch ($choice) {        
        "1" {
            Clear-Host
            Write-Host "`n Installing DHCP service..." -ForegroundColor Cyan
            try {
                Install-WindowsFeature -Name DHCP -IncludeManagementTools
                Show-Notification "`n DHCP service installed successfully!" "Green"
            } catch {
                Show-Notification "`n Error installing DHCP service: $_" "Red"
            }
        }

        "2" {
            Clear-Host
            Write-Host "`n Checking DHCP service status..." -ForegroundColor Cyan
            
            $CheckDhcp = Get-WindowsFeature -Name DHCP 
            if ($CheckDhcp.Installed) {
                Show-Notification "`n DHCP service is installed successfully." "Green"
                $dhcpService = Get-Service 'DHCPServer' -ErrorAction SilentlyContinue
                if ($dhcpService) {
                    Write-Host "`n Service Status: $($dhcpService.Status)" -ForegroundColor Cyan
                }
            } else {
                Show-Notification "DHCP service is not installed." "Red"
            }
            Start-Sleep -Seconds 1
        }
        
        "3" {
            Clear-Host
            Write-Host "`n DHCP Service Control" -ForegroundColor Cyan
            Write-Host " --------------------"
            $dhcpService = Get-Service 'DHCPServer' -ErrorAction SilentlyContinue
            
            if ($dhcpService) {
                Write-Host "`n Current Status: $($dhcpService.Status)" -ForegroundColor Yellow
                Write-Host "`n 1. Start Service"
                Write-Host " 2. Stop Service"
                Write-Host " 3. Restart Service"
                Write-Host " 0. Return to Main Menu"
                Write-Host ""
                $serviceChoice = Read-Host "`n ►  Enter your choice"
                
                switch ($serviceChoice) {
                    "1" {
                        Clear-Host
                        if ($dhcpService.Status -eq "Running") {
                            Show-Notification "Service is already running." "Yellow"
                        } else {
                            Clear-Host
                            Start-Service -Name DHCPServer
                            Show-Notification "DHCP Service started successfully." "Green"
                        }
                    }
                    "2" {
                        Clear-Host
                        if ($dhcpService.Status -eq "Stopped") {
                            Show-Notification "Service is already stopped." "Yellow"
                        } else {
                            Clear-Host
                            Stop-Service -Name DHCPServer -Force
                            Show-Notification "DHCP Service stopped successfully." "Green"
                        }
                    }
                    "3" {
                        Clear-Host
                        Restart-Service -Name DHCPServer -Force
                        Show-Notification "DHCP Service restarted successfully." "Green"
                    }
                    "0" {
                        # Return to main menu
                    }
                    default {
                        Show-Notification "Invalid choice. Please try again." "Red"
                    }
                }
            } else {
                Show-Notification "DHCP Service is not installed." "Red"
            }
        }

        "4" {
            Clear-Host
            Write-Host "`n Adding DHCP server to security group..." -ForegroundColor Cyan
            try {
                Add-DhcpServerSecurityGroup
                Show-Notification "DHCP server added to security group successfully." "Green"
            } catch {
                Show-Notification "Error adding DHCP server to security group: $_" "Red"
            }
        }
        
        "5" {
            Clear-Host
            Write-Host "`n Create DHCP Scope" -ForegroundColor Cyan
            Write-Host " -----------------"
            
            # User Inputs with validation
            do {
                $ScopeName = Read-Host "`n  ► Enter the scope name"
                if ([string]::IsNullOrWhiteSpace($ScopeName)) {
                    Show-Notification "Scope name cannot be empty." "Red"
                }
            } while ([string]::IsNullOrWhiteSpace($ScopeName))
            
            do {
                $SubnetIp = Read-Host "`n  ► Enter subnet IP address (e.g., 192.168.1.0)"
                if (-not (Test-IPAddress $SubnetIp)) {
                    Show-Notification "Invalid IP address format." "Red"
                }
            } while (-not (Test-IPAddress $SubnetIp))
            
            do {
                $SubnetMask = Read-Host "`n  ► Enter subnet mask (e.g., 255.255.255.0)"
                if (-not (Test-IPAddress $SubnetMask)) {
                    Show-Notification "Invalid subnet mask format." "Red"
                }
            } while (-not (Test-IPAddress $SubnetMask))
            
            do {
                $StartRange = Read-Host "`n  ► Enter start IP address for the scope"
                if (-not (Test-IPAddress $StartRange)) {
                    Show-Notification "Invalid IP address format." "Red"
                }
            } while (-not (Test-IPAddress $StartRange))
            
            do {
                $EndRange = Read-Host "`n  ► Enter end IP address for the scope"
                if (-not (Test-IPAddress $EndRange)) {
                    Show-Notification "Invalid IP address format." "Red"
                }
            } while (-not (Test-IPAddress $EndRange))

            try {
                Add-DhcpServerv4Scope -Name $ScopeName -StartRange $StartRange -EndRange $EndRange -SubnetMask $SubnetMask
                Show-Notification "DHCP scope created successfully." "Green"
            } catch {
                Show-Notification "Error creating DHCP scope: $_" "Red"
            }
        }

        "6" {
            Clear-Host
            Write-Host "`n Create Exclusion Range" -ForegroundColor Cyan
            
            # Show available scopes
            Write-Host "`n Available Scopes:" -ForegroundColor Yellow
            Get-DhcpServerv4Scope | Format-Table -Property ScopeId, Name, State, StartRange, EndRange -AutoSize
            
            do {
                $ScopeId = Read-Host "`n Enter the Scope ID to add exclusion"
                if (-not (Test-IPAddress $ScopeId)) {
                    Show-Notification "Invalid Scope ID format." "Red"
                }
            } while (-not (Test-IPAddress $ScopeId))
            
            do {
                $StartExcl = Read-Host "`n Enter start IP address for exclusion range"
                if (-not (Test-IPAddress $StartExcl)) {
                    Show-Notification "Invalid IP address format." "Red"
                }
            } while (-not (Test-IPAddress $StartExcl))
            
            do {
                $EndExcl = Read-Host "`n Enter end IP address for exclusion range"
                if (-not (Test-IPAddress $EndExcl)) {
                    Show-Notification "Invalid IP address format." "Red"
                }
            } while (-not (Test-IPAddress $EndExcl))

            try {
                Add-DhcpServerv4ExclusionRange -ScopeId $ScopeId -StartRange $StartExcl -EndRange $EndExcl
                Show-Notification "Exclusion range added successfully." "Green"
            } catch {
                Show-Notification "Error adding exclusion range: $_" "Red"
            }
        }
        
        "7" {
            Clear-Host
            
            # Show available scopes first
            Write-Host "`n Available Scopes:" -ForegroundColor Yellow
            Get-DhcpServerv4Scope | Format-Table -Property ScopeId, Name, State -AutoSize
            
            do {
                $ScopeId = Read-Host "`n ♀ Enter the Scope ID to configure options"
                if (-not (Test-IPAddress $ScopeId)) {
                    Show-Notification "Invalid Scope ID format." "Red"
                    continue
                }
                
                # Verify the scope exists
                $scopeExists = Get-DhcpServerv4Scope -ScopeId $ScopeId -ErrorAction SilentlyContinue
                if (-not $scopeExists) {
                    Show-Notification "Scope ID does not exist." "Red"
                }
            } while ((-not (Test-IPAddress $ScopeId)) -or (-not $scopeExists))
            
            [Console]::SetWindowSize(95, 30)
            
            $optionsMenu = $true
            while ($optionsMenu) {
                Clear-Host
                foreach ($line in $option7) {
                     Write-Host (Center-Text $line) -ForegroundColor Cyan 
                }
                
                $OptionChoice = Read-Host "`n ♀ Enter your choice"
                
                switch ($OptionChoice) {
                    "1" {
                        Clear-Host
                        Write-Host "`n Configure Default Gateway" -ForegroundColor Cyan
                        do {
                            $gatewayIp = Read-Host "`n Enter the gateway IP address"
                            if (-not (Test-IPAddress $gatewayIp)) {
                                Show-Notification "Invalid IP address format." "Red"
                            }
                        } while (-not (Test-IPAddress $gatewayIp))
                        
                        try {
                            Set-DhcpServerv4OptionValue -ScopeId $ScopeId -OptionId 3 -Value $gatewayIp
                            Show-Notification "Default gateway set successfully." "Green"
                        } catch {
                            Show-Notification "Error setting default gateway: $_" "Red"
                        }
                    }
                    "2" {
                        Clear-Host
                        Write-Host "`n Configure DNS Server" -ForegroundColor Cyan
                        do {
                            $dnsServer = Read-Host "`n Enter the DNS server IP address"
                            if (-not (Test-IPAddress $dnsServer)) {
                                Show-Notification "Invalid IP address format." "Red"
                            }
                        } while (-not (Test-IPAddress $dnsServer))
                        
                        try {
                            Set-DhcpServerv4OptionValue -ScopeId $ScopeId -OptionId 6 -Value $dnsServer
                            Show-Notification "DNS server set successfully." "Green"
                        } catch {
                            Show-Notification "Error setting DNS server: $_" "Red"
                        }
                    }
                    "3" {
                        Clear-Host
                        Write-Host "`n Configure Domain Name" -ForegroundColor Cyan
                        $domainName = Read-Host "`n Enter the domain name"
                        
                        try {
                            Set-DhcpServerv4OptionValue -ScopeId $ScopeId -OptionId 15 -Value $domainName
                            Show-Notification "Domain name set successfully." "Green"
                        } catch {
                            Show-Notification "Error setting domain name: $_" "Red"
                        }
                    }
                    "4" {
                        Clear-Host
                        Write-Host "`n Configure Lease Duration" -ForegroundColor Cyan
                        
                        do {
                            $leaseDuration = Read-Host "`n Enter lease duration in days (1-365)"
                            if (-not [int]::TryParse($leaseDuration, [ref]$null) -or [int]$leaseDuration -lt 1 -or [int]$leaseDuration -gt 365) {
                                Show-Notification "Please enter a valid number between 1 and 365." "Red"
                            }
                        } while (-not [int]::TryParse($leaseDuration, [ref]$null) -or [int]$leaseDuration -lt 1 -or [int]$leaseDuration -gt 365)
                        
                        try {
                            $timeSpan = New-TimeSpan -Days ([int]$leaseDuration)
                            Set-DhcpServerv4Scope -ScopeId $ScopeId -LeaseDuration $timeSpan
                            Show-Notification "Lease duration set successfully." "Green"
                        } catch {
                            Show-Notification "Error setting lease duration: $_" "Red"
                        }
                    }
                    "0" {
                        $optionsMenu = $false
                    }
                    default {
                        Show-Notification "Invalid choice. Please try again." "Red"
                    }
                }
            }
        }
        
        "8" {
            Clear-Host
            Write-Host "`n DHCP Cleanup Utility" -ForegroundColor Cyan
            Write-Host " --------------------"
            Write-Host "`n WARNING: This will remove DHCP configurations" -ForegroundColor Red
            Write-Host "`n Select cleanup option:" -ForegroundColor Yellow
            Write-Host "`n 1. Remove specific scope"
            Write-Host " 2. Remove all scopes"
            Write-Host " 3. Uninstall DHCP service completely"
            Write-Host " 0. Return to main menu"
            
            $cleanupChoice = Read-Host "`n ♀ Enter your choice"
            
            switch ($cleanupChoice) {
                "1" {
                    Clear-Host
                    Write-Host "`n Available Scopes:" -ForegroundColor Yellow
                    Get-DhcpServerv4Scope | Format-Table -Property ScopeId, Name, State -AutoSize
                    
                    $ScopeToRemove = Read-Host "`n Enter Scope ID to remove"
                    
                    try {
                        Remove-DhcpServerv4Scope -ScopeId $ScopeToRemove -Force
                        Show-Notification "Scope removed successfully." "Green"
                    } catch {
                        Show-Notification "Error removing scope: $_" "Red"
                    }
                }
                "2" {
                    Clear-Host
                    Write-Host "`n Removing all DHCP scopes..." -ForegroundColor Yellow
                    $confirmation = Read-Host "`n Are you sure you want to remove ALL scopes? (Y/N)"
                    
                    if ($confirmation -eq "Y" -or $confirmation -eq "y") {
                        try {
                            Get-DhcpServerv4Scope | ForEach-Object {
                                Remove-DhcpServerv4Scope -ScopeId $_.ScopeId -Force
                            }
                            Show-Notification "All scopes removed successfully." "Green"
                        } catch {
                            Show-Notification "Error removing scopes: $_" "Red"
                        }
                    } else {
                        Show-Notification "Operation cancelled." "Yellow"
                    }
                }
                "3" {
                    Clear-Host
                    Write-Host "`n Uninstalling DHCP service..." -ForegroundColor Yellow
                    $confirmation = Read-Host "`n Are you sure you want to uninstall DHCP service? (Y/N)"
                    
                    if ($confirmation -eq "Y" -or $confirmation -eq "y") {
                        try {
                            # Stop service first
                            Stop-Service -Name DHCPServer -Force -ErrorAction SilentlyContinue
                            Show-Notification "DHCP Service stopped." "Yellow"
                            
                            # Remove the feature
                            Uninstall-WindowsFeature -Name DHCP -Remove
                            Show-Notification "DHCP service uninstalled successfully." "Green"
                        } catch {
                            Show-Notification "Error uninstalling DHCP service: $_" "Red"
                        }
                    } else {
                        Show-Notification "Operation cancelled." "Yellow"
                    }
                }
                "0" {
                    # Return to main menu
                }
                default {
                    Show-Notification "Invalid choice. Please try again." "Red"
                }
            }
        }
        
        "9" {
            Clear-Host
            Write-Host "`n DHCP Configuration Summary" -ForegroundColor Cyan
            
            Write-Host "`n DHCP Server Status:" -ForegroundColor Yellow
            Get-Service 'DHCPServer' -ErrorAction SilentlyContinue | Format-Table -Property Name, Status, DisplayName -AutoSize
            
            Write-Host "`n DHCP Scopes:" -ForegroundColor Yellow
            $scopes = Get-DhcpServerv4Scope -ErrorAction SilentlyContinue
            if ($scopes) {
                $scopes | Format-Table -Property ScopeId, Name, State, StartRange, EndRange, SubnetMask, LeaseDuration -AutoSize
                
                # Display option for detailed view of a specific scope
                Write-Host "`n Enter a Scope ID for detailed information or press Enter to continue"
                $detailScope = Read-Host
                
                if (-not [string]::IsNullOrWhiteSpace($detailScope)) {
                    Clear-Host
                    Write-Host "`n Scope Details for $detailScope" -ForegroundColor Cyan
                    
                    Write-Host "`n Scope Properties:" -ForegroundColor Yellow
                    Get-DhcpServerv4Scope -ScopeId $detailScope | Format-List
                    
                    Write-Host "`n Scope Options:" -ForegroundColor Yellow
                    Get-DhcpServerv4OptionValue -ScopeId $detailScope | Format-Table -AutoSize
                    
                    Write-Host "`n Exclusion Ranges:" -ForegroundColor Yellow
                    Get-DhcpServerv4ExclusionRange -ScopeId $detailScope | Format-Table -AutoSize
                    
                    Write-Host "`n Press Enter to continue..."
                    Read-Host
                }
            } else {
                Write-Host "`n No DHCP scopes found." -ForegroundColor Yellow
            }
        }
        
        "10" {
            Clear-Host
            Write-Host "`n Exiting script..." -ForegroundColor Red
            Start-Process "https://github.com/j0oyboy"
            Start-Sleep -Seconds 1
            exit
        }

        default {
            Show-Notification "Invalid choice. Please select a valid option." "Red"
        }
    }
}