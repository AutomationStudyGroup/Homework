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
$props = [ordered]@{ TimeStamp = Get-Date; NumberOfFiles = $files.Count; NumberofFolders = $folders.Count; 'SizeofTemp(MB)' = [math]::Round(($files.Sum / 1MB), 3) } 
$tdata = New-Object -TypeName PSobject -Property $props; $tdata; $tdata | Export-Csv -Path C:\Temp\TempFolderLog.csv -NoTypeInformation -Append



#The TEMP folder information needs to be reported before and after the clean-up action. If you’re running the code a number of times make it a function. 
#You could make the code into a class with a static method fi you prefer but I’m going to use a function.
#You can use LastWriteTime on the files and folders to determine if they’re more than 24 hours old.
#Emptying the recycle bin is a bit trickier. PowerShell v5 introduced the Clear-RecycleBin cmdlet but unfortunately there isn’t a cmdlet to view the contents of the recycle bin 
#which means you can’t do any tests on the file. Back to good old COM.

$shell = New-Object -ComObject Shell.Application 
$rbin = $shell.Namespace(10) 
$rbin.Items() | Where-Object ModifyDate -lt $testdate | ForEach-Object { Remove-Item -Path $psitem.Path -Recurse -Confirm:$false -Force -WhatIf }


#Get the object for the Shell and set the namespace to 10 which is the recycle bin. Get the contents of the recycle bin, check if they are more than 24 hours old and delete if they are. The puzzle didn’t specifically ask for this filter but it’s a nice to have. If you just want to clear out the recycle bin then use Clear-RecycleBin
#How did I know to use namespace 10? I wrote about working with the recycle bin in PowerShell in Practice - https://www.manning.com/books/powershell-in-practice
#You can find a list of the available special folders using this small script:

1..1000 | ForEach-Object { 
    $shell = New-Object -ComObject Shell.Application 
    $sf = $shell.NameSpace($psitem) if ($sf) { $props = [ordered]@{ Value = $psitem Name = $sf.Title Path = $sf.Self.Path } 
        New-Object -TypeName PSobject -Property $props } 
}


#Your working code now becomes
function Get-TEMPsize { 
    $files = Get-ChildItem -Path $env:TEMP -Recurse -File | Measure-Object -Property length -Sum 
    $folders = Get-ChildItem -Path $env:TEMP -Recurse -Directory | Measure-Object 
    $props = [ordered]@{ TimeStamp = Get-Date NumberOfFiles = $files.Count NumberofFolders = $folders.Count 'SizeofTemp(MB)' = [math]::Round(($files.Sum / 1MB), 3) } 
    New-Object -TypeName PSobject -Property $props 
}
    

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

#You have two options for scheduling built into PowerShell:
#• Scheduled tasks
#• Scheduled jobs
#Let’s look at scheduled tasks first. You used to have to do bunch of work with COM objects to work with scheduled tasks but we now have the ScheduledTasks module. 
#Assuming the working code is saved as Clear-Temp.ps1 you can use the following to create a scheduled task:

$t = New-ScheduledTaskTrigger -Daily -At 13:00 
$psarg = '-NoProfile -WindowStyle Normal -NoExit -File "C:\MyData\2018 Summit\Iron Scripter\Iron Scripter prequels\Puzzle09\Clear-Temp.ps1"' 
$a = New-ScheduledTaskAction -Execute powershell.exe -Argument $psarg 
Register-ScheduledTask -TaskName 'Clear-Temp' -Trigger $t -Action $a -RunLevel Highest


#This will create a trigger to run the task at 13:00 (1pm) every day – as long as the user is logged on. The action is to run PowerShell and the script created earlier. Register the task to create it and set the run level to highest (admin privileges).
#I always create scheduled tasks with a normal window style and the -Noexit options so that I can see what’s happening. The drawback is that the task will appear to be still running so you’ll have to stop it manually. Once you’re happy everything’s working you can unregister the task


Get-ScheduledTask -TaskName Clear-Temp | 
Unregister-ScheduledTask -Confirm:$false

#Modify the PowerShell start options to suit your requirements and recreate the scheduled task.
#You can run a scheduled task from PowerShell:

Get-ScheduledTask -TaskName Clear-Temp | Start-ScheduledTask

#Scheduled jobs are your other option. A scheduled job combines the background execution of PowerShell jobs (probably one of the most overlooked features in PowerShell) and the scheduling capabilities of Windows. The cmdlets you need are in the PSScheduledJob module:

$fpath = 'C:\MyData\2018 Summit\Iron Scripter\Iron Scripter prequels\Puzzle09\Clear-Temp.ps1' 
$t = New-JobTrigger -Daily -At 13:00 
$o = New-ScheduledJobOption -RunElevated
Register-ScheduledJob -Name 'Clear-Temp' -FilePath $fpath -Trigger $t -ScheduledJobOption $o -RunNow


#You can either create a script block for the code your scheduled job will run or you can use a script. In this case set the path to the script. Define a trigger as before and an option to run the job with elevated privileges. The final step is to register the scheduled job.
#You can find the scheduled jobs on your system in the Task Scheduler Library under Microsoft\Windows\PowerShell\ScheduledJobs
#To run a scheduled job outside its schedule use:
#PS> Start-Job -DefinitionName Clear-temp
#You can then use the standard job cmdlets to work with the job – note that the job type is PSScheduledJob. Up to 32 (by default) runs of the scheduled job will be retained on disk. You could either let them overwrite or write another scheduled task/job to clean them up.
#Remove the schedule job with:

Unregister-ScheduledJob -Name Clear-Temp


