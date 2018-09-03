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

    begin {
        # Initialize disconnect flag.
        $disconnect = $false

        # If not connected to VIServer and no server is specified drop error.
        if (!$global:defaultviserver -and !$Server)
        {
            Write-Error 'You are not connected to any server, you must connect to an ESXi Server or specify one.' -ErrorAction Stop
        }
        # If not connected to VIServer but a server is specified we try to connect
        elseif (!$global:defaultviserver) {
            try {
                Connect-VIServer -Server $Server -ErrorAction Stop | Out-Null
                $disconnect = $true
                Write-Verbose "Connected to $Server."
            }
            catch {
                # If we cannot connect to VIServer drop error
                Write-Error "Error trying to connect to $Server." -ErrorAction Stop
            }            
        }
        else {
            Write-Verbose "Using already connected {$global:defaultviserver.Name}."
        }
        # If connected to a product that is not ESXi drop error
        if ($global:defaultviserver.ProductLine -ne "embeddedEsx") {
            Write-Error "You must connect to an ESXi server." -ErrorAction Stop
        }
    }
    process {
        
    }
    end {
        # Disconnect VIServer if connection was stablished by this function.
        if ($disconnect) {
            Disconnect-VIServer -Confirm:$false    
        }
    }
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