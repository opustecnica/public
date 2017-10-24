<#
.Synopsis
   WLS ssh client wrapper.
.DESCRIPTION
   WLS ssh client wrapper.
   As of Win10 1703, WLS doesn't have the means to resolve hostnames 
   that end in .local nor .ms-home.net.  This wrapper attempts to address 
   issues related to connections to a Raspberry PI Zero connected via OTC
   whether the address to the USB interface is provided via APIPA or ICS.
.EXAMPLE
   ssh username@rpi0.local
.EXAMPLE
   ssh username@rpi0.ms-home.net:1234
#>
function Get-PSSsh {
    [CmdletBinding()]
    [Alias('ssh')]
    Param (
        # SSHHost
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $SSHHost
    )

    Begin {
        # Extract elements of the connection string.
        $Regex = "(?<UserName>[^:@]+)(?:@(?<SSHHost>[^:]+))?(?::(?<Port>\d+))?"
        try {
            [void]($SSHhost -match "$Regex")
            $UserName = $Matches.UserName
            $SSHHost = $Matches.SSHHost
            if ($Matches.Port) {
                $Port = $Matches.Port
            } else {
                $Port = 22
            }
        }
        catch{
            Write-Host "It seems the connection string is not properly formatted." -ForegroundColor Red
            Write-Host "    Example: UserName@[HostName|IPAddress]:[Port]"
        }
        # Is the Host in IP format?
        if ([void][ipaddress]$SSHHost) {
            # Do Nothing 
        } else {
            try {
                # Resolve hostname to IPv4
                $SSHHost = [System.Net.Dns]::GetHostAddresses($SSHHost).IPAddressToString
            }
            catch {
                # Quit if the the hostname cannot be resolved.
                Write-Host "$_.Exception" -ForegroundColor Red
            }
        }
    }
    Process {
        # Invoke WLS ssh client
        Invoke-Expression "bash -c 'ssh $($UserName)@$($SSHHost) -p $($Port)'"
    }
    End {
    }
}
