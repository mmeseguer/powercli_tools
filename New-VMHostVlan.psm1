function New-VMHostVlan {
    <#
    .SYNOPSIS
    Creates a range of VLANs (Virtual Port Groups) in bulk to an ESXi server.
    
    .DESCRIPTION
    This function creates VLANs (Virtual Port Groups) in bulk to an ESXi server.
    You must provide a numeric $First VLAN and, if you want to create a range of VLANs, a numeric $End should be provided too.
    
    .PARAMETER Start
    First number of VLAN to create.

    .PARAMETER End
    Last number of VLAN to create. If not specified it just create the one of Start parameter.

    .PARAMETER Server
    IP or DNS name of the VIServer. If already connected to a VIServer this parameter will be ignored.

    .PARAMETER Vswitch
    vSwitch where to create the VLAN/s. Defaults to 'vSwitch0'

    .PARAMETER Prefix
    Prefix of the VLAN name. Defaults to 'VLAN'.

    .EXAMPLE
    New-VMHostVlan -Start 100 -End 150 -Server 192.168.168.168 -Vswitch 'vSwitch0'
    #>

    [CmdletBinding()]
    param (
        # First VLAN to create
        [Parameter(Mandatory=$true)]
        [int]$Start,
        # Ending VLAN to create (if not specified we make it's value the same as the $Start to just create one)
        # Validate that it's bigger than $Start VLAN
        [ValidateScript({if ($Start -le $_){$true}})]
        [int]$End=$Start,
        # IP or DNS name of the VIServer. If already connected to a VIServer this parameter will be ignored.
        [string]$Server,
        # Virtual Switch to create the VLANs (by default vSwitch0)
        [string]$Vswitch='vSwitch0',
        # Prefix to use in the name of the VLAN
        [string]$Prefix='VLAN'
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
        # Loop through the range and create the VLANs
        for ($i=$Start; $i -le $End; $i++) {
            New-VirtualPortGroup -VirtualSwitch $Vswitch -Name $Prefix$i -VlanID $i
        }
    }
    end {
        # Disconnect VIServer if connection was stablished by this function.
        if ($disconnect) {
            Disconnect-VIServer -Confirm:$false    
        }
    }
}