# MediConnect Appwrite Database Setup Script
# Run this script after providing your API key

param(
    [Parameter(Mandatory=$true)]
    [string]$ApiKey
)

$ProjectId = "6a14834f003c65073c46"
$Endpoint = "https://fra.cloud.appwrite.io/v1"
$DatabaseId = "mediconnect_db"

$Headers = @{
    "Content-Type" = "application/json"
    "X-Appwrite-Project" = $ProjectId
    "X-Appwrite-Key" = $ApiKey
}

function Invoke-AppwriteAPI {
    param($Method, $Path, $Body = $null)
    $Uri = "$Endpoint$Path"
    try {
        if ($Body) {
            $Response = Invoke-RestMethod -Method $Method -Uri $Uri -Headers $Headers -Body ($Body | ConvertTo-Json -Depth 10)
        } else {
            $Response = Invoke-RestMethod -Method $Method -Uri $Uri -Headers $Headers
        }
        return $Response
    } catch {
        $ErrorBody = $_.ErrorDetails.Message | ConvertFrom-Json -ErrorAction SilentlyContinue
        Write-Host "  ERROR: $($ErrorBody.message ?? $_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

Write-Host "`n=== MediConnect Appwrite Setup ===" -ForegroundColor Cyan

# ─── Create Database ──────────────────────────────────────────────────────────
Write-Host "`n[1/7] Creating database: $DatabaseId" -ForegroundColor Yellow
$db = Invoke-AppwriteAPI -Method POST -Path "/databases" -Body @{
    databaseId = $DatabaseId
    name = "MediConnect DB"
}
if ($db) { Write-Host "  ✅ Database created: $DatabaseId" -ForegroundColor Green }

# ─── Helper: Create Collection ────────────────────────────────────────────────
function New-Collection {
    param($CollectionId, $Name)
    Write-Host "`n  Creating collection: $Name" -ForegroundColor Yellow
    $col = Invoke-AppwriteAPI -Method POST -Path "/databases/$DatabaseId/collections" -Body @{
        collectionId = $CollectionId
        name = $Name
        permissions = @("create(\"any\")", "read(\"any\")", "update(\"any\")", "delete(\"any\")")
        documentSecurity = $false
    }
    if ($col) { Write-Host "  ✅ Collection: $CollectionId" -ForegroundColor Green }
    return $col
}

# ─── Helper: Create Attribute ─────────────────────────────────────────────────
function New-StringAttr {
    param($CollectionId, $Key, $Size, $Required)
    Invoke-AppwriteAPI -Method POST -Path "/databases/$DatabaseId/collections/$CollectionId/attributes/string" -Body @{
        key = $Key
        size = $Size
        required = $Required
    } | Out-Null
    Write-Host "    + $Key (String, $Size)" -ForegroundColor Gray
}

function New-BoolAttr {
    param($CollectionId, $Key, $Required)
    Invoke-AppwriteAPI -Method POST -Path "/databases/$DatabaseId/collections/$CollectionId/attributes/boolean" -Body @{
        key = $Key
        required = $Required
    } | Out-Null
    Write-Host "    + $Key (Boolean)" -ForegroundColor Gray
}

# ─── COLLECTION 1: users ──────────────────────────────────────────────────────
Write-Host "`n[2/7] Creating collections..." -ForegroundColor Yellow
$usersCol = New-Collection -CollectionId "users" -Name "Users"
Start-Sleep -Milliseconds 500
New-StringAttr "users" "userId" 36 $true
New-StringAttr "users" "email" 100 $true
New-StringAttr "users" "role" 20 $true
New-StringAttr "users" "fullName" 100 $true
New-StringAttr "users" "phone" 20 $false
New-StringAttr "users" "createdAt" 50 $true

# ─── COLLECTION 2: appointments ───────────────────────────────────────────────
$aptsCol = New-Collection -CollectionId "appointments" -Name "Appointments"
Start-Sleep -Milliseconds 500
New-StringAttr "appointments" "patientId" 36 $true
New-StringAttr "appointments" "patientName" 100 $true
New-StringAttr "appointments" "doctorId" 36 $true
New-StringAttr "appointments" "doctorName" 100 $true
New-StringAttr "appointments" "specialty" 100 $true
New-StringAttr "appointments" "date" 50 $true
New-StringAttr "appointments" "timeSlot" 50 $true
New-StringAttr "appointments" "fee" 20 $true
New-StringAttr "appointments" "status" 20 $true
New-StringAttr "appointments" "clinicId" 36 $false
New-StringAttr "appointments" "notes" 500 $false
New-StringAttr "appointments" "createdAt" 50 $true

# ─── COLLECTION 3: prescriptions ─────────────────────────────────────────────
$rxCol = New-Collection -CollectionId "prescriptions" -Name "Prescriptions"
Start-Sleep -Milliseconds 500
New-StringAttr "prescriptions" "doctorId" 36 $true
New-StringAttr "prescriptions" "doctorName" 100 $true
New-StringAttr "prescriptions" "patientId" 36 $true
New-StringAttr "prescriptions" "patientName" 100 $true
New-StringAttr "prescriptions" "diagnosis" 500 $true
New-StringAttr "prescriptions" "instructions" 500 $false
New-StringAttr "prescriptions" "appointmentId" 36 $false
New-StringAttr "prescriptions" "createdAt" 50 $true

# ─── COLLECTION 4: messages (chat) ───────────────────────────────────────────
$chatCol = New-Collection -CollectionId "chat_messages" -Name "Chat Messages"
Start-Sleep -Milliseconds 500
New-StringAttr "chat_messages" "senderId" 36 $true
New-StringAttr "chat_messages" "receiverId" 36 $true
New-StringAttr "chat_messages" "senderName" 100 $true
New-StringAttr "chat_messages" "text" 1000 $true
New-StringAttr "chat_messages" "chatId" 100 $true
New-BoolAttr   "chat_messages" "read" $true
New-StringAttr "chat_messages" "createdAt" 50 $true

# ─── COLLECTION 5: lab_results ───────────────────────────────────────────────
$labCol = New-Collection -CollectionId "lab_results" -Name "Lab Results"
Start-Sleep -Milliseconds 500
New-StringAttr "lab_results" "patientId" 36 $true
New-StringAttr "lab_results" "testName" 100 $true
New-StringAttr "lab_results" "uploadedBy" 100 $true
New-StringAttr "lab_results" "fileId" 100 $true
New-StringAttr "lab_results" "fileUrl" 500 $false
New-StringAttr "lab_results" "fileType" 20 $true
New-StringAttr "lab_results" "uploadedAt" 50 $true

# ─── COLLECTION 6: medicine_reminders ────────────────────────────────────────
$remCol = New-Collection -CollectionId "medicine_reminders" -Name "Medicine Reminders"
Start-Sleep -Milliseconds 500
New-StringAttr "medicine_reminders" "userId" 36 $true
New-StringAttr "medicine_reminders" "medicineName" 100 $true
New-StringAttr "medicine_reminders" "dosage" 50 $true
New-StringAttr "medicine_reminders" "time" 20 $true
New-BoolAttr   "medicine_reminders" "active" $true
New-BoolAttr   "medicine_reminders" "takenToday" $true
New-StringAttr "medicine_reminders" "createdAt" 50 $true

# ─── COLLECTION 7: doctors ───────────────────────────────────────────────────
$docCol = New-Collection -CollectionId "doctors" -Name "Doctors"
Start-Sleep -Milliseconds 500
New-StringAttr "doctors" "name" 100 $true
New-StringAttr "doctors" "specialty" 100 $true
New-StringAttr "doctors" "fee" 20 $true
New-StringAttr "doctors" "rating" 10 $true
New-StringAttr "doctors" "userId" 36 $false
New-BoolAttr   "doctors" "available" $true

# ─── Create Storage Buckets ───────────────────────────────────────────────────
Write-Host "`n[3/7] Creating storage buckets..." -ForegroundColor Yellow

$labBucket = Invoke-AppwriteAPI -Method POST -Path "/storage/buckets" -Body @{
    bucketId = "lab_results_files"
    name = "Lab Results Files"
    permissions = @("create(\"any\")", "read(\"any\")", "update(\"any\")", "delete(\"any\")")
    fileSecurity = $false
    maximumFileSize = 10485760
    allowedFileExtensions = @("pdf", "jpg", "jpeg", "png")
}
if ($labBucket) { Write-Host "  ✅ Bucket: lab_results_files" -ForegroundColor Green }

$rxBucket = Invoke-AppwriteAPI -Method POST -Path "/storage/buckets" -Body @{
    bucketId = "prescriptions_files"
    name = "Prescription Files"
    permissions = @("create(\"any\")", "read(\"any\")", "update(\"any\")", "delete(\"any\")")
    fileSecurity = $false
    maximumFileSize = 5242880
    allowedFileExtensions = @("pdf")
}
if ($rxBucket) { Write-Host "  ✅ Bucket: prescriptions_files" -ForegroundColor Green }

# ─── Test connection ──────────────────────────────────────────────────────────
Write-Host "`n[4/7] Testing connection with a test document..." -ForegroundColor Yellow
Start-Sleep -Seconds 2

$testDoc = Invoke-AppwriteAPI -Method POST -Path "/databases/$DatabaseId/collections/users/documents" -Body @{
    documentId = "test_doc_delete_me"
    data = @{
        userId = "test-123"
        email = "test@mediconnect.app"
        role = "patient"
        fullName = "Test User"
        createdAt = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
    }
    permissions = @()
}

if ($testDoc) {
    Write-Host "  ✅ Test document created" -ForegroundColor Green
    # Delete test doc
    Invoke-AppwriteAPI -Method DELETE -Path "/databases/$DatabaseId/collections/users/documents/test_doc_delete_me" | Out-Null
    Write-Host "  ✅ Test document deleted" -ForegroundColor Green
}

# ─── Update .env files ────────────────────────────────────────────────────────
Write-Host "`n[5/7] Updating .env files..." -ForegroundColor Yellow

$backendEnvPath = "c:\Users\1\Medi Connect\backend-node\.env"
$envContent = Get-Content $backendEnvPath -Raw
$envContent = $envContent -replace "APPWRITE_PROJECT_ID=.*", "APPWRITE_PROJECT_ID=$ProjectId"
$envContent = $envContent -replace "APPWRITE_API_KEY=.*", "APPWRITE_API_KEY=$ApiKey"
$envContent = $envContent -replace "APPWRITE_DATABASE_ID=.*", "APPWRITE_DATABASE_ID=$DatabaseId"
$envContent = $envContent -replace "APPWRITE_ENDPOINT=.*", "APPWRITE_ENDPOINT=$Endpoint"
Set-Content $backendEnvPath $envContent
Write-Host "  ✅ backend-node/.env updated" -ForegroundColor Green

# ─── Summary ─────────────────────────────────────────────────────────────────
Write-Host "`n=== SETUP COMPLETE ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Project ID:    $ProjectId" -ForegroundColor White
Write-Host "Database ID:   $DatabaseId" -ForegroundColor White
Write-Host "Endpoint:      $Endpoint" -ForegroundColor White
Write-Host ""
Write-Host "Collections created:" -ForegroundColor White
Write-Host "  - users" -ForegroundColor Gray
Write-Host "  - appointments" -ForegroundColor Gray
Write-Host "  - prescriptions" -ForegroundColor Gray
Write-Host "  - chat_messages" -ForegroundColor Gray
Write-Host "  - lab_results" -ForegroundColor Gray
Write-Host "  - medicine_reminders" -ForegroundColor Gray
Write-Host "  - doctors" -ForegroundColor Gray
Write-Host ""
Write-Host "Storage buckets:" -ForegroundColor White
Write-Host "  - lab_results_files" -ForegroundColor Gray
Write-Host "  - prescriptions_files" -ForegroundColor Gray
Write-Host ""
Write-Host "✅ All done! Your Appwrite database is ready." -ForegroundColor Green
