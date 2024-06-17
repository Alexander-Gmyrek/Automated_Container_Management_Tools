# Automated Container Deployment On Windows

Created: June 16, 2024 3:14 PM

### Tools Required:

1. **Task Scheduler** - The Windows equivalent of Cron for scheduling tasks.
2. **PowerShell** - The scripting language for automating tasks on Windows.
3. **Git for Windows** - For managing the version control of the project.
4. **Docker for Windows** - For containerizing the application.
5. **A lock file mechanism** - To prevent simultaneous deployments.

### Steps to Set Up:

### 1. Install Required Tools:

- **Git for Windows**: Download and install Git from [git-scm.com](https://git-scm.com/download/win).
- **Docker for Windows**: Download and install Docker Desktop from docker.com.
- **Ensure PowerShell is Installed**: PowerShell is included by default in Windows 10 and Windows Server 2016 and later.

### 2. Schedule the PowerShell Script with Task Scheduler:

1. **Open Task Scheduler**:
    - Press `Win + R`, type `taskschd.msc`, and press Enter.
2. **Create a New Task**:
    - In the right pane, click on "Create Task".
3. **General Tab**:
    - Name your task (e.g., "Automated Deployment").
    - Configure it to run whether the user is logged on or not.
    - Set it to run with highest privileges.
4. **Triggers Tab**:
    - Click "New" to create a new trigger.
    - Set the trigger to "Daily" and repeat the task every 1 minute.
5. **Actions Tab**:
    - Click "New" to create a new action.
    - Set the action to "Start a program".
    - In the "Program/script" box, type `powershell`.
    - In the "Add arguments (optional)" box, type `File "C:\path\to\deploy.ps1"`.
6. **Conditions Tab**:
    - Uncheck "Start the task only if the computer is on AC power" to ensure it runs on battery as well.
7. **Settings Tab**:
    - Check "Allow task to be run on demand".
    - Ensure "If the task fails, restart every" is checked and set to 1 minute.
    - Set "Stop the task if it runs longer than" to 1 hour (adjust as necessary).
8. **Finish**:
    - Click OK to save the task.
    - You may be prompted to enter your password to create the task.

### 3. Monitoring and Logs:

- The script logs messages to `deploy.log` in the repository directory. Check this file for deployment status and errors.