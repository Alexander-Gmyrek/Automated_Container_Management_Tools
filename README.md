# Automated_Container_Management_Tools
These are tools I am using to manage my containers on a windows server

All you need to do is update the configuration file to contain your paths, navigate to the folder in powershell and run update_scripts.ps1. Then follow the set up instructions for each of the automations you want to use. That should be it. Feel fre to automate the set up further if you want, or automate the set up of the set up. Go crazy with it!

Ok so I automated it so now all you need to do is fill out the config.txt file and run automate set up and it will get all the automations running for you!

Ok so I intogerated and automated the instalation, deployment, and matnince proccess so now its all one step. You can still pick and chose some of these tools to use for your own projects and I will probaly add more in the future, but if you just want to get the database up and running go use the Billing_Database_Installer.

Added automated port switching to use call
. .\port_switching.ps1
to load the functions.
Create a hash table like this one
$filesAndFunctions = @(
    @{
        filePath = "/your/file/path"
        portPattern = '(\d+):\d+'
        replaceFunction = { param ($line, $newPorts, $portIndex, $portPattern) Switch-ReplacePorts -line $line -newPorts $newPorts -portIndex $portIndex -portPattern $portPattern }
    },
    @{
        filePath = "/your/file/path"
        portPattern = 'EXPOSE (\d+)'
        replaceFunction = { param ($line, $newPorts, $portIndex, $portPattern)
            if ($line -match $portPattern) {
                return "EXPOSE $($newPorts[0]) $($newPorts[1])"
            } else {
                return $line
            }
        }
    }
)

Then call the function (Pay attention to the order of your required ports)
Request-PortSwitching -requiredPorts $requiredPorts -substitutePorts $substitutePorts -filesAndFunctions $filesAndFunctions