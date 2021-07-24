$shell = New-Object -ComObject Wscript.Shell

#it will not ask confirmation o user and user will not have to press Y and enter
#we do have a force option but this is nice example for any such script

Set-ExecutionPolicy Unrestricted | Write-Output $shell.sendkeys("Y`r`n")