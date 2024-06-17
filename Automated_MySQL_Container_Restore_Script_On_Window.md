# Automated MySQL Container Restore Script On Windows

Created: June 16, 2024 3:17 PM

This script will:

- List all available backups.
- Allow the user to select a backup.
- Restore the selected backup to the MySQL database.

### Usage:

1. **Run the Script**:
    - Open PowerShell with administrative privileges.
    - Navigate to the directory where the script is saved.
    - Run the script using the command:
        
        ```powershell
        .\restore_mysql.ps1
        ```
        
2. **Follow the Prompts**:
    - The script will list all available backups in the specified backup directory.
    - You will be prompted to enter the number corresponding to the backup you wish to restore.
    - The script will then restore the selected backup to the MySQL database running in the Docker container.