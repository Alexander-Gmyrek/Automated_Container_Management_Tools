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
        throw "Configuration file not found: $filePath"
    }
    return $config
}

# Get the configuration settings
try {
    $config = Get-Config -filePath $configFilePath
} catch {
    Write-Error $_.Exception.Message
    exit 1
}

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
    try {
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
            throw "Script file not found: $scriptPath"
        }
    } catch {
        Write-Error "Failed to update script: $scriptPath - $($_.Exception.Message)"
        exit 1
    }
}

# Function to create a scheduled task
function Initialize-ScheduledTask {
    param (
        [string]$taskName,
        [string]$scriptPath,
        [string]$triggerTime,
        [string]$repeatInterval
    )
    try {
        $action = New-ScheduledTaskAction -Execute 'PowerShell.exe' -Argument "-File `"$scriptPath`""
        $trigger = New-ScheduledTaskTrigger -Daily -At $triggerTime -RepetitionInterval $repeatInterval
        $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
        $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -DontStopOnIdleEnd -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1)
        
        $task = New-ScheduledTask -Action $action -Principal $principal -Trigger $trigger -Settings $settings
        Register-ScheduledTask -TaskName $taskName -InputObject $task -Force
    } catch {
        Write-Error "Failed to create scheduled task: $taskName - $($_.Exception.Message)"
        exit 1
    }
}

# Update the scripts
Update-Script -scriptPath $backupScriptPath -config $config
Update-Script -scriptPath $restoreScriptPath -config $config
Update-Script -scriptPath $deployScriptPath -config $config

# Create scheduled tasks for deploy and backup scripts
Initialize-ScheduledTask -taskName "DeployScript" -scriptPath $deployScriptPath -triggerTime "00:00" -repeatInterval "PT1H"
Initialize-ScheduledTask -taskName "BackupMySQLScript" -scriptPath $backupScriptPath -triggerTime "00:00" -repeatInterval "PT1H"

Write-Output "Scripts updated and scheduled tasks created successfully."