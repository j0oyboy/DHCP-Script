# Script v3
chcp 65001 > $null

$host.UI.RawUI.WindowTitle = "DHCP Script"


# Change the Window Size
[Console]::SetWindowSize(95, 33)

# Function to center text in the console
function Center-Text($text) {
    $width = [console]::WindowWidth
    $padLeft = [math]::Max(0, ($width - $text.Length) / 2)
    return (' ' * $padLeft) + $text
}


$Banner = @(
    " ",
    " ",
    "██████╗ ██╗  ██╗ ██████╗██████╗    ███████╗ ██████╗██████╗ ██╗██████╗ ████████╗ ",
    "██╔══██╗██║  ██║██╔════╝██╔══██╗   ██╔════╝██╔════╝██╔══██╗██║██╔══██╗╚══██╔══╝ ",
    "██║  ██║███████║██║     ██████╔╝   ███████╗██║     ██████╔╝██║██████╔╝   ██║    ",
    "██║  ██║██╔══██║██║     ██╔═══╝    ╚════██║██║     ██╔══██╗██║██╔═══╝    ██║    ",
    "██████╔╝██║  ██║╚██████╗██║        ███████║╚██████╗██║  ██║██║██║        ██║    ",
    "╚═════╝ ╚═╝  ╚═╝ ╚═════╝╚═╝        ╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝╚═╝        ╚═╝    ",
    "                                                                          	    by Souhaib",
    " "
)

$menu = @(
    " ",
    " 1. Installation service DHCP`n",
    "2. Check the installation`n",
    " 3. Start the DHCP service`n",
    " 4. Add DHCP server to the security group`n",
    " 5. Create a Scope`n",
    " 6. Create a Exclution scope`n",
    " 7. Add option to the scope`n",
    " 8. Remove Everythink`n"
    " 9. Github`n",
    " 10. Exit The Script"
    " "
)
$option7 = @(
    " ",
    " 1. Add Gateway`n",
    " 2. Add Dns Server`n",
    " 0. Return to the script"
)

While ($true){
    clear

    # Loop every line in the banner and print (color ('Red')
    foreach ($line in $Banner){
        Write-host (Center-Text $line) -ForegroundColor DarkRed
    } 
    
    # Loop every line in the menu
    foreach ($line in $menu){
        Write-Host (Center-Text $line) -ForegroundColor Yellow
    }
    
    # Choice
    $choice = Read-Host " ►  Enter your choice: "

    Switch ($choice)
    {        
        "1"{
             clear
             Write-Host "`n Start Installing DHCP service..."
             Install-WindowsFeature -Name DHCP -IncludeManagementTools -Verbose
        }

        "2"{
            clear
            Write-Host "`n Checking The DHCP service..."
            
            $CheckSDhcp = Get-WindowsFeature -Name DHCP 
            if ($CheckSDhcp.Installed){
                Write-Host "`n [+] The Service is installed sesuccessfully" -ForegroundColor Red
            } else
            {
                Write-Host "`n [-] The service is not instaleld" -ForegroundColor Green
            }

            Start-Sleep 1
        }
        
        "3"{
            clear
            Write-Host "`n Starting the DHCP service..."
               
            Write-host "`n Checking the service if is Started..." -ForegroundColor Cyan
            Get-Service 'DHCPServer'
            Start-Sleep 1
        }

        "4"{
            clear
            Write-Host "`n Adding the DHCP server to the security group..."
            Add-DhcpServerSecurityGroup
            Start-sleep 2
        }
        
        "5"{
            clear
            Write-Host "`n Start Creating the Scope..."
            # User Inputs
            $ScopeName = Read-Host "`n Enter the scope Name: "
            $SubnetIp = Read-Host "`n Enter your IP address (ex: 192.168.1.0): "
            $SubnetMask = Read-Host "`n Enter your Subnet Mask (ex: 255.255.255.0): "
            $StartRange = Read-Host "`n Enter the start of the scope: "
            $EndRange = Read-Host "`n Enter the End of the scope: "

            Add-DhcpServer4Scope -Name $ScopeName -StartRange $StartRange -EndRange $EndRange -SubnetMask $SubnetMask

        }

        "6"{
            clear
            Write-Host "`n Start Creating the Exclution scope..."

            $StartExcl = Read-Host "`n Enter the Start of the excluded range: "
            $EndExcl = Read-Host "`n Enter the End of the excluded range: "

            Add-DhcpServerv4ExclusionRange -Name $ScopeName -StartRange $StartExcl -EndRange $EndExcl
        }
        "7"{
            clear
            [Console]::SetWindowSize(51, 15)
            foreach ($line in $option7) {
                 Write-Host (Center-Text $line) -ForegroundColor Cyan 
            }
            
            $OptionChoice = Read-Host "`n ♥ "
            if ($OptionChoice -eq "1"){
                    clear
                    $gatewayIp = Read-Host "`n Enter the Gateway of the Network: "
                    $dnsServer = Read-Host "`n Enter the DNS IP: "
                    
                    Add-DhcpServer4Option -ScopeId $ScopeName -OptionId 3 -Value $gatewayIp
            }
            if ($OptionChoice -eq "2"){
                clear
                Add-DhcpServer4Option -ScopeId $ScopeName -OptionId 6 -Value $dnsServer

            } if ($OptionChoice -eq "0") {
                clear
                [Console]::SetWindowSize(95, 33)
                #foreach ($line in $Banner){  Write-host (Center-Text $line) -ForegroundColor DarkRed }
            } else {
                clear
                Write-Host "`n 3elach Berakti adak Zaml Kherj..." 
                Start-Sleep 2
                exit
            }
        }
        "8"{
            clear
            Write-Host "`n Start Removing DHCP stuf..." -ForegroundColor Yellow

            Write-Host " -------------------------------------------"

            Write-Host "`n Start Removing the DHCP package..." -ForegroundColor Yellow
            Uninstall-WindowsFeature -Name DHCP -Remove > $null  2>&1
            Write-Host "`n the DHCP package remove Successfully." -ForegroundColor Red
            start-sleep 1

            Write-Host " -------------------------------------------"
            Write-Host " Stopping DHCP service:.."
            Stop-Service -Name DHCPServer -Force
            Write-Host "`n DHCP Service Stopped." -ForegroundColor Red
            start-sleep 1

            Write-Host " -------------------------------------------"
            Write-Host "`n Removing The DHCP Scopes..." -ForegroundColor yellow
            Remove-DhcpServerv4Scope -ScopeId $SubnetIp -Confirm:$false
            Write-Host "`n Scope Removed successfully..." -ForegroundColor Red
            start-sleep 1

            Write-Host " -------------------------------------------"

            Write-Host " Removing The DHCP Exclution Scopes." -ForegroundColor Yellow
            Remove-DhcpServerv4ExclusionRange -ScopeId $SubnetIp -StartRange $StartExcl -EndRange $EndExcl -Confirm:$false
            Write-Host "`n Scope Removed successfully..." -ForegroundColor Red
            start-sleep 1

            Write-Host " -------------------------------------------"

            Write-Host " Checking..."
            Get-DhcpServerv4Scope
            Get-DhcpServerv4ExclusionRange -ScopeId $SubnetIp
            start-sleep 3

        }
        "9"{
            clear
            Write-Host "`n Starting Github..."
            start https://github.com/j0oyboy
            Start-Sleep 1
        }

        "10"{
            clear
            Write-Host "`n Exiting The script..." -ForegroundColor Cyan
            Start-Sleep 1
            exit
        }

    }

    # Stop the code for 6 seconds
    #Start-Sleep 1
}