# Appwrite Database Setup

Create the following in your Appwrite Console at https://fra.cloud.appwrite.io

## 1. Create Database
- Database ID: `mediconnect_db`
- Name: MediConnect

## 2. Create Collections

### appointments
| Attribute | Type | Required |
|-----------|------|----------|
| patientId | String | Yes |
| patientName | String | Yes |
| doctorId | String | Yes |
| doctorName | String | Yes |
| specialty | String | Yes |
| date | String | Yes |
| timeSlot | String | Yes |
| fee | String | Yes |
| status | String | Yes (default: "pending") |
| createdAt | String | Yes |

### prescriptions
| Attribute | Type | Required |
|-----------|------|----------|
| doctorId | String | Yes |
| doctorName | String | Yes |
| patientId | String | Yes |
| patientName | String | Yes |
| diagnosis | String | Yes |
| medicines | String[] | Yes |
| instructions | String | No |
| createdAt | String | Yes |

### medicine_reminders
| Attribute | Type | Required |
|-----------|------|----------|
| userId | String | Yes |
| medicineName | String | Yes |
| dosage | String | Yes |
| time | String | Yes |
| active | Boolean | Yes |
| takenToday | Boolean | Yes |
| createdAt | String | Yes |

### chat_messages
| Attribute | Type | Required |
|-----------|------|----------|
| senderId | String | Yes |
| receiverId | String | Yes |
| senderName | String | Yes |
| text | String | Yes |
| chatId | String | Yes |
| read | Boolean | Yes |
| createdAt | String | Yes |

### lab_results
| Attribute | Type | Required |
|-----------|------|----------|
| patientId | String | Yes |
| testName | String | Yes |
| uploadedBy | String | Yes |
| fileId | String | Yes |
| fileType | String | Yes |
| uploadedAt | String | Yes |

### doctors
| Attribute | Type | Required |
|-----------|------|----------|
| name | String | Yes |
| specialty | String | Yes |
| fee | String | Yes |
| rating | String | Yes |
| available | Boolean | Yes |

## 3. Create Storage Buckets
- Bucket ID: `lab_results_files` — for lab result PDFs/images
- Bucket ID: `prescriptions_files` — for prescription PDFs

## 4. Set Permissions
For each collection, add these permissions:
- Read: users
- Create: users
- Update: users
- Delete: users

## 5. Add Indexes (for queries)
- appointments: index on `patientId`, `doctorId`
- chat_messages: index on `chatId`
- medicine_reminders: index on `userId`
- lab_results: index on `patientId`
- prescriptions: index on `patientId`

## 6. Claude API Key
In `lib/src/services/ai_service.dart`, replace:
```
static const String _apiKey = 'YOUR_CLAUDE_API_KEY';
```
With your actual Anthropic API key from https://console.anthropic.com
