#Discover the size of the TEMP folder on the local system – report total size, number of subfolders 
#and number of files



#Clean out the contents of the TEMP folder that are more than 24 hours old


#Ensure that the deletion process doesn’t error by EXCLUDING files and directories that are pinned open. You may not be able to discover 
#these files and will have to just find them by trial and error

#Empty the recycle bin for the drive containing your TEMP folder


#Create a scheduled task or job that will automate this process. Store the total size, number of files, folders and timestamp in a log file 
#before and after the clean-up action. Also log the success or failure of the scheduled task/job. 
#If you use scheduled jobs ensure that the old jobs are removed on a scheduled basis

