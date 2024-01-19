
<#

 Author: Dimitrios Kakoulidis
 Date Create : 18-01-2024
 Last Update : 18-01-2024
 Version: 1.2

 .Description 
   Script is making exact copy of a source location to destination.
   - Compare all files between source and destination folder. 
   - If files or fodlers exists on destination folder but not on source then they will be removed
   - If files exists on source and not on destination then they will be copied in the destination folder
   - If files exists on both folders and they are exactly the same the script will be skipped them
   - If files on source folder is newer the script will replace the old file on destination with the new updated version
  
 .Output
   - In the end you will have an export BCKLogs_Currentdate.csv file that shows all the actions (copied, skipped, create, delete) of each file and folder
   
#> 



### Parameters that are needed when you run the script
param (
    [string]$source,
    [string]$destination,
    [switch]$help,
    [switch]$version,
    [switch]$about
)


### Variables for source and destination folders and variables for log files and location to be saved.

$sourceFolder = $source
$destinationFolder = $destination
$logs = @()
$loglocation = "BCKLogs_$(Get-Date -Format 'dd-MM-yyyy').csv" 



### Triggered with the argument -version
If ($version){
  Write-output 'Backup.ps1 Version 1.2'
  Exit
}


### Triggered with the argument -Help
If ($help){  
  Write-Host " This script will make exact copy of a source folder to a destination folder`n", 
             "  You can run it with the following format `n"
  Write-Host  "Backup.ps1 -source " -ForegroundColor Green -NoNewline;
  Write-Host "<put source folder>" -ForegroundColor Yellow -NoNewline; 
  Write-Host " -destination" -ForegroundColor Green -NoNewline;
  Write-Host " <put destination folder>" -ForegroundColor Yellow
  Exit
}


### Triggered with the argument -about
If ($about){
  Write-output "Author: Dimitrios Kakoulidis
 Date Create : 18-01-2024
 Last Update : 18-01-2024
 Version: 1.0

 .Description 
   Script is making exact copy of a source location to destination.
   - Compare all files between source and destination folder. 
   - If files or fodlers exists on destination folder but not on source then they will be removed
   - If files exists on source and not on destination then they will be copied in the destination folder
   - If files exists on both folders and they are exactly the same the script will skipped them
   - If files on source folder is newer the script will replace the old file on destination with the new updated version
  
 .Output
   - In the end you will have an export BCKLogs_Currentdate.csv file that shows all the actions (copied, skipped, create, delete) of each file and folder"
   
  Exit
}


### Check if the give source is empty and throw an error message

if ($source.Length -eq 0 -or $source -eq $null -or $source -eq '') {
    Write-host "You haven't provide the source folder. Please try again with the following format"
    Write-host  "Backup.ps1 -source" -ForegroundColor Green -NoNewline; Write-host " <put source folder>" -ForegroundColor red -NoNewline; Write-host "  -destination <put destination folder>" -ForegroundColor Green 
    Exit
}
 

### Check if the give destination is empty and throw an error message

if ($destination -eq $null -or $destination -eq '') {
    Write-host "You haven't provide the destination folder. Please try again with the following format"
    Write-host  "  Backup.ps1 -source <put source folder> -destination" -ForegroundColor Green -NoNewline; Write-host " <put destination folder>" -ForegroundColor Red -NoNewline 
    Exit
}



### Check if the give source exists. If not then it throws an error message

if (-not (Test-Path -Path $sourceFolder)) {
    Write-output "Source folder does not exist, Please check and run again the script"
    Exit
}


### Create the destination folder exists. If not then it will create it and skip the comparison with 
### the source folder as it is not needed. If the destination folder exists then start the comparison and remove 
### whatever file or folder exists only in destintion folder

if (-not (Test-Path -Path $destinationFolder)) {
    New-Item -ItemType Directory -Path $destinationFolder | Out-Null
    Write-host "Folder $destinationFolder Created" -ForegroundColor Green
}
else{

  ### Checks to compare and remove files/folders from destination folder starts #############


  ### Get a list of all files in the folder and all subfolders
  $allDestinationFiles = Get-ChildItem -Path $destinationFolder -File -Recurse
     
  ### Remove files in the destination that do not exist in the source folder
  foreach ($destinationFile in $allDestinationFiles) {
    $AuditLogDF = New-Object System.Object
    $sourcePath = Join-Path $sourceFolder $destinationFile.FullName.Substring($destinationFolder.Length + 1)


    ### Check if the file doesn't exist in the source folder
    if (-not (Test-Path -Path $sourcePath)) {
      ### Remove the file from the destination
      Remove-Item -Path $destinationFile.FullName -Force -ErrorAction SilentlyContinue
      Write-host "File $destinationFile.FullName Removed" -ForegroundColor Red
      ### Create a log record that the file was removed
      $AuditLogDF| Add-Member -MemberType NoteProperty -Name "Type" -Value "File"
      $AuditLogDF| Add-Member -MemberType NoteProperty -Name "Name" -Value $destinationFile.FullName
      $AuditLogDF| Add-Member -MemberType NoteProperty -Name "Status" -Value "Removed"
      $logs += $AuditLogDF
    }
  }


  ### Get a list of all directories in the destination folder and its subfolders
  $destinationDirectories = Get-ChildItem -Path $destinationFolder -Directory -Recurse

  ### Remove directories in the destination that don't exist in the source
  foreach ($destinationDirectory in $destinationDirectories) {
    $AuditLogD = New-Object System.Object
    $relativePath = $destinationDirectory.FullName.Substring($destinationFolder.Length + 1)
    $sourcePath = Join-Path $sourceFolder $relativePath

    ### Check if the directory doesn't exist in the source
    if (-not (Test-Path -Path $sourcePath -PathType Container)) {
        ### Remove the directory from the destination
        Remove-Item -Path $destinationDirectory.FullName -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "Folder $destinationDirectory Removed" -ForegroundColor Red
        ### Create a log record that the folder was removed
        $AuditLogD| Add-Member -MemberType NoteProperty -Name "Type" -Value "Folder"
        $AuditLogD| Add-Member -MemberType NoteProperty -Name "Name" -Value $destinationDirectory
        $AuditLogD| Add-Member -MemberType NoteProperty -Name "Status" -Value "Removed"
        $logs += $AuditLogD
    }
   }

}

  ### Checks to compare and remove files/folders from destination folder ends #############


  ### Checks to compare and copy files/folders to destination folder starts #############


### Create the destination folder if it doesn't exist
if (-not (Test-Path -Path $destinationFolder)) {
    New-Item -ItemType Directory -Path $destinationFolder | Out-Null
    Write-Host "Folder $destinationFolder Created" -ForegroundColor Green
}


### Create each folder to the destination 

### Get a list of all directories in the source folder and subfolders
$sourceDirectories = Get-ChildItem -Path $sourceFolder -Directory -Recurse

### Create related directories in the destination folder
foreach ($sourceDirectory in $sourceDirectories) {

    $AuditLogFolder = New-Object System.Object
    $relativePath = $sourceDirectory.FullName.Substring($sourceFolder.Length + 1)
    $destinationPath = Join-Path $destinationFolder $relativePath

    # Create a log record for folders
    $AuditLogFolder| Add-Member -MemberType NoteProperty -Name 'Type' -Value 'Folder'
    $AuditLogFolder| Add-Member -MemberType NoteProperty -Name 'Name' -Value $destinationPath


    # Check if the directory exists in the destination
    if (-not (Test-Path -Path $destinationPath -PathType Container)) {

        # Create the directory if it doesn't exist
        New-Item -ItemType Directory -Path $destinationPath -Force | Out-Null
        Write-Host "Folder $destinationPath Created" -ForegroundColor Green

        # Create a log record that folder was created
        $AuditLogFolder| Add-Member -MemberType NoteProperty -Name 'Status' -Value 'Created'

    } else {
        # Create a log record that folder was skipped as already exists
        $AuditLogFolder| Add-Member -MemberType NoteProperty -Name 'Status' -Value 'Skipped'
        Write-Host "Folder $destinationPath was Skipped" -ForegroundColor Yellow
    }
    $logs+= $AuditLogFolder
}


### Copy each file to the destination 

$allFiles = Get-ChildItem -Path $sourceFolder -File -Recurse

foreach ($file in $allFiles) {

    $AuditLog = New-Object System.Object
    $destinationPath = Join-Path $destinationFolder $file.FullName.Substring($sourceFolder.Length + 1)

    # Create a log record for the file
    $AuditLog| Add-Member -MemberType NoteProperty -Name 'Type' -Value 'File'
    $AuditLog| Add-Member -MemberType NoteProperty -Name 'Name' -Value $file.FullName

    # Check if the file exists in the destination and if it is newer
    if (!(Test-Path -Path $destinationPath) -or ($file.LastWriteTime -gt (Get-Item -Path $destinationPath).LastWriteTime)) {

        # Copy the file to the destination
        Copy-Item -Path $file.FullName -Destination $destinationPath -Force

        # Create a log record for the file that is copied
        $AuditLog| Add-Member -MemberType NoteProperty -Name 'Status' -Value 'Copied'
        Write-Host "File $file.FullName was Copied" -ForegroundColor Green

    } else {
        # Create a log record for the file that it is skipped as it is already exists and it is the same
        $AuditLog| Add-Member -MemberType NoteProperty -Name 'Status' -Value 'SKipped'
        Write-Host "File $file.FullName was Skipped" -ForegroundColor Yellow
    }
    $logs+= $AuditLog
}

### Checks to compare and copy files/folders to destination folder ends #############


### Export log files to csv 
$logs| Export-Csv $loglocation -NoTypeInformation -Encoding UTF8

## Output final message

Write-Output "Log files from the task is stored on file "$loglocation


### End of script. ###