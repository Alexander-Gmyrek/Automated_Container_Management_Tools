# Function to check if ports are open and replace them if necessary
function Confirm-Ports {
    param (
        [int[]]$ports,
        [int[]]$substitutePorts
    )
    $openPorts = @()
    foreach ($port in $ports) {
        $tcpConnections = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
        if ($tcpConnections) {
            Write-Message "Port $port is occupied."
        } else {
            $openPorts += $port
        }
    }

    if ($openPorts.Count -lt $ports.Count) {
        foreach ($port in $substitutePorts) {
            if ($openPorts.Count -eq $ports.Count) {
                break
            }
            $tcpConnections = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
            if (-not $tcpConnections) {
                $openPorts += $port
            }
        }
    }

    if ($openPorts.Count -lt $ports.Count) {
        $occupiedPorts = $ports | Where-Object { $_ -notin $openPorts }
        foreach ($port in $occupiedPorts) {
            if($openPorts.Count -lt $ports.Count) {
                $tcpConnections = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
                if ($tcpConnections) {
                    $processId = $tcpConnections.OwningProcess
                    $answer = read-host "Port $port is occupied by process with ID $processId. Do you want to stop the process? (Y/N)"
                    if ($answer -eq 'yes') { 
                        $process = Get-Process -Id $processId
                        $process | Stop-Process -Force
                        Write-Message "Stopped process using port $port (Process ID: $processId)"
                        $openPorts += $port
                    }  
                }
            }
        }
    }

    return $openPorts
}

# Make sure the ports are ordered correctly to avoid unnecessary changes in files
function Switch-OpenPorts {
    param (
        [int[]]$openPorts,
        [int[]]$requiredPorts
    )

    $n = $openPorts.Length
    if ($n -ne $requiredPorts.Length -or $n -le 1) {
        throw "Both arrays must have the same length greater than 1"
    }

    for ($i = 0; $i -lt $n; $i++) {
        for ($j = 0; $j -lt $n; $j++) {
            if ($openPorts[$i] -eq $requiredPorts[$j]) {
                $temp = $openPorts[$i]
                $openPorts[$i] = $openPorts[$j]
                $openPorts[$j] = $temp
            }
        }
    }
    
    return $openPorts
}

# Function to replace ports in a line of text
function Switch-ReplacePorts {
    param (
        [string]$line,
        [int[]]$newPorts,
        [ref]$portIndex,
        [string]$portPattern
    )

    if ($line -match $portPattern -and $portIndex.Value -lt $newPorts.Length) {
        $newPort = $newPorts[$portIndex.Value]
        $portIndex.Value++
        return $line -replace $portPattern, "${newPort}:$newPort"
    } else {
        return $line
    }
}

# Abstract function to automate port switching in multiple files
function Request-PortSwitching {
    param (
        [int[]]$requiredPorts,
        [int[]]$substitutePorts,
        [hashtable[]]$filesAndFunctions
    )

    $openPorts = Confirm-Ports -ports $requiredPorts -substitutePorts $substitutePorts
    if ($openPorts.Count -lt $requiredPorts.Count) {
        throw "Unable to open required ports."
    }

    $openPorts = Switch-OpenPorts -openPorts $openPorts -requiredPorts $requiredPorts

    if ($openPorts -ne $requiredPorts) {
        foreach ($fileAndFunction in $filesAndFunctions) {
            $filePath = $fileAndFunction["filePath"]
            $portPattern = $fileAndFunction["portPattern"]
            $replaceFunction = $fileAndFunction["replaceFunction"]
            $portIndex = 0
            $fileContent = Get-Content $filePath
            $updatedFileContent = $fileContent | ForEach-Object {
                & $replaceFunction -line $_ -newPorts $openPorts -portIndex ([ref]$portIndex) -portPattern $portPattern
            }
            $updatedFileContent | Set-Content $filePath
            Write-Output "Port numbers have been successfully updated in $filePath"
        }
    }
}
