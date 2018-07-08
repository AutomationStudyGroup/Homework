#Parameters
#The script should take 2 arguments $source and $destination (for the source and destination folders).
param (
    $source,
    $target
)
#Functions
#2)	Functions
function Check-Folder ([string]$path, [switch]$create){
if(!$exists -and $create){

    return $exists
}

}
check-folder C:\temp
#Create a function named CheckFolder that checks for the existence of a specific directory/folder that is passed 
#to it as a parameter. Also, include a switch parameter named create. If the directory/folder does not exist and 
#the create switch is specified, a new folder should be created using the name of the folder/directory that was 
#passed to the function.



#Create a function named DisplayFolderStatistics to display folder statistics for a directory/path that is passed 
#to it. Output should include the name of the folder, number of files in the folder, and total size of all files in 
#that directory.




#3)	Main processing

#a) Test for existence of the source folder (using the CheckFolder function).


#b) Test for the existence of the destination folder; create it if it is not found (using the CheckFolder function 
#with the –create switch).Write-Host "Testing Destination Directory - $destination"



#c) Copy each file to the appropriate destination.
#get all the files that need to be copied



#c-i) Display a message when copying a file. The message should list where the file is being
#moved from and where it is being moved to.





#d) Display each target folder name with the file count and byte count for each folder.


