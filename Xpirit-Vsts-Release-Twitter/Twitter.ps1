Param(
    [string] $Message,
    [string] $TwitterEndPoint
)

function Get-ModuleVersion($modulename){
    return (Get-Module -Name $modulename).Version
}

$mytwitterversion = Get-ModuleVersion ("mytwitter")
if ($mytwitterversion) {
    #mytwitter is installed on the system
	Write-Output "MyTwitter is installed $mytwitterversion"
} else {
	Write-Output "Intalling MyTwitter"
    
	$ScriptPath = $MyInvocation.MyCommand.Path
	$ScriptDirectory = (Split-Path $ScriptPath -Parent)
	$Module = Join-Path $ScriptDirectory "MyTwitter.zip"

    $unzipdir = Join-Path $env:temp "MyTwitter-master"
	if (Test-Path $unzipdir){
	    Remove-Item "$unzipdir" -recurse
	}

	Add-Type -Assembly System.IO.Compression.FileSystem
	[System.IO.Compression.ZipFile]::ExtractToDirectory($Module, $unzipdir)

    $modulePath = Join-Path $env:temp "MyTwitter-master\MyTwitter.psm1"  

	Import-Module $modulePath  -Verbose

    $mytwitterversion = Get-ModuleVersion ("mytwitter")
	Write-Output "MyTwitter installed $mytwitterversion"
}

$TwitterConfig = Get-ServiceEndpoint -Context $distributedTaskContext -Name $TwitterEndPoint
if(-not $TwitterConfig){
	Write-Output "Twitter Service Endpoint is null"
	return
}

$APIKey = $TwitterConfig.Authorization.Parameters.username
$APISecret = $TwitterConfig.Authorization.Parameters.password
$AccessToken = $TwitterConfig.Authorization.Parameters.AccessToken
$AccessTokenSecret = $TwitterConfig.Authorization.Parameters.AccessTokenSecret

#Write-Output "Configure tweeting"
New-MyTwitterConfiguration -APIKey $APIKey -APISecret $APISecret -AccessToken $AccessToken -AccessTokenSecret $AccessTokenSecret
Write-Output "Tweet message $Message"
Send-Tweet -Message $Message -Verbose
#Write-Output "Remove configuration tweeting"
Remove-MyTwitterConfiguration
