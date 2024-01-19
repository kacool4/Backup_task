# Backup Tool ver 1.2


 - Author: Dimitrios Kakoulidis
 - Date Create : 18-01-2024
 - Last Update : 18-01-2024
 - Version: 1.2

## Potential Issue that may occur
```
In case you see that the script is not running or throws erros please download the Zip file.
Sometimes Github adds weird characters in the code that cause script not to run.
Thank you.
```

 ## Description 
   Script is making an exact copy of a source location to destination location.

  Activities Performed by the script :
   - Compare all files between source and destination folder. 
   - If files or fodlers exists on destination folder but not on source then they will be removed
   - If files exists on source and not on destination then they will be copied in the destination folder
   - If files exists on both folders and they are exactly the same the script will be skipped them
   - If files on source folder is newer the script will replace the old file on destination with the new updated version
  
 ## Output File
   - In the end you will have an export BCKLogs_Currentdate.csv file that shows all the actions (copied, skipped, create, delete) of each file and folder


 ![Alt text](/screenshots/report.png?raw=true "CSV Export")


 ## Run the script
 
   Use the following command to run the script and replace the <Source_Folder> and <Destination_folder> with your preferred folders
```powershell
PS> Backup.ps1 -source <Source_Folder> -destination <Destination_Folder>
```
   ![Alt text](/screenshots/Output.png?raw=true "Console Output")

## Arguments
Apart from the -source and -destination arguments you can use also the following :
```
- -version --> Shows the latest version of the script
- -Help --> Gives you the syntax of the command
- -About --> Gives a description of the script
```

 ![Alt text](/screenshots/triggers.png?raw=true "Arguments")

# Checks


The script is written in a way that can predict missing arguments. For Example in case you add only source folder it will throw an error that you forgot the destination folder

 ![Alt text](/screenshots/no_dest_folder.png?raw=true "Error")

 Other checks that the script does are :
  -  If the source folder does not exist
  -  If you put destination folder only\
  -  If you don't put any argument

