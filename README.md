# Microsoft Intune Win32 Upload Utility

This is a script which helps automate the process of uploading Win32 apps to Microsoft Intune. Using this script you can upload Win32 apps using a single command verses having to specify each option via the GUI.

## Initial Setup

For the script to communicate with Microsoft Intune, access needs to be provided. This script was written to connect via Microsoft Graph using a shared secret. For more information on setting up this access please see this [article](https://median.co/docs/microsoft-intune).

```
$TenantID = 
$ClientID = 
$ClientSecret = 
```

Additionally, also [download](https://github.com/Microsoft/Microsoft-Win32-Content-Prep-Tool) and indicate where the IntuneWinAppUtil.exe file is located. This is used to generate the IntuneWIN file required by Microsoft Intune for upload.

```
$IntuneWinExe = C:\Scripts\Tools\IntuneWinAppUtil.exe
```

## App Preparation

The script expects a specific layout to successfully upload the app. The layout needs to look as follows:

```
Example App - Folder
- Source - App including installer/script to run.
    - main.ps1
- config.json - JSON file containing the Microsoft Intune configuration.
- detect.ps1 - Script which will detect whether the app was successfully installed.
```
Copy the example layout provided in this repo, and edit it to your needs. The example shows an app which disables Adobe Acrobat's AI functionality via changing a registry key.

## Upload

To upload the file, run the script referencing the full path to the app.

```
.\UploadWin32App.ps1 'C:\Example App'
```