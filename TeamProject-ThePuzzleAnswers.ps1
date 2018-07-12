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
$props = [ordered]@{ TimeStamp = Get-Date; NumberOfFiles = $files.Count; NumberofFolders = $folders.Count; 'SizeofTemp(MB)' = [math]::Round(($files.Sum / 1MB), 3) }
New-Object -TypeName PSobject -Property $props


#One of the requirements was to log the information about the TEMP folder. You have an object as output so the easiest solution is to export the data to a CSV file.
$files = Get-ChildItem -Path $env:TEMP -Recurse -File | Measure-Object -Property length -Sum 
$folders = Get-ChildItem -Path $env:TEMP -Recurse -Directory | Measure-Object 
$props = [ordered]@{ TimeStamp = Get-Date NumberOfFiles = $files.Count NumberofFolders = $folders.Count 'SizeofTemp(MB)' = [math]::Round(($files.Sum / 1MB), 3) } $tdata = New-Object -TypeName PSobject -Property $props $tdata $tdata | Export-Csv -Path C:\TestScripts\TempFolderLog.csv -NoTypeInformation -Append



#The TEMP folder information needs to be reported before and after the clean-up action. If you’re running the code a number of times make it a function. You could make the code into a class with a static method fi you prefer but I’m going to use a function.
#You can use LastWriteTime on the files and folders to determine if they’re more than 24 hours old.
#Emptying the recycle bin is a bit trickier. PowerShell v5 introduced the Clear-RecycleBin cmdlet but unfortunately there isn’t a cmdlet to view the contents of the recycle bin which means you can’t do any tests on the file. Back to good old COM.

$shell = New-Object -ComObject Shell.Application 
$rbin = $shell.Namespace(10) 
$rbin.Items() | Where-Object ModifyDate -lt $testdate | ForEach-Object { Remove-Item -Path $psitem.Path -Recurse -Confirm:$false -Force -WhatIf }


#Get the object for the Shell and set the namespace to 10 which is the recycle bin. Get the contents of the recycle bin, check if they are more than 24 hours old and delete if they are. The puzzle didn’t specifically ask for this filter but it’s a nice to have. If you just want to clear out the recycle bin then use Clear-RecycleBin
#How did I know to use namespace 10? I wrote about working with the recycle bin in PowerShell in Practice - https://www.manning.com/books/powershell-in-practice
#You can find a list of the available special folders using this small script:

1..1000 | ForEach-Object { 
    $shell = New-Object -ComObject Shell.Application 
    $sf = $shell.NameSpace($psitem) if ($sf) { $props = [ordered]@{ Value = $psitem Name = $sf.Title Path = $sf.Self.Path } 
    New-Object -TypeName PSobject -Property $props } }


    #Your working code now becomes
    function Get-TEMPsize { 
        $files = Get-ChildItem -Path $env:TEMP -Recurse -File | Measure-Object -Property length -Sum 
        $folders = Get-ChildItem -Path $env:TEMP -Recurse -Directory | Measure-Object 
        $props = [ordered]@{ TimeStamp = Get-Date NumberOfFiles = $files.Count NumberofFolders = $folders.Count 'SizeofTemp(MB)' = [math]::Round(($files.Sum / 1MB), 3) } 
        New-Object -TypeName PSobject -Property $props }
    

        # get current size 
        Get-TEMPsize | Export-Csv -Path C:\TestScripts\TempFolderLog.csv -NoTypeInformation -Append

        ## remove old files 
        $testdate = (Get-Date).AddHours(-24)

        Get-ChildItem -Path $env:TEMP -Recurse -File | 
        Where-Object LastWriteTime -lt $testdate | 
        Where-Object Fullname -NotLike "$env:TEMP\*NVIDIA*" | 
        Where-Object Fullname -NotLike "*wct*.tmp" | Remove-Item -Force


        Get-ChildItem -Path $env:TEMP -Recurse -Directory | 
        Where-Object LastWriteTime -lt $testdate | 
        Where-Object Fullname -NotLike "$env:TEMP\*NVIDIA*" | 
        Remove-Item -Force -Recurse


        ## empty recycle bin 
        $shell = New-Object -ComObject Shell.Application
        $rbin = $shell.Namespace(10) 
        $rbin.Items() |
        Where-Object ModifyDate -lt $testdate | 
        ForEach-Object { Remove-Item -Path $psitem.Path -Recurse -Confirm:$false -Force }


        ## get new size 
        Get-TEMPsize | Export-Csv -Path C:\TestScripts\TempFolderLog.csv -NoTypeInformation -Append

        #Notice the lines 
        Where-Object Fullname -NotLike "$env:TEMP\*NVIDIA*" | 
        Where-Object Fullname -NotLike "*wct*.tmp" |

        #These exclude a number of folders used by the graphics card which contain files that are locked open. Likewise, the wct*.tmp files generate an “Access Denied” message when running the script. If you want to trap all of these you should log the failures of each individual delete – which is something Daybreak and Flawless factions may think of adding.
        #Now you have the working code it’s time to think about the scheduling aspects.