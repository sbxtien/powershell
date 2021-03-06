function Prevent-IseExecution ()
{
<#
  .SYNOPSIS
  Prevents a script from executing any further if it's in the ISE
  
  .DESCRIPTION
  The function determines whether it's running in the ISE or a window, 
  if it's in the ISE it breaks, causing further execution of the script to halt. 
#>

  # If we're in the PowerShell ISE, there will be a special variable
  # named $PsIse. If it's null, then we're in the command prompt
  if ($psise -ne $null)
  {
    "You cannot run this script inside the PowerShell ISE. Please execute it from the PowerShell Command Window."
    break # The break will bubble back up to the parent
  }

}

# Stop the user if we're in the ISE
Prevent-IseExecution

# Code will only continue if we're in command prompt
"I must not be in the ISE"