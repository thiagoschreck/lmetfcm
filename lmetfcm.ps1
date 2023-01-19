$Banner = @"
                                _____                                                                     
 _      __  __   ___   _____  /\  ___\  ___   __  __ 
| |    |  \/  | | __| |_   _| \ \  __\ / __| |  \/  |
| |__  | |\/| | | _|    | |    \ \_\  | (__  | |\/| |
|____| |_|  |_| |___|   |_|     \/_/   \___| |_|  |_|
                                                    
Kindly allow me to edit my own system's context menu.
-----------------------------------------------------`n
"@

$ContextMenuBasePath = "HKCU:\Software\Classes\directory\Background\shell"
$Option = $Args[0]

function Write-ResultMessage {
  param (
    $Result,
    $Message
  )
  $ForegroundColor = "White"
  switch ($Result) {
    "SUCCESS" { 
      $ForegroundColor = "Green"
    }
    "ERROR" {
      $ForeGroundColor = "Red"
    }
    "WARNING" {
      $ForeGroundColor = "Yellow"
    }
    Default {
      $ForeGroundColor = "Red"
      Write-Host ("[ERROR] Value $Result is not a valid result")
    }
  }

  Write-Host ("[$Result] $Message") -ForegroundColor $ForegroundColor
}

Clear-Host
Write-Host $Banner
if (Test-Path -Path $ContextMenuBasePath) {
  Set-Location -Path $ContextMenuBasePath
}
else {
  Write-ResultMessage -Result "WARNING" -Message ("Directory does not exist, creating $ContextMenuBasePath")
  New-Item -Path $ContextMenuBasePath -ItemType Directory
}
Write-Host "Current context menus:"
Get-ChildItem

function Add-ContextMenuItemProperty {
  param (
    $KeyPath
  )
  $MenuName = Read-Host -Prompt 'Insert the context menu name'
  $ProgramPath = Read-Host -Prompt 'Insert the path of the program'
  New-ItemProperty -Path $KeyPath -Name "(Default)" -Value $MenuName -PropertyType "String" | Out-Null
  New-ItemProperty -Path $KeyPath -Name "Icon" -Value $ProgramPath -PropertyType "String" | Out-Null
  New-Item -Path ("$KeyPath") -Name "command" | Out-Null
  New-ItemProperty -Path ("$KeyPath\command") -Name "(Default)" -Value ("`"$ProgramPath`" `"%V`"") -PropertyType "String" | Out-Null
}

function Add-ContextMenuItem {
  # TODO check if key exists beforehand
  $KeyToAdd = Read-Host -Prompt 'Insert the name of the key to add'
  if (Test-Path ("$ContextMenuBasePath\$KeyToAdd")) {
    Write-ResultMessage -Result "ERROR" -Message ("Key name `"$KeyToAdd`" already exists")
    Set-Location -Path $PsScriptRoot
    Exit
  }
  New-Item -Path $ContextMenuBasePath -Name $KeyToAdd | Out-Null
  Add-ContextMenuItemProperty -KeyPath ("$ContextMenuBasePath\$KeyToAdd")
  Write-ResultMessage -Result "SUCCESS" -Message ("Successfully added key $KeyToAdd")
}

function Remove-ContextMenuItem {
  $KeyToRemove = Read-Host -Prompt 'Insert the name of the key to remove'
  if ( $null -ne $KeyToRemove -and $KeyToRemove -ne "") {
    Remove-Item -Path ($ContextMenuBasePath + "\" + $KeyToRemove)
    Write-ResultMessage -Result "SUCCESS" -Message ("Successfully removed key $KeyToRemove")
  }
  else {
    Write-ResultMessage -Result "ERROR" -Message "Key name was not specified"
    Set-Location -Path $PsScriptRoot
    Exit
  }
}

function Rename-ContextMenuItem {
  # TODO Check if original key exists
  $KeyToRename = Read-Host -Prompt 'Insert the name of the key to rename'
  if ( $null -ne $KeyToRename -and $KeyToRename -ne "") {
    $NewKeyName = Read-Host -Prompt 'Insert the new name for the key'
    if ( $null -ne $NewKeyName -and $NewKeyName -ne "") {
      Rename-Item -Path ($ContextMenuBasePath + "\" + $KeyToRename) $NewKeyName
      Write-ResultMessage -Result "SUCCESS" -Message ("Successfully renamed key from $KeyToRename to $NewKeyName")
    }
    else {
      Write-ResultMessage -Result "ERROR" -Message "New name was not specified"
      Set-Location -Path $PsScriptRoot
      Exit
    }
  }
  else {
    Write-ResultMessage -Result "ERROR" -Message "Key name was not specified"
    Set-Location -Path $PsScriptRoot
    Exit   
  }
}

switch ($Option) {
  "get" { 
    # TODO
  }
  "add" { Add-ContextMenuItem }
  "remove" { Remove-ContextMenuItem }
  "rename" { Rename-ContextMenuItem }
  Default {
    Write-ResultMessage -Result "ERROR" -Message "Invalid argument(s)."
    Exit
  }
}

# Return to original path
Set-Location -Path $PsScriptRoot