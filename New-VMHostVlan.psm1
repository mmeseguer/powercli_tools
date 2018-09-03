function New-VMHostVlan {
    <#
    .SYNOPSIS
    Creates a range of VLANs (Virtual Port Groups) to an ESXi server
    
    .DESCRIPTION
    Long description
    
    .EXAMPLE
    An example
    
    .NOTES
    General notes
    #>

    [CmdletBinding()]
    param (
        # IP or DNS name of the VIServer. If already connected to a VIServer this parameter will be ignored.
        [string]$Server
)
}
#############################
## Nombre: Creacion_VLANS.ps1
## Descripción: Crea VLANs en un rango especificado en un host ESXi, con la nomenclatura de beServices.
## IMPORTANTE: Crea estas VLANs en vSwitch0, si las queremos en otro vSwitch hay que editar la variable $vswitch con el deseado.
## Versión: 1.0
#############################

##### Variables fijas ####
$vswitch = "vSwitch0"

#### Obtenemos variables ####
# Variables de conexión
#$server = Read-Host -Prompt "Introduce IP de host ESXi"
$user = Read-Host -Prompt "Introduce usuario de host ESXi"
$password = Read-Host -Prompt "Introduce password de host ESXi" -AsSecureString
#$servers= 109..112

# Variables de VLANs
Write-Output = "Este script crea VLANs dentro de un rango."
$vlan_inicial = Read-Host -Prompt "Introduce VLAN inicial (esta también se creará)"
$vlan_final = Read-Host -Prompt "Introduce VLAN final (esta también se creará)"

#### Cuerpo del script ####
# Conectamos con el nodo ESXi
ForEach ($server in $servers) {
    Connect-VIserver "192.168.100.$server" -User $user -Password ([Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)))
    # Creamos VLANs dentro del rango introducido
    for ($i=[int]$vlan_inicial; $i -le [int]$vlan_final; $i++) {
        New-VirtualPortGroup -VirtualSwitch $vswitch -Name VLAN$i -VlanID $i
    }
    Disconnect-VIServer -Force -Confirm:$false
    }