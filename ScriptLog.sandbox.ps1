#Requires -Version 4

<#
.DESCRIPTION
Basic Script Log example
.EXAMPLE
.NOTES
Filename   : ScriptLog.sandbox.ps1
.NOTES
History
2015-11-19  Script file created
#>

Set-StrictMode -Version Latest


function Start-ScriptLog {
<#
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
[CmdletBinding()]
Param (
  [Parameter()]  #(Mandatory=$true)]
  #[ValidateScript()]
  [string]$ScriptLogPath = $(Split-Path -Path $Script:MyInvocation.MyCommand.Path -Parent)
)

Begin {
  "Script Log Path = '$ScriptLogPath'." | Write-Debug
  [string]$ScriptLogFileName = 

  $Script:ThisScript = New-Object -TypeName PSObject -Property @{LogFile = [System.IO.FileInfo]"$ScriptLogPath\"}
  $ThisScript.PSObject.TypeNames.Insert(0,'SQLAdmin.ScriptLog')

  $FileName = "{0:yyyy'-'MM'-'dd'T'HHmmss}" -f [System.DateTime]::UtcNow
}

Process {
}

End {}
}



#region Script

function New-ScriptLog {
  
  <#
  .DESCRIPTION
    Create and initialise new script log for the current execution of the script.
  .PARAMETER MsSql
    Custom object holding SQL Server installation metadata.
  .INPUTS
    (none)
  .OUTPUTS
    (none)
  .RETURNVALUE
    Script log file
  .LINKS
    MSDN Library: "FileInfo Class"
    https://msdn.microsoft.com/en-us/library/system.io.fileinfo.aspx
  .NOTES
    2015-11-26 (NGR) Function created.
  #>
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory=$true,ValueFromPipeLine=$true)]
    [System.IO.DirectoryInfo]$LogPath
  )
  
  Begin {
    #"{0:s}Z  ::  New-ScriptLog() : Create new script log." -f [System.DateTime]::UtcNow | Write-Verbose
  }
  
  Process {
    [System.IO.FileInfo]$script:ScriptLogFile = New-Item -Path $LogPath -Name ("InstallMsSql.{0:yyyyMMddThhmmssZ}.log" -f [System.DateTime]::UtcNow) -ItemType File -Force -ErrorAction Stop
  
    "Script Log file = '$($script:ScriptLogFile.FullName)'." | Write-Debug
  
    "Executing script '$($MyInvocation.ScriptName)' on the computer '${env:COMPUTERNAME}'." | Write-ScriptLog
    "Script execution is done by the user '${env:USERNAME}@${env:USERDNSDOMAIN}'." | Write-ScriptLog
  
    return $script:ScriptLogFile
  }
  
  End {}
  }  # New-ScriptLog()
  
  function Write-ScriptLog {
  <#
  .DESCRIPTION
    Write message in script log.
    Dependant on the type the message will also be send to other pipes.
  .PARAMETER Ms Sql
    Custom object holding SQL Server installation metadata.
  .PARAMETER Message
    User defined message in script execution.
  .PARAMETER Type
    Message type to other actions on the given message.
  .INPUTS
    (none)
  .OUTPUTS
    (none)
  .RETURNVALUE
    (none)
  .NOTES
    2015-11-26 (NGR) Function created.
  #>
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory=$true,ValueFromPipeLine=$true)]
    [string]$Message,
  
    [Parameter()]
    [ValidateSet('Error', 'Warning', 'Information', IgnoreCase=$false)]
    [string]$Type
  )
  
  Begin {
    #"{0:s}Z  ::  Write-ScriptLog() : Write given message to script log." -f [System.DateTime]::UtcNow | Write-Verbose
  }
  
  Process {
  
    "{0:s}Z  $Message" -f [System.DateTime]::UtcNow | Out-File -FilePath $script:ScriptLogFile -Append -NoClobber
  
    switch -CaseSensitive ($Type) {
      'Error' {
        "{0:s}Z  $Message" -f [System.DateTime]::UtcNow | Write-Error
      }
      'Warning' {
        "{0:s}Z  $Message" -f [System.DateTime]::UtcNow | Write-Warning
      }
    }
  }
  
  End {}
  }  # Write-ScriptLog()
  
  function Skip-Script {
  <#
  .DESCRIPTION
    Skip script execution.
  .PARAMETER ErrorMessage
    User defined description of reason to skip script.
  .INPUTS
    (none)
  .OUTPUTS
    (none)
  .RETURNVALUE
    (none)
  .NOTES
    2015-11-20 (NGR) Function created.
  #>
  [CmdletBinding()]
  Param(
    [Parameter(ValueFromPipeLine=$true)]
    [string]$ErrorMessage
  )
  
  Begin {
    "{0:s}Z  ::  Skip-Script() : Skip script execution. Script execution termination." -f [System.DateTime]::UtcNow | Write-Verbose
  }
  
  Process {
    if ($ErrorMessage.Length -gt 0) {
      $ErrorMessage | Write-ScriptLog -Type Error
    }
  
    "The execution of the script '$($MyInvocation.ScriptName)' is terminating." | Write-ScriptLog -Type Error
  
    exit  # Terminating script execution.
  }
  
  End {}
  }  # Skip-Script()
  
  #endregion Script
  

###  INVOCATION  ###


#region Test

#Split-Path -Path $Script:MyInvocation.MyCommand.Path -Parent | gm
$Script:MyInvocation.MyCommand | gm


#Start-ScriptLog -Verbose -Debug
<#
Start-ScriptLog : Cannot process argument transformation on parameter 'ScriptLogPath'.
  Cannot convert the "" value of type "System.String" to type "System.Management.Automation.ParameterAttribute".
At C:\Users\Niels\OneDrive\Scripts\ScriptLog.sandbox.ps1:55 char:1
#>

#endregion Test
