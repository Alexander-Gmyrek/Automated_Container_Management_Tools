# Define variables
$repoPath = "C:\path\to\your\repository"
$lockFile = "C:\path\to\your\repository\deploy.lock"
$logFile = "C:\path\to\your\repository\deploy.log"

# Function to log messages
function Write-Message {
    param (
        [string]$message
    )
    Add-Content -Path $logFile -Value "$((Get-Date).ToString()): $message"
}

# Check if lock file exists
if (Test-Path $lockFile) {
    Write-Message "Lock file exists. Exiting..."
    exit
}

# Create lock file
New-Item -ItemType File -Path $lockFile

try {
    # Pull latest changes from git
    Set-Location $repoPath
    & git fetch

    # Check if there are any changes by comparing the local and remote hashes
    try {
        $localHash = & git -Command "rev-parse @"
        $remoteHash = & git -Command "rev-parse @{u}"
    } catch {
        Write-Message "Error executing Git command: $_"
        throw  # rethrow the exception to handle it further up the call stack
    }


    if ($localHash -ne $remoteHash) {
        Write-Message "Changes detected. Deploying..."

        # Pull latest changes
        & 'C:\Program Files\Git\cmd\git.exe' pull

        # Build and deploy using Docker Compose
        docker-compose build
        docker-compose up -d --scale app=2

        # Sleep for 30 seconds to ensure the new container is up
        Start-Sleep -Seconds 30

        # Scale down the old container
        docker-compose down --remove-orphans

        Write-Message "Deployment completed."
    } else {
        Write-Message "No changes detected."
    }
} catch {
    Write-Message "An error occurred: $_"
} finally {
    # Remove lock file
    Remove-Item -Path $lockFile
}
