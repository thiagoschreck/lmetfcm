$Banner = @"
                                _____                                                                     
 _      __  __   ___   _____  /\  ___\  ___   __  __ 
| |    |  \/  | | __| |_   _| \ \  __\ / __| |  \/  |
| |__  | |\/| | | _|    | |    \ \_\  | (__  | |\/| |
|____| |_|  |_| |___|   |_|     \/_/   \___| |_|  |_|
                                                    
Kindly allow me to edit my own system's context menu.
-----------------------------------------------------
"@

$ContextMenuBasePath = "HKCU:\Software\Classes\directory\Background\shell"
$Option = $Args[0]

clear
Write-Host $Banner
Set-Location -Path $ContextMenuBasePath
Write-Host "Current context menus:"
Get-ChildItem

function Output-ResultMessage {
  param (
    $Result,
    $Message
  )
  $ForegroundColor = "White"
  if($Result -eq "SUCCESS") {
    $ForegroundColor = "Green"
  } 
  elseif($Result -eq "ERROR") {
    $ForeGroundColor = "Red"
  }
  else {
    $ForeGroundColor = "Red"
    Write-Host ("[ERROR] Value $Result is not a valid result")
  }

  Write-Host ("[$Result] $Message") -ForegroundColor $ForegroundColor
}

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
  New-Item -Path $ContextMenuBasePath -Name $KeyToAdd | Out-Null
  Add-ContextMenuItemProperty -KeyPath ("$ContextMenuBasePath\$KeyToAdd")
  Output-ResultMessage -Result "SUCCESS" -Message ("Successfully added key $KeyToAdd")
}

function Remove-ContextMenuItem {
  $KeyToRemove = Read-Host -Prompt 'Insert the name of the key to remove'
  if ( $KeyToRemove -ne $null -and $KeyToRemove -ne "") {
    Remove-Item -Path ($ContextMenuBasePath + "\" + $KeyToRemove)
    Output-ResultMessage -Result "SUCCESS" -Message ("Successfully removed key $KeyToRemove")
  }
  else {
    Output-ResultMessage -Result "ERROR" -Message "Key name was not specified"
  }
}

function Rename-ContextMenuItem {
  # TODO Check if original key exists
  $KeyToRename = Read-Host -Prompt 'Insert the name of the key to rename'
  if ( $KeyToRename -ne $null -and $KeyToRename -ne "") {
    $NewKeyName = Read-Host -Prompt 'Insert the new name for the key'
    if ( $NewKeyName -ne $null -and $NewKeyName -ne "") {
      Rename-Item -Path ($ContextMenuBasePath + "\" + $KeyToRename) $NewKeyName
      Output-ResultMessage -Result "SUCCESS" -Message ("Successfully renamed key from $KeyToRename to $NewKeyName")
    }
    else {
      Output-ResultMessage -Result "ERROR" -Message "New name was not specified"
    }
  }
  else {
    Output-ResultMessage -Result "ERROR" -Message "Key name was not specified"
  }
}

if ( $Option -eq "get" ) {
}
elseif ( $Option -eq "add" ) {
  Add-ContextMenuItem
}
elseif ( $Option -eq "remove" ) {
  Remove-ContextMenuItem
}
elseif ( $Option -eq "rename" ) {
  Rename-ContextMenuItem
}
else {
  Write-Host "else"
}

# Return to original path
Set-Location -Path $PsScriptRoot