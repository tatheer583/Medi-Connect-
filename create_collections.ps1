# Run this AFTER creating the database in Appwrite Console
# Usage: .\create_collections.ps1 -DatabaseId "YOUR_DB_ID"

param(
    [Parameter(Mandatory=$true)]
    [string]$DatabaseId
)

$ApiKey = "YOUR_APPWRITE_API_KEY"
$ProjectId = "YOUR_APPWRITE_PROJECT_ID"
$Endpoint = "https://fra.cloud.appwrite.io/v1"
$H = @{ "Content-Type"="application/json"; "X-Appwrite-Project"=$ProjectId; "X-Appwrite-Key"=$ApiKey }

function AW { param($M,$P,$B=$null)
    try {
        if($B){ Invoke-RestMethod -Method $M -Uri "$Endpoint$P" -Headers $H -Body ($B|ConvertTo-Json -Depth 10) }
        else { Invoke-RestMethod -Method $M -Uri "$Endpoint$P" -Headers $H }
    } catch {
        $e = $_.ErrorDetails.Message | ConvertFrom-Json -EA SilentlyContinue
        if($e.type -ne "collection_already_exists" -and $e.type -ne "attribute_already_exists") {
            Write-Host "  WARN: $($e.message)" -ForegroundColor Yellow
        }
        return $null
    }
}

function Col { param($Id,$Name)
    Write-Host "  Collection: $Name ($Id)" -ForegroundColor Cyan
    AW POST "/databases/$DatabaseId/collections" @{
        collectionId=$Id; name=$Name
        permissions=@('create("any")','read("any")','update("any")','delete("any")')
        documentSecurity=$false
    } | Out-Null
}

function Str { param($Col,$Key,$Size,$Req=$true)
    AW POST "/databases/$DatabaseId/collections/$Col/attributes/string" @{ key=$Key; size=$Size; required=$Req } | Out-Null
    Write-Host "    + $Key (String $Size)" -ForegroundColor Gray
}

function Bool { param($Col,$Key,$Req=$true)
    AW POST "/databases/$DatabaseId/collections/$Col/attributes/boolean" @{ key=$Key; required=$Req } | Out-Null
    Write-Host "    + $Key (Boolean)" -ForegroundColor Gray
}

Write-Host "`n=== Creating Collections in: $DatabaseId ===" -ForegroundColor Green

# users
Col "users" "Users"
Start-Sleep -Seconds 1
Str "users" "userId" 36
Str "users" "email" 100
Str "users" "role" 20
Str "users" "fullName" 100
Str "users" "phone" 20 $false
Str "users" "createdAt" 50

# appointments
Col "appointments" "Appointments"
Start-Sleep -Seconds 1
Str "appointments" "patientId" 36
Str "appointments" "patientName" 100
Str "appointments" "doctorId" 36
Str "appointments" "doctorName" 100
Str "appointments" "specialty" 100
Str "appointments" "date" 50
Str "appointments" "timeSlot" 50
Str "appointments" "fee" 20
Str "appointments" "status" 20
Str "appointments" "clinicId" 36 $false
Str "appointments" "notes" 500 $false
Str "appointments" "createdAt" 50

# prescriptions
Col "prescriptions" "Prescriptions"
Start-Sleep -Seconds 1
Str "prescriptions" "doctorId" 36
Str "prescriptions" "doctorName" 100
Str "prescriptions" "patientId" 36
Str "prescriptions" "patientName" 100
Str "prescriptions" "diagnosis" 500
Str "prescriptions" "instructions" 500 $false
Str "prescriptions" "appointmentId" 36 $false
Str "prescriptions" "createdAt" 50

# chat_messages
Col "chat_messages" "Chat Messages"
Start-Sleep -Seconds 1
Str "chat_messages" "senderId" 36
Str "chat_messages" "receiverId" 36
Str "chat_messages" "senderName" 100
Str "chat_messages" "text" 1000
Str "chat_messages" "chatId" 100
Bool "chat_messages" "read"
Str "chat_messages" "createdAt" 50

# lab_results
Col "lab_results" "Lab Results"
Start-Sleep -Seconds 1
Str "lab_results" "patientId" 36
Str "lab_results" "testName" 100
Str "lab_results" "uploadedBy" 100
Str "lab_results" "fileId" 100
Str "lab_results" "fileUrl" 500 $false
Str "lab_results" "fileType" 20
Str "lab_results" "uploadedAt" 50

# medicine_reminders
Col "medicine_reminders" "Medicine Reminders"
Start-Sleep -Seconds 1
Str "medicine_reminders" "userId" 36
Str "medicine_reminders" "medicineName" 100
Str "medicine_reminders" "dosage" 50
Str "medicine_reminders" "time" 20
Bool "medicine_reminders" "active"
Bool "medicine_reminders" "takenToday"
Str "medicine_reminders" "createdAt" 50

# doctors
Col "doctors" "Doctors"
Start-Sleep -Seconds 1
Str "doctors" "name" 100
Str "doctors" "specialty" 100
Str "doctors" "fee" 20
Str "doctors" "rating" 10
Str "doctors" "userId" 36 $false
Bool "doctors" "available"

# Storage buckets
Write-Host "`n  Creating storage buckets..." -ForegroundColor Cyan
AW POST "/storage/buckets" @{
    bucketId="lab_results_files"; name="Lab Results Files"
    permissions=@('create("any")','read("any")','update("any")','delete("any")')
    fileSecurity=$false; maximumFileSize=10485760
    allowedFileExtensions=@("pdf","jpg","jpeg","png")
} | Out-Null
Write-Host "    + lab_results_files" -ForegroundColor Gray

AW POST "/storage/buckets" @{
    bucketId="prescriptions_files"; name="Prescription Files"
    permissions=@('create("any")','read("any")','update("any")','delete("any")')
    fileSecurity=$false; maximumFileSize=5242880
    allowedFileExtensions=@("pdf")
} | Out-Null
Write-Host "    + prescriptions_files" -ForegroundColor Gray

# Test document
Write-Host "`n  Testing with a document..." -ForegroundColor Cyan
Start-Sleep -Seconds 2
$test = AW POST "/databases/$DatabaseId/collections/users/documents" @{
    documentId="test_delete_me"
    data=@{ userId="test"; email="test@test.com"; role="patient"; fullName="Test"; createdAt=(Get-Date -Format "o") }
    permissions=@()
}
if($test) {
    Write-Host "  ✅ Test document created" -ForegroundColor Green
    AW DELETE "/databases/$DatabaseId/collections/users/documents/test_delete_me" | Out-Null
    Write-Host "  ✅ Test document deleted" -ForegroundColor Green
}

# Update .env files
$envPath = "c:\Users\1\Medi Connect\backend-node\.env"
$env = Get-Content $envPath -Raw
$env = $env -replace "APPWRITE_DATABASE_ID=.*", "APPWRITE_DATABASE_ID=$DatabaseId"
Set-Content $envPath $env
Write-Host "`n  ✅ backend-node/.env updated with DATABASE_ID=$DatabaseId" -ForegroundColor Green

Write-Host "`n=== ALL DONE ===" -ForegroundColor Green
Write-Host "Project ID:  6a14834f003c65073c46"
Write-Host "Database ID: $DatabaseId"
Write-Host "Collections: users, appointments, prescriptions, chat_messages, lab_results, medicine_reminders, doctors"
Write-Host "Buckets:     lab_results_files, prescriptions_files"
