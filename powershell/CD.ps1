function cd {
<#
.Synopsis
   Change Directory/Folder
.DESCRIPTION
   Change CD behaviour to honor Windows Shortcuts and 
   defaults to the HOME directory if invoked without a target. 
.EXAMPLE
   cd mylink.lnk
.EXAMPLE
   cd
#>
    [CmdletBinding()]
    [OutputType([int])]
    Param (
        # TARGET = Path to destination
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $Target = $HOME
    )

    Begin { remove-item alias:cd -force -ErrorAction 0  }
    
    Process {
        if($target.EndsWith(".lnk")){ 
            $sh = new-object -com wscript.shell 
            $fullpath = (resolve-path $target).Path 
            $targetpath = $sh.CreateShortcut($fullpath).TargetPath 
            set-location $targetpath 
        } else { 
            set-location $target 
        }
    }
    
    End { }
}
