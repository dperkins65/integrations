<#
accelerate.ps1

Description: Assigns a storage policy to all VMDKs of a provided VM UUID. Useful
for triggering policy changes from monitoring tools.

Created: 11/10/16
Author: Daniel Perkins
Reference:
Prerequisites: VMware vSphere PowerCLI

Example:

.\Accelerate.ps1 -UUID 00000000-0000-0000-000000000000

Disclaimer:

The script is provided "as-is," without any warranty, express or implied, of accuracy,
completeness, merchantability, fitness for a particular purpose, title or non-infringement,
or any other warranty, and none of the code or information provided is recommended,
supported or guaranteed by Infinio. Your use of the script shall be at your sole risk.

Infinio shall not be liable for any loss, injury, or damages you may sustain by using
the script, whether direct, indirect, special, incidental, or consequential, even if
Infinio has been advised of the possibility of such damages.

The script is not covered by Infinio’s standard support guidelines nor will it
necessarily be supported, configured, customized, maintained, or updated by Infinio.
#>

# Read in UUID parameter
param ([Parameter(Mandatory=$True)][string]$UUID)
Write-Host ("Received UUID from alert: " + $UUID)

Add-PSSnapin VMware.VimAutomation.Core
Import-Module VMware.VimAutomation.Storage

# vSphere environment parameters
$VcenterServer = ""
$Username = ""
$Password = ""
$StoragePolicy = "Infinio Accelerator Storage Policy"

# Connect to the vCenter server
Connect-VIServer -Server $VcenterServer -User $Username -Password $Password
Write-Host "Connected to vCenter server.."

# Get required objects
Get-VM | Foreach ($_) {If ((Get-View $_.Id).config.uuid -eq $UUID) {$VM = ($_)}}
If (-Not $VM) {Throw "No VM with UUID: " + $UUID}
Else {"Found VM '" + $VM + "' with UUID: " + $UUID}
$HD = Get-HardDisk -VM $VM
Write-Host ("Found hard disks: " + $HD)

# Set the Infinio Accelerator storage policy
Set-SpbmEntityConfiguration $VM -StoragePolicy $StoragePolicy
Foreach ($i in $HD) {Set-SpbmEntityConfiguration $i -StoragePolicy $StoragePolicy}
Write-Host ("Storage policy now set to: " + $StoragePolicy)
