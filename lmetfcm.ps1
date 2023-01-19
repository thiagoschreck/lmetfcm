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
    "SUCCESS" { $ForegroundColor = "Green" }
    "ERROR" { $ForeGroundColor = "Red" }
    "WARNING" { $ForeGroundColor = "Yellow" }
    Default { $ForeGroundColor = "Red" }
  }
  Write-Host ("[$Result] $Message") -ForegroundColor $ForegroundColor
}

function Exit-WithErrorMessage {
  param (
    $Message
  )
  Write-ResultMessage -Result "ERROR" -Message $Message
  Set-Location -Path $PsScriptRoot
  Exit
}

function Confirm-StringIsNullOrEmpty {
  param (
    $String
  )
  return $null -eq $String -Or ("" -eq $String)
}

function Add-ContextMenuItem {
  $KeyToAdd = Read-Host -Prompt 'Insert the name of the key to add'
  $KeyPath = ("$ContextMenuBasePath\$KeyToAdd")
  if (Test-Path $KeyPath) {
    Exit-WithErrorMessage -Message ("Key name `"$KeyToAdd`" already exists")
  }
  $MenuName = Read-Host -Prompt 'Insert the context menu name'
  if (Confirm-StringIsNullOrEmpty -String $MenuName) { 
    Exit-WithErrorMessage -Message "Menu name was not specified" 
  }
  $ProgramPath = Read-Host -Prompt 'Insert the path of the program'
  if (Confirm-StringIsNullOrEmpty -String $ProgramPath) { 
    Exit-WithErrorMessage -Message "Program path was not specified" 
  }
  New-Item -Path $ContextMenuBasePath -Name $KeyToAdd | Out-Null
  New-ItemProperty -Path $KeyPath -Name "(Default)" -Value $MenuName -PropertyType "String" | Out-Null
  New-ItemProperty -Path $KeyPath -Name "Icon" -Value $ProgramPath -PropertyType "String" | Out-Null
  New-Item -Path ("$KeyPath") -Name "command" | Out-Null
  New-ItemProperty -Path ("$KeyPath\command") -Name "(Default)" -Value ("`"$ProgramPath`" `"%V`"") -PropertyType "String" | Out-Null
  Write-ResultMessage -Result "SUCCESS" -Message ("Successfully added key $KeyToAdd")
}

function Remove-ContextMenuItem {
  $KeyToRemove = Read-Host -Prompt 'Insert the name of the key to remove'
  if (Confirm-StringIsNullOrEmpty -String $KeyToRemove) {
    Exit-WithErrorMessage -Message "Key name was not specified"
  }
  Remove-Item -Path ($ContextMenuBasePath + "\" + $KeyToRemove)
  Write-ResultMessage -Result "SUCCESS" -Message ("Successfully removed key $KeyToRemove")
}

function Rename-ContextMenuItem {
  # TODO Check if original key exists
  $KeyToRename = Read-Host -Prompt 'Insert the name of the key to rename'
  if (Confirm-StringIsNullOrEmpty -String $KeyToRename) {
    Exit-WithErrorMessage -Message "Key name was not specified"
  }
  $NewKeyName = Read-Host -Prompt 'Insert the new name for the key'
  if (Confirm-StringIsNullOrEmpty -String $NewKeyName) {
    Exit-WithErrorMessage -Message "New name was not specified" 
  }
  Rename-Item -Path ($ContextMenuBasePath + "\" + $KeyToRename) $NewKeyName
  Write-ResultMessage -Result "SUCCESS" -Message ("Successfully renamed key from $KeyToRename to $NewKeyName")
}

function Init {
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

  switch ($Option) {
    "get" { } # TODO
    "add" { Add-ContextMenuItem }
    "remove" { Remove-ContextMenuItem }
    "rename" { Rename-ContextMenuItem }
    Default { Exit-WithErrorMessage -Message "Invalid argument(s)." }
  }
}

Init

# Return to original path
Set-Location -Path $PsScriptRoot