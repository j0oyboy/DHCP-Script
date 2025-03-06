[console]::SetWindowSize(100, 30)

# Function to center text in the console
function Center-Text($text) {
    $width = [console]::WindowWidth
    $padLeft = [math]::Max(0, ($width - $text.Length) / 2)
    return (' ' * $padLeft) + $text
}

# Banner
$banner = @(
    "██████╗ ██╗  ██╗ ██████╗██████╗ ",     
    "██╔══██╗██║  ██║██╔════╝██╔══██╗",    
    "██║  ██║███████║██║     ██████╔╝",    
    "██║  ██║██╔══██║██║     ██╔═══╝ ",     
    "██████╔╝██║  ██║╚██████╗██║     ",         
    "╚═════╝ ╚═╝  ╚═╝ ╚═════╝╚═╝     ",         
    "",                                
    ""                                
)

# Display Banner
clear
foreach ($line in $banner) {
    Write-Host (Center-Text $line) -ForegroundColor Yellow
}

# Install DHCP Server
Write-Host " Installing DHCP..."
Install-WindowsFeature -Name DHCP -IncludeManagementTools -Verbose

# Check if DHCP is installed
clear
foreach ($line in $banner) { Write-Host (Center-Text $line) -ForegroundColor Cyan }
Write-Host "[+] Checking the DHCP service..."
$CheckDHCP = Get-WindowsFeature -Name DHCP
if ($CheckDHCP.Installed) {
    Write-Host "[+] The service is installed" -ForegroundColor Green
} else {
    Write-Host "[-] The Service is not installed" -ForegroundColor Red
}

# Check if the DHCP service is running
start-sleep 1
clear
foreach ($line in $banner) { Write-Host (Center-Text $line) -ForegroundColor Cyan }
Write-Host " Checking if Service DHCP is running..."
Get-Service 'DHCPServer'

# Restart the DHCP service
clear
foreach ($line in $banner) { Write-Host (Center-Text $line) -ForegroundColor Cyan }
Write-Host " Restarting DHCP Service..."
Restart-Service DHCPServer

# Add the server to the security group
Add-DhcpServerSecurityGroup

# Add a DHCP scope
clear
foreach ($line in $banner) { Write-Host (Center-Text $line) -ForegroundColor Cyan }
$scopeInput = Read-Host " Enter The Scope name"
$startRangeInput = Read-Host " Enter The start of range"
$endRangeInput = Read-Host " Enter The end of range"
$subnetInput = Read-Host " Enter The subnet of the sub network"

Add-DhcpServer4Scope -Name $scopeInput -StartRange $startRangeInput -EndRange $endRangeInput -SubnetMask $subnetInput -State Active

Write-Host "------------------------------------------------------------"

# Exclude a range of addresses
clear
foreach ($line in $banner) { Write-Host (Center-Text $line) -ForegroundColor Cyan }
$networkInput = Read-Host " Enter The Sub Network"
$startExclud = Read-Host " Enter the Start of the excluded range"
$endExclud = Read-Host " Enter the End of the excluded range"

Add-DhcpServer4ExclusionRange -ScopeId $networkInput -StartRange $startExclud -EndRange $endExclud 

# DHCP Options
$scopeId = (Get-DhcpServer4Scope | Where-Object { $_.Name -eq $scopeInput }).ScopeId
$gatewayIp = Read-Host " Enter the Gateway of the Network"
$dnsServer = Read-Host " Enter the DNS IP"

Set-DhcpServer4OptionValue -ScopeId $scopeId -OptionId 3 -Value $gatewayIp
Set-DhcpServer4OptionValue -ScopeId $scopeId -OptionId 6 -Value $dnsServer
Set-DhcpServer4OptionValue -ScopeId $scopeId -OptionId 15 

Write-Host "------------------------------------------------------------"
