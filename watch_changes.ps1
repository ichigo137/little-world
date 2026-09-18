# File change watcher for her_little_world
# Logs all changes to changes.log

$projectRoot = "C:\Users\roypa\Downloads\her_little_world\her_little_world"
$logFile = "$projectRoot\changes.log"

# Clear/create log
"=== Watch started at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ===" | Out-File $logFile

$folders = @("lib", "assets")
$filters = @("*.dart", "*.yaml", "*.txt", "*.wav", "*.mp3", "*.json")

$watchers = @()

foreach ($folder in $folders) {
    $path = Join-Path $projectRoot $folder
    if (Test-Path $path) {
        $watcher = New-Object System.IO.FileSystemWatcher
        $watcher.Path = $path
        $watcher.IncludeSubdirectories = $true
        $watcher.Filter = "*.*"
        $watcher.NotifyFilter = [System.IO.NotifyFilters]::LastWrite -bor [System.IO.NotifyFilters]::FileName -bor [System.IO.NotifyFilters]::Size
        $watcher.EnableRaisingEvents = $true
        $watchers += $watcher
    }
}

# Watch pubspec.yaml at root
$pubWatcher = New-Object System.IO.FileSystemWatcher
$pubWatcher.Path = $projectRoot
$pubWatcher.Filter = "pubspec.yaml"
$pubWatcher.NotifyFilter = [System.IO.NotifyFilters]::LastWrite -bor [System.IO.NotifyFilters]::FileName
$pubWatcher.EnableRaisingEvents = $true
$watchers += $pubWatcher

$action = {
    $details = $Event.SourceEventArgs
    $path = $details.FullPath
    $name = $details.Name
    $changeType = $details.ChangeType
    $time = Get-Date -Format "HH:mm:ss"

    # Get file size if exists
    $size = ""
    if (Test-Path $path) {
        $size = " ($(((Get-Item $path).Length / 1KB).ToString('0.0'))KB)"
    }

    $entry = "[$time] $changeType : $name$size"
    $entry | Out-File $logFile -Append
}

$handlers = @()
foreach ($w in $watchers) {
    $handlers += Register-ObjectEvent $w "Changed" -Action $action
    $handlers += Register-ObjectEvent $w "Created" -Action $action
    $handlers += Register-ObjectEvent $w "Deleted" -Action $action
    $handlers += Register-ObjectEvent $w "Renamed" -Action $action
}

Write-Host "Watching for changes in: lib/, assets/, pubspec.yaml"
Write-Host "Log file: $logFile"
Write-Host "Press Ctrl+C to stop."

try {
    while ($true) { Start-Sleep -Seconds 1 }
} finally {
    foreach ($h in $handlers) { Unregister-Event $h }
    foreach ($w in $watchers) { $w.Dispose() }
    "=== Watch stopped at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ===" | Out-File $logFile -Append
}
