function Get-VMFolderStructure {
    <#
    .SYNOPSIS
    Lists VMware vCenter folder path.

    .DESCRIPTION
    With Get-VMFolderStructure you can get an array of the full path of all VMware vCenter's VM folders in order to recreate them in another vCenter Server.
    The result can be piped an exported to a file for future use.

    .EXAMPLE
    Get-VMFolderStructure | Out-File export.txt

    .NOTES
    General notes
    #>
    [CmdletBinding()]
    param (
         # IP or DNS name of the VIServer. If already connected to a VIServer this parameter will be ignored.
         [string]$Server
    )
        
    begin {
        # Initialize disconnect flag
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
        }
        else {
            Write-Verbose "Using already connected {$global:defaultviserver.Name}"
        }

    }
        
    process {
        # Declaration of special folder to not process them.
        $fexceptions = "Datacenters","vm","network","datastore","host"

        # Initialize export array.
        $fexport = @()
        # Get all "VM" folders that are not in exceptions.
        $folders = Get-Folder -Type VM | Where-Object {$_.Name -notin $fexceptions}

        # Loop through folders.
        ForEach ($folder in $folders) {
            # Build initial path.
            $fpath = $folder.name
            # Obtain parent folder.
            $fparent = $folder.Parent
            
            # Loop while a parent folder exist and is not an exception.
            while ($fparent -and $fparent -notin $fexceptions) {
                # Append parent to path.
                $fpath = "$fparent\$fpath"
                # Move fparent to its own parent.
                $fparent = $fparent.Parent
            }
            # Add the full path to our export array.
            $fexport += $fpath
        }
    }
        
    end {
        # Disconnect VIServer if connection was stablished by this module.
        if ($disconnect) {
            Disconnect-VIServer -Confirm:$false    
        }
        # Show sorted array of paths (for a correct recreation of folders).
        $fexport | Sort-Object
    }
    
}