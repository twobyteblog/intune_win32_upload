## Microsoft Intune Win32 Upload Utility

Script which automates the uploading of Win32 apps to Microsoft Intune.

## Setup Instructions

### Authentication

Create an [Enterprise Application](https://median.co/docs/microsoft-intune) within Microsoft Azure to allow access to Microsoft Intune via the [Microsoft Graph API](https://learn.microsoft.com/en-us/graph/use-the-api).

```
$TenantID = 
$ClientID = 
$ClientSecret = 
```

### IntuneWinApp Utility

[Download](https://github.com/Microsoft/Microsoft-Win32-Content-Prep-Tool) and specify the location of the ```IntuneWinAppUtil.exe``` file. This is used to generate the IntuneWIN file required by Microsoft Intune for upload.

```
$IntuneWinExe = C:\Scripts\Tools\IntuneWinAppUtil.exe
```

### Folder Structure

Copy the example layout provided in this repo, and edit it to your needs. The example shows an app which disables Adobe Acrobat's AI functionality via changing a registry key.

```bash
- Source/ - Directory containing the application.
- config.json - Intune Win32App setings.
- detect.ps1 - Detection script used by Microsoft Intune to determine installation success.
```

## Upload

To upload the file, run the script referencing the full path to the app.

```
.\UploadWin32App.ps1 'C:\Example App'
```