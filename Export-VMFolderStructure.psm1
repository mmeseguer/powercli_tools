function Export-VMFolderStructure {
    <#
    .SYNOPSIS
    Exports an array of all VM Folders in a vCenter.

    .DESCRIPTION
    With Export-VMFolderStructure you can get an array of the full path of all VMware vCenter's VM folders in order to recreate them in another vCenter Server.
    The result can be piped an exported to a file for future use.

    .EXAMPLE
    Export-VMFolderStructure | Out-File export.txt

    .NOTES
    Name: Export-VMFolderStructure
    Author: Marc Meseguer
    Version 1.0
        - Initial release.
    #>
    [CmdletBinding()]
    param (
         # IP or DNS name of the VIServer. If already connected to a VIServer this parameter will be ignored.
         [string]$Server,
         # Datacenter name. If no datacenter specified and there's only one datacenter we use it.
         [string]$Datacenter,
         # Path to the file of the export
         [Parameter(Mandatory=$true)]
         [ValidateScript({Test-Path (Split-Path $_) -PathType Container})]
         [string]$Path
    )
        
    begin {
        # Initialize disconnect flag.
        $disconnect = $false

        # If not connected to VIServer and no server is specified drop error.
        if (!$global:defaultviserver -and !$Server)
        {
            Write-Error 'You are not connected to any server, you must connect to a vCenter Server or specify one.' -ErrorAction Stop
        }
        # If not connected to VIServer but a server is specified we try to connect
        elseif (!$global:defaultviserver) {
            try {
                Connect-VIServer -Server $Server -ErrorAction
                $disconnect = $true
                Write-Verbose "Connected to $Server"
            }
            catch {
                # If we cannot connect to VIServer drop error
                Write-Error "Error trying to connect to $Server" -ErrorAction Stop
            }            
        }
        else {
            Write-Verbose "Using already connected {$global:defaultviserver.Name}"
        }

        # If no Datacenter is specified we check if there's more than one
        if (!$Datacenter -and (Get-Datacenter).Count -ne 1){
            Write-Error "If there's more than one datacenter you have to select one."
        }

    }
        
    process {
        # Declaration of special folder to not process them.
        $fexceptions = "Datacenters","vm","network","datastore","host"
        
        # Initialize collection of paths
        $folder_collection = New-Object System.Collections.ArrayList

        # Get all "VM" folders that are not in exceptions.
        $folders = Get-Folder -Type VM | Where-Object {$_.Name -notin $fexceptions}

        # Loop through folders.
        ForEach ($folder in $folders) {
            # Initialize path.
            $fpath = ""
            # Obtain parent folder.
            $fparent = $folder.Parent
            
            # Loop while a parent folder exist and is not an exception.
            while ($fparent -and $fparent -notin $fexceptions) {
                # Append parent to path.
                $fpath = "$fparent\$fpath"
                # Move fparent to its own parent.
                $fparent = $fparent.Parent
            }
            # Set properties
            $folder_properties = @{
                Name = $folder.Name
                Path = $fpath
            }
            # Create object
            $folder_object = New-Object -TypeName PSObject -Property $folder_properties
            # Add object to collection
            $folder_collection.Add($folder_object) | Out-Null
        }
    }
        
    end {
        # Disconnect VIServer if connection was stablished by this function.
        if ($disconnect) {
            Disconnect-VIServer -Confirm:$false    
        }
        # Export sorted collection of paths (for a correct recreation of folders).
        $folder_collection | Sort-Object -Property Path | Export-Csv -Path $Path
    }
    
}
function Import-VMFolderStructure {
    [CmdletBinding()]
    param (
         # IP or DNS name of the VIServer. If already connected to a VIServer this parameter will be ignored.
        [string]$Server,
        # Path to the export file 
        [string]$Path
    )

    begin {
        # Initialize disconnect flag.
        $disconnect = $false

        # If not connected to VIServer and no server is specified drop error.
        if (!$global:defaultviserver -and !$Server)
        {
            Write-Error 'You are not connected to any server, you must connect to a vCenter Server or specify one.' -ErrorAction Stop
        }
        # If not connected to VIServer but a server is specified we try to connect
        elseif (!$global:defaultviserver) {
            try {
                Connect-VIServer -Server $Server -ErrorAction Stop
                $disconnect = $true
                Write-Verbose "Connected to $Server"
            }
            catch {
                # If we cannot connect to VIServer drop error
                Write-Error "Error trying to connect to $Server" -ErrorAction Stop
            }           
        
        # If path is not valid drop error
        
        }
        else {
            Write-Verbose "Using already connected {$global:defaultviserver.Name}"
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