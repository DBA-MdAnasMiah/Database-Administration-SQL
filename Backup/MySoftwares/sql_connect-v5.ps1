# ======================================================================
# SIMPLE/Simple backup -  VERSION 0.1
# Author      : Md Anas Miah
# Created     : 2025-11-14
# ======================================================================

Add-Type -AssemblyName "System.Data"

Write-Host "==============================================================="
Write-Host "        SIMPLE/Simple backup software - By Anas"
Write-Host "==============================================================="
Write-Host "Author       : Md Anas Miah"
Write-Host "Date         : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Host "Created By   : DBA MD ANAS MIAH"
Write-Host "---------------------------------------------------------------"
Write-Host ""

# ----------------------------------------------------------------------
#  backup mode
# ----------------------------------------------------------------------
do {
    Write-Host "Choose your Backup Mode:"
    Write-Host "1 = Backup SINGLE Database"
    Write-Host "2 = Backup ALL USER Databases"
    $backupMode = Read-Host "Enter option (1 or 2)"

    if ($backupMode -ne "1" -and $backupMode -ne "2") {
        Write-Host "Invalid option. Please enter 1 or 2."
    }
} until ($backupMode -eq "1" -or $backupMode -eq "2")

# ----------------------------------------------------------------------
# server connection
# ----------------------------------------------------------------------
$conn = $null

do {
    $serverInstance = Read-Host "Enter SQL Server instance"

    $connString = "Server=$serverInstance;Database=master;Integrated Security=True;"
    $conn = New-Object System.Data.SqlClient.SqlConnection $connString

    try {
        $conn.Open()
        Write-Host "Connected to SQL Server successfully." -ForegroundColor Green
        $connectionSuccess = $true
    }
    catch {
        Write-Host ""
        Write-Host "ERROR: Cannot connect to SQL Server." -ForegroundColor Red
        Write-Host "INFO : Check server name spelling, network, or SQL permissions, then try again."
        Write-Host ""
        $connectionSuccess = $false
    }

} until ($connectionSuccess -eq $true)

Write-Host ""

# ----------------------------------------------------------------------
# backup path
# ----------------------------------------------------------------------
do {
    $backupDir = Read-Host "Enter backup folder path (e.g. D:\SQLBackups)"

    if (!(Test-Path $backupDir)) {
        Write-Host "ERROR: Folder does not exist. Please check the path and try again." -ForegroundColor Red
        $folderOK = $false
    }
    else {
        $folderOK = $true
    }
} until ($folderOK -eq $true)

# ----------------------------------------------------------------------
# copy only backup option
# ----------------------------------------------------------------------
do {
    Write-Host ""
    Write-Host "Copy_Only Backup?"
    Write-Host "1 = YES"
    Write-Host "2 = NO"
    $copyChoice = Read-Host "Enter option (1 or 2)"

    if ($copyChoice -ne "1" -and $copyChoice -ne "2") {
        Write-Host "Invalid option. Please enter 1 or 2."
    }
} until ($copyChoice -eq "1" -or $copyChoice -eq "2")

$useCopyOnly = ($copyChoice -eq "1")

# ----------------------------------------------------------------------
# compression options
# ----------------------------------------------------------------------
do {
    Write-Host ""
    Write-Host "Use Compression?"
    Write-Host "1 = YES"
    Write-Host "2 = NO"
    $compressChoice = Read-Host "Enter option (1 or 2)"

    if ($compressChoice -ne "1" -and $compressChoice -ne "2") {
        Write-Host "Invalid option. Please enter 1 or 2."
    }
} until ($compressChoice -eq "1" -or $compressChoice -eq "2")

$useCompression = ($compressChoice -eq "1")

# ----------------------------------------------------------------------
# SQL OPTIONS TEXT
# ----------------------------------------------------------------------
$copyOnlyText = if ($useCopyOnly) { "COPY_ONLY," } else { "" }
$compressionText = if ($useCompression) { "COMPRESSION" } else { "NO_COMPRESSION" }

# **********************************************************************
# option 1: single database backup with looping
# **********************************************************************
if ($backupMode -eq "1") {

    do {
        $db = Read-Host "Enter database name"

        # Check if database exists
        $checkSql = "SELECT CASE WHEN EXISTS (SELECT 1 FROM sys.databases WHERE name = '$db') THEN 1 ELSE 0 END;"
        $cmdCheck = $conn.CreateCommand()
        $cmdCheck.CommandText = $checkSql

        try {
            $dbExists = [int]$cmdCheck.ExecuteScalar()
        }
        catch {
            $dbExists = 0
        }

        if ($dbExists -eq 0) {
            Write-Host "ERROR: Database '$db' not found." -ForegroundColor Red
            Write-Host "INFO : Check the database name and try again."
            $validDb = $false
        }
        else {
            $validDb = $true
        }

    } until ($validDb -eq $true)

    # At this point, $db is guaranteed to be a valid database name
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $file = "$backupDir\$db-FULL-$timestamp.bak"

    $sql = "BACKUP DATABASE [$db] TO DISK = '$file' WITH $copyOnlyText INIT, $compressionText, STATS = 10;"

    $cmd = $conn.CreateCommand()
    $cmd.CommandText = $sql

    try {
        $cmd.ExecuteNonQuery()
        Write-Host "SUCCESS: Backup completed for $db" -ForegroundColor Green
        Write-Host "Backup File: $file"
    }
    catch {
        Write-Host "ERROR: Backup failed for $db" -ForegroundColor Red
        Write-Host "INFO : Check SQL permissions or error logs."
    }
}

# **********************************************************************
# option 2; backup all user databases
# **********************************************************************
if ($backupMode -eq "2") {

    $sqlList = "SELECT name FROM sys.databases WHERE database_id > 4"
    $cmdList = $conn.CreateCommand()
    $cmdList.CommandText = $sqlList

    try {
        $reader = $cmdList.ExecuteReader()
    }
    catch {
        Write-Host "ERROR: Cannot fetch user databases." -ForegroundColor Red
        $conn.Close()
        exit
    }

    $dbs = @()
    while ($reader.Read()) {
        $dbs += $reader["name"]
    }
    $reader.Close()

    foreach ($db in $dbs) {

        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $file = "$backupDir\$db-FULL-$timestamp.bak"

        $sql = "BACKUP DATABASE [$db] TO DISK = '$file' WITH $copyOnlyText INIT, $compressionText, STATS = 10;"

        $cmd = $conn.CreateCommand()
        $cmd.CommandText = $sql

        try {
            $cmd.ExecuteNonQuery()
            Write-Host "SUCCESS: Backup completed for $db" -ForegroundColor Green
        }
        catch {
            Write-Host "ERROR: Backup failed for $db" -ForegroundColor Red
        }
    }

    Write-Host ""
    Write-Host "SUCCESS: All user database backups completed." -ForegroundColor Green
}

$conn.Close()

Write-Host ""
Write-Host "==============================================================="
Write-Host "                    BACKUP FINISHED"
Write-Host "==============================================================="
