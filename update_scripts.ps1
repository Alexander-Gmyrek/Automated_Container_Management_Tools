# Define the path to the configuration file
$configFilePath = ".\config.txt"

# Function to read configuration file and return a hashtable of settings
function Get-Config {
    param (
        [string]$filePath
    )
    $config = @{}
    if (Test-Path $filePath) {
        Get-Content $filePath | ForEach-Object {
            $parts = $_ -split "="
            if ($parts.Count -eq 2) {
                $config[$parts[0].Trim()] = $parts[1].Trim()
            }
        }
    } else {
        Write-Error "Configuration file not found: $filePath"
        exit
    }
    return $config
}

# Get the configuration settings
$config = Get-Config -filePath $configFilePath

# Define the script paths
$backupScriptPath = ".\backup_mysql.ps1"
$restoreScriptPath = ".\restore_mysql.ps1"
$deployScriptPath = ".\deploy.ps1"

# Function to update a script with the configuration settings
function Update-Script {
    param (
        [string]$scriptPath,
        [hashtable]$config
    )
    if (Test-Path $scriptPath) {
        $scriptContent = Get-Content $scriptPath
        foreach ($key in $config.Keys) {
            $pattern = "\`$$key\s*=\s*`"[^`"]*`""
            $replacement = "`$$key = `"$($config[$key])`""
            $scriptContent = $scriptContent -replace $pattern, $replacement
        }
        Set-Content -Path $scriptPath -Value $scriptContent
        Write-Output "Updated script: $scriptPath"
    } else {
        Write-Error "Script file not found: $scriptPath"
    }
}

# Update the scripts
Update-Script -scriptPath $backupScriptPath -config $config
Update-Script -scriptPath $restoreScriptPath -config $config
Update-Script -scriptPath $deployScriptPath -config $config

Write-Output "All scripts have been updated with the new configuration."
