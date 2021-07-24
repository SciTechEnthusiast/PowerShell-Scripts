#region external-code

# Below is the script taken from respective links
# Thanks to all those awesome people who worked on them. :)


<#source : https://gist.github.com/dend/5ae8a70678e3a35d02ecd39c12f99110#>
function Show-Notification {
    [cmdletbinding()]
    Param (
        [string]
        $ToastTitle,
        [string]
        [parameter(ValueFromPipeline)]
        $ToastText
    )

    [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null
    $Template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText02)

    $RawXml = [xml] $Template.GetXml()
    ($RawXml.toast.visual.binding.text|Where-Object {$_.id -eq "1"}).AppendChild($RawXml.CreateTextNode($ToastTitle)) > $null
    ($RawXml.toast.visual.binding.text|Where-Object {$_.id -eq "2"}).AppendChild($RawXml.CreateTextNode($ToastText)) > $null

    $SerializedXml = New-Object Windows.Data.Xml.Dom.XmlDocument
    $SerializedXml.LoadXml($RawXml.OuterXml)

    $Toast = [Windows.UI.Notifications.ToastNotification]::new($SerializedXml)
    $Toast.Tag = "PowerShell"
    $Toast.Group = "PowerShell"
    $Toast.ExpirationTime = [DateTimeOffset]::Now.AddSeconds(10)

    $Notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("PowerShell")
    $Notifier.Show($Toast);
}

<#source: https://stackoverflow.com/questions/7690994/running-a-command-as-administrator-using-powershell#>
#slightly modified
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-windowstyle hidden -NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; Start-Sleep -s 15; exit}

#endregion


# Run below line  
# Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-windowstyle hidden -NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; Start-Sleep -s 15; exit}

$camera=Get-PnpDevice -FriendlyName "*HD User Facing*" -Class "Camera" -ErrorAction SilentlyContinue;
$status="Unknown";

if($camera){
    switch($camera.Status){
        "OK" {  Disable-PnpDevice -InstanceId $camera.InstanceId -Confirm:$false;$status="Disabled";break}
        default {Enable-PnpDevice -InstanceId $camera.InstanceId -Confirm:$false; $status="Enabled";}
    }
}else{
    $status="camera not found"
}

Show-Notification "Camera Status" $status ;



