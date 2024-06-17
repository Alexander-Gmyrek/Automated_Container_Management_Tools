# restore_mysql.ps1

# Define variables
$backupDir = "C:\path\to\backup\directory"
$containerName = "your_mysql_container_name"  # Replace with your MySQL container name
$mysqlUser = "your_mysql_user"  # Replace with your MySQL username
$mysqlPassword = "your_mysql_password"  # Replace with your MySQL password

# Function to log messages
function Write-Message {
    param (
        [string]$message
    )
    Write-Output "$((Get-Date).ToString()): $message"
}

# List available backups
$backups = Get-ChildItem -Path $backupDir -Filter "mysql_backup_*.sql"

if ($backups.Count -eq 0) {
    Write-Message "No backups found in $backupDir"
    exit
}

Write-Message "Available backups:"
for ($i = 0; $i -lt $backups.Count; $i++) {
    Write-Output "$($i + 1). $($backups[$i].Name)"
}

# Prompt user to select a backup
$selection = Read-Host "Enter the number of the backup to restore"

if ($selection -lt 1 -or $selection -gt $backups.Count) {
    Write-Message "Invalid selection. Exiting..."
    exit
}

$selectedBackup = $backups[$selection - 1]
Write-Message "Selected backup: $($selectedBackup.Name)"

# Restore the selected backup
try {
    Write-Message "Restoring MySQL backup..."

    # Copy the backup file to the Docker container
    docker cp $selectedBackup.FullName "${containerName}:/backup_to_restore.sql"

    # Run the MySQL restore command in the Docker container
    $restoreCommand = "docker exec $containerName /usr/bin/mysql -u $mysqlUser --password=$mysqlPassword < /backup_to_restore.sql"
    docker exec $containerName bash -c $restoreCommand

    Write-Message "Backup restored successfully from $($selectedBackup.Name)"
} catch {
    Write-Message "An error occurred during the restore: $_"
} finally {
    # Clean up the temporary backup file inside the container
    docker exec $containerName bash -c "rm -f /backup_to_restore.sql"
}
