Install-WindowsFeature -name Web-Server -IncludeManagementTools
Set-Content -Path C:\Inetpub\wwwroot\iisstart.htm -value "Hello World!"
