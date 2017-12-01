
function Get-FullName {
    [CmdletBinding()]
    param (
        # Title String 
        [Parameter(
            mandatory=$true)]
        [string]
        $Name
    )

    begin {
        [regex]$Regex = "^(?<day>\d{2})(?<month>\d{2})"
    }
    
    process {
        [VOID]($Name -match $Regex)
        $Month = (Get-Culture).DateTimeFormat.GetMonthName($Matches.month)
        $Day = $Matches.day
        "Episode of {0,9}, {1:N}" -f $Month, $Day
    }
    
    end {
    }
}

[URI]$URI = "http://www.rosariofiorello.com/podcast/puntate/"
$Response =  Invoke-WebRequest -URI $URI

Write-Host = $Response.GetType().Fullname

# Add an index property to the object 
[psobject]$Episodes = $Response.Links | 
    Where-Object href -Like *mp3 | 
    sort-object @{Expression={$_.href.Substring(2,2)}; Ascending = $true},@{Expression={$_.href.Substring(0,2)}; Ascending = $true} | 
    ForEach-Object {$i=1} {$_ | 
        Add-Member Index ($i++) -PassThru
    }

$Episodes = $Episodes | 
    Select-Object @{Name="#";Expression={$_.Index}}, @{Name="NAME";Expression={Get-FullName($_.href)}}, @{Name="LINK";Expression={"$URI$($_.href)"}}

$Episodes | Format-Table -Autosize

$Index = Read-Host "Please enter the index of the episode you want to play: "

if (($Index -gt 0) -and ($Index -le $Episodes.Length)) {
    [string]$Link = ($Episodes[$Index - 1]).LINK
    [string]$Player = "C:\Program Files (x86)\Windows Media Player\wmplayer.exe"
    Write-Host "Now Playing: $Link" -ForegroundColor Magenta
    Invoke-Expression "& `"$Player`" $Link"
}



