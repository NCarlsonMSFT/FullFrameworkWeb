Param(
    [Parameter(ParameterSetName = "Build", Position = 0, Mandatory = $True)]
    [switch]$Build,
    [Parameter(ParameterSetName = "Clean", Position = 0, Mandatory = $True)]
    [switch]$Clean,
    [Parameter(ParameterSetName = "Run", Position = 0, Mandatory = $True)]
    [switch]$Run,
    [Parameter(ParameterSetName = "GetUrl", Position = 0, Mandatory = $True)]
    [switch]$GetUrl,
    [Parameter(ParameterSetName = "WaitForUrl", Position = 0, Mandatory = $True)]
    [switch]$WaitForUrl,
    [parameter(ParameterSetName = "Clean", Position = 1, Mandatory = $True)]
    [parameter(ParameterSetName = "Build", Position = 1, Mandatory = $True)]
    [parameter(ParameterSetName = "Run", Position = 1, Mandatory = $True)]
    [ValidateNotNullOrEmpty()]
    [String]$Environment,
    [parameter(ParameterSetName = "Clean", Position = 3, Mandatory = $False)]
    [parameter(ParameterSetName = "Build", Position = 3, Mandatory = $False)]
    [parameter(ParameterSetName = "Run", Position = 3, Mandatory = $False)]
    [ValidateNotNullOrEmpty()]
    [String]$ProjectFolder = (Split-Path -Path $MyInvocation.MyCommand.Definition),
    [parameter(ParameterSetName = "Build", Position = 5, Mandatory = $False)]
    [switch]$NoCache,
    [parameter(ParameterSetName = "Run", Position = 5, Mandatory = $False)]
    [bool]$OpenSite = $True
)

#TODO : Not this....
#TODO : Not this....
#TODO : Not this....
#TODO : Not this....
#TODO : Not this....
#TODO : Not this....
#TODO : Not this....
#TODO : Not this....
#TODO : Not this....
#TODO : Not this....
#TODO : Not this....
#TODO : Not this....
$Env:DevEnvDir = "C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\IDE\"
$Env:Framework40Version = "v4.0"
$Env:FrameworkDir = "C:\WINDOWS\Microsoft.NET\Framework\"
$Env:FrameworkDIR32 = "C:\WINDOWS\Microsoft.NET\Framework\"
$Env:FrameworkVersion = "v4.0.30319"
$Env:FrameworkVersion32 = "v4.0.30319"
$Env:INCLUDE = "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\INCLUDE;C:\Program Files (x86)\Windows Kits\NETFXSDK\4.6.1\include\um;"
$Env:LIB = "C:\Program Files (x86)\Windows Kits\NETFXSDK\4.6.1\lib\um\x86;"
$Env:LIBPATH = "C:\WINDOWS\Microsoft.NET\Framework\v4.0.30319;"
$Env:NETFXSDKDir = "C:\Program Files (x86)\Windows Kits\NETFXSDK\4.6.1\"
$Env:Path = "C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\IDE\CommonExtensions\Microsoft\TestWindow;C:\Program Files (x86)\MSBuild\14.0\bin;C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\IDE\;C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\BIN;C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\Tools;C:\WINDOWS\Microsoft.NET\Framework\v4.0.30319;C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\VCPackages;C:\Program Files (x86)\Microsoft Visual Studio 14.0\Team Tools\Performance Tools;C:\Program Files (x86)\Microsoft SDKs\Windows\v10.0A\bin\NETFX 4.6.1 Tools\;C:\Program Files\Common Files\Microsoft Shared\Microsoft Online Services;C:\Program Files (x86)\Common Files\Microsoft Shared\Microsoft Online Services;C:\WINDOWS\system32;C:\WINDOWS;C:\WINDOWS\System32\Wbem;C:\WINDOWS\System32\WindowsPowerShell\v1.0\;C:\Users\ncarlson\AppData\Local\Microsoft\WindowsApps;C:\Program Files\docker\;C:\WINDOWS\system32;C:\WINDOWS;C:\WINDOWS\System32\Wbem;C:\WINDOWS\System32\WindowsPowerShell\v1.0\;C:\Users\ncarlson\.dnx\bin;C:\Program Files\Microsoft DNX\Dnvm\;C:\Program Files\Microsoft SQL Server\120\Tools\Binn\;C:\Program Files\Microsoft SQL Server\130\Tools\Binn\;C:\Program Files\Git\cmd;C:\Users\ncarlson\AppData\Local\Microsoft\WindowsApps;;C:\Program Files (x86)\Microsoft VS Code\bin"
$Env:PATHEXT = ".COM;.EXE;.BAT;.CMD;.VBS;.VBE;.JS;.JSE;.WSF;.WSH;.MSC"
$Env:VCINSTALLDIR = "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\"
$Env:VisualStudioVersion = "14.0"
$Env:VS140COMNTOOLS = "C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\Tools\"
$Env:VSINSTALLDIR = "C:\Program Files (x86)\Microsoft Visual Studio 14.0\"
$Env:VSSDK140Install = "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VSSDK\"
$Env:WindowsLibPath = "References\CommonConfiguration\Neutral"
$Env:WindowsSDKLibVersion = "winv6.3\"
$Env:WindowsSDKVersion = "\"
$Env:WindowsSDK_ExecutablePath_x64 = "C:\Program Files (x86)\Microsoft SDKs\Windows\v10.0A\bin\NETFX 4.6.1 Tools\x64\"
$Env:WindowsSDK_ExecutablePath_x86 = "C:\Program Files (x86)\Microsoft SDKs\Windows\v10.0A\bin\NETFX 4.6.1 Tools\"





$ErrorActionPreference = "Stop"

# Turns VERBOSE output ON
$VerbosePreference = "Continue"

# The name of the image created by the compose file
$ImageName = "username/webapplication1"

# Kills all containers using an image, removes all containers using an image, and removes the image.
function Clean () {

    docker rm -f $(docker ps -a)

    # If $ImageName exists remove it
    $ImageNameRegEx = "\b$ImageName\b"
    docker images | select-string -pattern $ImageNameRegEx | foreach {
        $imageName = $_.Line.split(" ", [System.StringSplitOptions]::RemoveEmptyEntries)[0];
        $tag = $_.Line.split(" ", [System.StringSplitOptions]::RemoveEmptyEntries)[1];
        $shellCommand = "docker rmi -f ${imageName}:$tag"
        Write-Verbose "Executing: $shellCommand";
        Invoke-Expression "cmd /c $shellCommand `"2>&1`""
    }

    # Remove any dangling images (from previous builds)
    $shellCommand = "docker images -q --filter 'dangling=true'"
    Write-Verbose "Executing: $shellCommand"
    $danglingImages = $(Invoke-Expression "cmd /c $shellCommand `"2>&1`"")
    if (-not [String]::IsNullOrWhiteSpace($danglingImages)) {
        $shellCommand = "docker rmi -f $danglingImages"
        Write-Verbose "Executing: $shellCommand"
        Invoke-Expression "cmd /c $shellCommand `"2>&1`""
    }

    # If the folder for publishing exists, delete it
    if (Test-Path $pubPath) {
        Remove-Item $pubPath -Force -Recurse
    }
}

# Runs docker build.
function Build () {
    # Publish the project
    PublishProject

    $dockerFilePath = GetDockerFilePath($pubPath)

    $buildArgs = ""
    if ($NoCache)
    {
        $buildArgs = "--no-cache"
    }

    $taggedImageName = $ImageName
    if ($Environment -ne "Release") {
        $taggedImageName = "${ImageName}:$Environment"
    }

    # Call docker build on the published project to build the images
    $shellCommand = "docker build -f '$dockerFilePath' -t $taggedImageName $buildArgs '$pubPath'"
    Write-Verbose "Executing: $shellCommand"
    Invoke-Expression "cmd /c $shellCommand `"2>&1`""
    if ($LastExitCode -ne 0) {
        Write-Error "Failed to build the image"
    }
}

# Runs docker run
function Run () {
    $dockerFilePath = GetDockerFilePath($pubPath)

    $conflictingContainerIds = $(docker ps | select-string -pattern ":80->" | foreach { Write-Output $_.Line.split()[0] })

    if ($conflictingContainerIds) {
        $conflictingContainerIds = $conflictingContainerIds -Join ' '
        Write-Host "Stopping conflicting containers using port 80"
        $stopCommand = "docker stop $conflictingContainerIds"
        Write-Verbose "Executing: $stopCommand"
        Invoke-Expression "cmd /c $stopCommand `"2>&1`""
        if ($LastExitCode -ne 0) {
            Write-Error "Failed to stop the container(s)"
        }
    }

    $taggedImageName = $ImageName
    if ($Environment -ne "Release") {
        $taggedImageName = "${ImageName}:$Environment"
    }

    $shellCommand = "docker run -d -p 80:80 $taggedImageName"
    Write-Verbose "Executing: $shellCommand"
    Invoke-Expression "cmd /c $shellCommand `"2>&1`""
    if ($LastExitCode -ne 0) {
        Write-Error "Failed to start the container(s)"
    }

    if ($OpenSite) {
        OpenSite
    }
}

# Opens the remote site
function OpenSite () {
    # If we're going to debug, the server won't start immediately; don't need to wait for it.
    if (-not $RemoteDebugging)
    {
        $uri = GetUrl

        WaitForUrl $uri

        # Open the site.
        Start-Process $uri
    }
    else {
        # Give the container 10 seconds to get ready
        Start-Sleep 10
    }
} 

# Gets the Url of the remote container
function GetUrl () {
    $id = $(docker ps -a | select-string -pattern $imageName).Line.split()[0]
    $ip = $(docker inspect --format "{{ .NetworkSettings.Networks.nat.IPAddress }}" $id)
    return "http://$ip"
}

# Checks if the URL is responding
function WaitForUrl ([string]$uri) {
    Write-Host "Opening site $uri " -NoNewline
    $status = 0
    $count = 0

    #Check if the site is available
    while ($status -ne 200 -and $count -lt 120) {
        try {
            $response = Invoke-WebRequest -Uri $uri -Headers @{"Cache-Control"="no-cache";"Pragma"="no-cache"} -UseBasicParsing -Verbose:$false
            $status = [int]$response.StatusCode
        }
        catch [System.Net.WebException] { }
        if($status -ne 200) {
            Write-Host "." -NoNewline
            # Wait Time max. 2 minutes (120 sec.)
            Start-Sleep 1
            $count += 1
        }
    }
    Write-Host
    if($status -ne 200) {
        Write-Error "Failed to connect to $uri"
    }
}

# Publishes the project
function PublishProject () {
    try {
        Push-Location $ProjectFolder

        # Publish the project
        msbuild /p:WebPublishMethod=FileSystem /p:PublishUrl="$pubPath" /p:DeployOnBUild=true /p:DeployTarget=WebPublish /p:DockerBuild=False
    }
    finally {
        Pop-Location
    }
}

function GetDockerFilePath([string]$folder) {
    $dockerFileName = $Null
    if ($Environment -eq "Release") {
        $dockerFileName = "dockerfile"
    } else {
        $dockerFileName = "dockerfile.$Environment"
    }
    $dockerFileName = Join-Path $folder $dockerFileName

    if (Test-Path $dockerFileName) {
        return $dockerFileName
    } else {
        Write-Error -Message "$Environment is not a valid parameter. File '$dockerFileName' does not exist." -Category InvalidArgument
    }
}

# Our working directory in bin
$dockerBinFolder = Join-Path $ProjectFolder (Join-Path "bin" "Docker")
# The folder to publish the app to
$pubPath = Join-Path $dockerBinFolder "app"

# Call the correct functions for the parameters that were used
if ($Clean) {
    Clean
}
if ($Build) {
    Build
}
if ($Run) {
    Run
}
if ($GetUrl) {
    GetUrl
}
if ($WaitForUrl) {
    WaitForUrl (GetUrl)
}