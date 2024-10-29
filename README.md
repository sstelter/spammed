# Simple Picture And Movie Mirroring for External Devices

This script will allow you to mirror pictures and movies from iPhones to local or external hard drives.

## Usage

```powershell
powershell -f mirror.ps1 -deviceName "Device name" -deviceFolderPath "Path to pictures and movies" -dstHome "Destination directory"
```

e.g.
```powershell
powershell -f mirror.ps1 -deviceName "Apple iPhone" -deviceFolderPath "Internal Storage" -dstHome "e:\iPhone\export"
```

The 'dstHome' argument is optional.  If not specified, the mirroring script will use the value of your TEMP environment variable.
