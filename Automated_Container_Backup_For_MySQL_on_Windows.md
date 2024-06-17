# Automated Container Backup For MySQL on Windows

Created: June 16, 2024 3:15 PM

This script will handle both hourly backups and the daily/monthly cleanup.

### Schedule the PowerShell Script with Task Scheduler:

1. **Open Task Scheduler**:
    - Press `Win + R`, type `taskschd.msc`, and press Enter.
2. **Create a New Task**:
    - In the right pane, click on "Create Task".
3. **General Tab**:
    - Name your task (e.g., "MySQL Backup").
    - Configure it to run whether the user is logged on or not.
    - Set it to run with highest privileges.
4. **Triggers Tab**:
    - Click "New" to create a new trigger.
    - Set the trigger to "Daily" and repeat the task every 1 hour. Set the duration for 1 day.
5. **Actions Tab**:
    - Click "New" to create a new action.
    - Set the action to "Start a program".
    - In the "Program/script" box, type `powershell`.
    - In the "Add arguments (optional)" box, type `File "C:\path\to\backup_mysql.ps1"`.
6. **Conditions Tab**:
    - Uncheck "Start the task only if the computer is on AC power" to ensure it runs on battery as well.
7. **Settings Tab**:
    - Check "Allow task to be run on demand".
    - Ensure "If the task fails, restart every" is checked and set to 1 hour (adjust as necessary).
    - Set "Stop the task if it runs longer than" to 1 hour (adjust as necessary).
8. **Finish**:
    - Click OK to save the task.
    - You may be prompted to enter your password to create the task.