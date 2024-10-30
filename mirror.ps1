param(
  [string]$deviceName       = 'Apple iPhone', 
  [string]$deviceFolderPath = 'Internal Storage',
  [string]$dstHome          = ''
)

$tempDir = [System.IO.Path]::GetTempPath()

if ($dstHome -eq '') { $dstHome = (-join($tempDir, 'iphone_export')) }

$iPhoneSkipFolders = (-join($dstHome, 'iPhoneSkipFolders'))


# Argument debugging
#Write-Host $deviceName
#Write-Host $deviceFolderPath
#Write-Host $dstHome
#Write-Host $tempDir
#Write-Host $iPhoneSkipFolders
#[Environment]::Exit(1)

$shell             = New-Object -com shell.application
$deviceFolder      = ($shell.NameSpace("shell:MyComputerFolder").Items() | where Name -eq $deviceName).GetFolder

$sourceFolderAsFolderItem = $deviceFolderPath.Split('\') |
ForEach-Object -Begin { 
  $comFolder = $deviceFolder 
} -Process {
  Try
    { $comFolder = ($comFolder.Items() | where {$_.IsFolder} | where Name -eq $_).GetFolder }
  Catch
    { Write-Error 'Failed to parse $deviceFolderPath' }
} -End { 
  $comFolder.Self 
}

$srcDirs          = @($sourceFolderAsFolderItem.GetFolder.items())
$totalCopiedItems = 0

foreach ($srcDir in $srcDirs)
  {
    $copiedItems   = 0
	$existingItems = 0
	$skipDir       = $null
	$skippedCount  = 0
	
    Write-Host (-join("Checking '", $srcDir.Name, "'...."))
	
    $srcItems = @($srcDir.GetFolder.items())
	
    #Write-Host $srcItems[0].Name
	#[Environment]::Exit(1)
	
    if (Test-Path -Path $iPhoneSkipFolders) 
	  { 
	    $skippedLine = Select-String -Path $iPhoneSkipFolders -Pattern $srcDir.Name -SimpleMatch | Out-String
		
		if ($skippedLine -ne $null)
		  { $skipDir, [int]$skippedCount = $skippedLine.split(';') }
		  
		if ($srcItems.Count -ne $skippedCount)
		  { $skipDir = $null }
	  }

	if ($skipDir -eq $null)
	  {
	    $dstDir = (-join($dstHome, '\', $srcDir.Name))
		
		if (!(Test-Path -Path $dstDir))
		  { [void](New-Item -Path $dstDir -ItemType Directory -Force) }
		  
		$destinationFolder = $shell.Namespace($dstDir).self
		
		if ($srcItems.Count -gt 0)
		  {
		    foreach ($srcItem in $srcItems)
		      {
		        if (!(Test-Path (-join($dstDir, '\', $srcItem.Name, '.*')) -PathType Leaf))
			      { 
			        Write-Host (-join("Copying '", $srcItem.Name, "' to '", $dstDir, "'"))
			        # Copy-Item -Path $srcItem -Destination $dstDir
					$destinationFolder.GetFolder.CopyHere($srcItem)
                    $copiedItems += 1				
			      }
				else
				  { $existingItems += 1 }
		      }
		  }
		  
		Write-Host (-join("Found ", $existingItems, " existing items; Copied ", $copiedItems, " new items to '", $dstDir, "'"))
		(-join($srcDir.Name, ';', $srcItems.Count)) | Out-File -FilePath $iPhoneSkipFolders -Append
		
		$totalCopiedItems += $srcItems.Count
	  }
	else
	  { 
	    $totalCopiedItems += $skippedCount
	    Write-Host (-join("Skipping '", $skipDir, "' - ", $skippedCount, ' items')) 
	  }
  }
  
Write-Host (-join("Total items copied - ", $totalCopiedItems))
