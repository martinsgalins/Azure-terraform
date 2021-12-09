Install-WindowsFeature -name Web-Server -IncludeManagementTools
Set-Content -Path C:\Inetpub\wwwroot\iisstart.html -value "Hello World!"
