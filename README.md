# Automated_Container_Management_Tools
These are tools I am using to manage my containers on a Windows server. An update is coming soon.

All you need to do is update the configuration file to contain your paths, navigate to the folder in Powershell and run update_scripts.ps1. Then follow the setup instructions for each of the automations you want to use. That should be it. Feel free to automate the setup further if you want, or automate the setup of the setup. Go crazy with it!

Ok so I automated it so now all you need to do is fill out the config.txt file and run Automate Set Up and it will get all the automation running for you!

Ok, so I integrated and automated the installation, deployment, and maintenance process so now it's all one step. You can still pick and chose some of these tools to use for your own projects and I will probably add more in the future, but if you just want to get the database up and running go use the Billing_Database_Installer.

Added automated port switching functionality and added it to db setup.
To for yourself use call
. .\port_switching.ps1
to load the functions.
Create a hash table like this one and put it in a file like \PortReplacementConfig.ps1 
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

Load it with # Load the port replacement configuration
. .\PortReplacementConfig.ps1

Then call the function
Request-PortSwitching -requiredPorts $requiredPorts -substitutePorts $substitutePorts -filesAndFunctions $filesAndFunctions
