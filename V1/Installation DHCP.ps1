Write-Host "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
Write-Host " Script For Administration DHCP "
Write-Host "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

Write-Host "Installing Dhcp..."

Install-WindowsFeature -Name DHCP -IncludeManagementTools -Verbose

# Check the dhcp is isntall
clear
Write-Host "Checking the DHCP service"


$CheckDHCP = Get-WindowsFeature	-Name DHCP
if ($CheckDHCP.Installed) {
	Write-Host "The service is installed" -ForegroundColor Green
} else {
	Write-Host "The Service is not installed" -ForegroundColor Red
}

# Check If the service DHCP is Run
clear
Write-Host "Checking if Service DHCP is running..."

Get-service 'DHCPServer'

# Restart The service
clear
Write-host "Restart Service DHCP..."
Restart-Service DHCPServer

# Add a server to security group
Add-DhcpServerSecurityGroup


# Add a scope of address
#Inputs 
clear
$scopeInput = Read-Host "Enter The Scoop name: "
$startRangeInput = Read-Host "Enter The start of range: "
$endRangeInput = Read-Host "Enter The end of range: "
$subnetInput = Read-Host "Enter The subnet of the sub network: "

Add-DhcpServer4Scope -Name $scopInput -StartRange $startRangeInput -EndRange $endRangeInput -SubnetMask $subnetInput -State Active

Write-host "------------------------------------------------------------"

# Exclud a range of addresses
clear
$networkInput = Read-Host "Enter The Sub Network: "
$startExclud = Read-Host "Enter the Start of the  excluded range"
$endExclud = Read-Host "Enter the End of the excluded range"

Add-DhcpServer4ExclusionRange -ScopeId $networkInput -StartRange $startExclud -EndRange $endExclud 

# DHCP Option
$scopeId = Get-DhcpServer4Scope | Where-Object {$_.Name -eq $scopeInput} | Select-Object -ExcludeProperty ScopeId
$gatewayIp = Read-Host "Enter the Gateway of the Network: "
$dnsServer = Read-Host "Enter the DNS ip: "

Set-DhcpServer4OptionValue -ScopeId $scopeId -OptionId 3 -Value $gatewayIp
Set-DhcpServer4OptionValue -ScopeId $scopeId -OptionId 6 -Value $dnsServer
Set-DhcpServer4OptionValue -ScopeId $scopeId -OptionId 15 