# Define variables
$backupDir = "C:\path\to\backup\directory"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupFile = "$backupDir\mysql_backup_$timestamp.sql"
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

# Function to perform the backup
function Complete-Backup {
    try {
        Write-Message "Starting MySQL backup..."

        # Run the MySQL dump command in the Docker container
        $dumpCommand = "docker exec $containerName /usr/bin/mysqldump -u $mysqlUser --password=$mysqlPassword --all-databases > /backup/mysql_backup.sql"
        docker exec $containerName bash -c "mkdir -p /backup"
        docker exec $containerName bash -c $dumpCommand

        # Copy the backup file from the Docker container to the host
        docker cp "${containerName}:/backup/mysql_backup.sql" $backupFile

        Write-Message "Backup completed successfully. Backup file: $backupFile"
    } catch {
        Write-Message "An error occurred during the backup: $_"
    } finally {
        # Clean up the temporary backup directory inside the container
        docker exec $containerName bash -c "rm -rf /backup"
    }
}

# Function to clean up old backups
function Clear-Backups {
    param (
        [string]$pattern
    )
    Write-Message "Cleaning up old backups with pattern: $pattern"
    Get-ChildItem -Path $backupDir -Filter $pattern | Remove-Item
}

# Perform the backup
Complete-Backup

# Check if it is midnight
if ((Get-Date).Hour -eq 0) {
    if ((Get-Date).Day -eq 1) {
        # Monthly cleanup: Keep only the last backup of the previous month
        $previousMonth = (Get-Date).AddMonths(-1).ToString("yyyyMM")
        $pattern = "mysql_backup_$previousMonth*.sql"
        Clear-Backups $pattern
    }
    # Daily cleanup: Keep only the last backup of the previous day
    $previousDay = (Get-Date).AddDays(-1).ToString("yyyyMMdd")
    $pattern = "mysql_backup_$previousDay*.sql"
    Clear-Backups $pattern
}