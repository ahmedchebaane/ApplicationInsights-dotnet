﻿[CmdletBinding()]
Param(
    # C:\Repos\bin\Debug\Src
    [string]$buildDirectory = (Join-Path -Path (Split-Path -parent (Split-Path -parent (Split-Path -parent $PSCommandPath))) -ChildPath "bin\Debug") ,
    
    # C:\Repos\fxCop
    [string]$fxCopDirectory = (Join-Path -Path (Split-Path -parent (Split-Path -parent (Split-Path -parent $PSCommandPath))) -ChildPath "fxCop")
)

# these are dlls that end up in the bin, but do not belong to us and don't need to be scanned.
$excludedFiles = @();

Write-Host "`nPARAMETERS:";
Write-Host "`tbuildDirectory:" $buildDirectory;
Write-Host "`tfxCopDirectory:" $fxCopDirectory;

$frameworks = @("net45", "net46", "netstandard1.6");

# don't need to clean folder on build server, but is needed for local dev
Write-Host "`nCreate FxCop Directory...";
if (Test-Path $fxCopDirectory) { Remove-Item $fxCopDirectory -Recurse; }

# copy all
Write-Host "`nCopy all files (excluding 'Test' directories)...";
Get-ChildItem -Path $buildDirectory -Recurse -File -Include *.dll, *.pdb |
    ForEach-Object {
        $file = $_;

        # exclude test files
        if ($file.Directory -match "Test") {
            return;
        }

        $frameworks | ForEach-Object {
            if($file.Directory -match $_) {
                Copy-Item $file.FullName -Destination (New-Item (Join-Path -Path $fxCopDirectory -ChildPath $_) -Type container -Force) -Force;
            }
        }
    }

# delete excluded files
if ($excludedFiles.Count -gt 0) {
    Write-Host "`nDelete excluded files...";
    Get-ChildItem -Path $fxCopDirectory -Recurse -File | 
        ForEach-Object { 
            if ($excludedFiles.Contains($_.Name)) {
                Write-Host "Excluded File:" $_.FullName;
                Remove-Item $_.FullName;
            }
        } 
}

# summary for log output (file list and count)
Write-Host "`nCopied Files:";

$count = 0;
Get-ChildItem -Path $fxCopDirectory -Recurse -File | 
    ForEach-Object { 
        Write-Host "`t"$_.FullName; 
        $count++;
    } 

Write-Host "`nTOTAL FILES:" $count;