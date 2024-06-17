# Define the list of files and their corresponding port replacement functions
$filesAndFunctions = @(
    @{
        filePath = "$($config.billingDatabasePath)\BillingDatabaseFiles\docker-compose.yml"
        portPattern = '(\d+):\d+'
        replaceFunction = { param ($line, $newPorts, $portIndex, $portPattern) Switch-ReplacePorts -line $line -newPorts $newPorts -portIndex $portIndex -portPattern $portPattern }
    },
    @{
        filePath = "$($config.billingDatabasePath)\BillingDatabaseFiles\Dockerfile"
        portPattern = 'EXPOSE (\d+)'
        replaceFunction = { param ($line, $newPorts, $portIndex, $portPattern)
            if ($line -match $portPattern) {
                return "EXPOSE $($newPorts[0]) $($newPorts[1])"
            } else {
                return $line
            }
        }
    },
    @{
        filePath = "$($config.billingDatabasePath)\BillingDatabaseFiles\backend\Dockerfile"
        portPattern = 'EXPOSE (\d+)'
        replaceFunction = { param ($line, $newPorts, $portIndex, $portPattern)
            if ($line -match $portPattern) {
                return "EXPOSE $($newPorts[1])"
            } else {
                return $line
            }
        }
    },
    @{
        filePath = "$($config.billingDatabasePath)\BillingDatabaseFiles\frontend\Dockerfile"
        portPattern = 'EXPOSE (\d+)'
        replaceFunction = { param ($line, $newPorts, $portIndex, $portPattern)
            if ($line -match $portPattern) {
                return "EXPOSE $($newPorts[0])"
            } else {
                return $line
            }
        }
    },
    @{
        filePath = "$($config.billingDatabasePath)\BillingDatabaseFiles\frontend\Dockerfile"
        portPattern = 'ENV SET_BASE_URL="http://localhost:(\d+)"'
        replaceFunction = { param ($line, $newPorts, $portIndex, $portPattern)
            if ($line -match $portPattern) {
                return "ENV SET_BASE_URL=""http://localhost:$($newPorts[1])"""
            } else {
                return $line
            }
        }
    }
)
