#Quiz Answers

#First thing you need to discover is the TEMP folder. There’s an environment variable that covers just that:
$env:TEMP
C:\Temp


#Next job is to discover the folder total size, number of files and number of subfolders:
Get-ChildItem -Path $env:TEMP -Recurse -File | Measure-Object -Property length -Sum

#The Sum property contains the sum of the sizes (lengths) of the file. The Count property contains the number of files.
Get-ChildItem -Path $env:TEMP -Recurse -Directory | Measure-Object

#This time you only want the number of folders. Putting that together to create the report.
$files = Get-ChildItem -Path $env:TEMP -Recurse -File | Measure-Object -Property length -Sum 
$folders = Get-ChildItem -Path $env:TEMP -Recurse -Directory | Measure-Object 
$props = [ordered]@{ TimeStamp = Get-Date NumberOfFiles = $files.Count NumberofFolders = $folders.Count 'SizeofTemp(MB)' = [math]::Round(($files.Sum / 1MB), 3) } New-Object -TypeName PSobject -Property $props