// Appwrite document base fields
export interface AppwriteDocument {
  $id: string;
  $sequence: string;
  $createdAt: string;
  $updatedAt: string;
  $collectionId: string;
  $databaseId: string;
  $permissions: string[];
}

// Appwrite user document stored in the users collection
export interface AppwriteUser extends AppwriteDocument {
  email: string;
  phoneNumber: string;
  userType: 'doctor' | 'patient' | 'lab_technician' | 'admin';
  firstName: string;
  lastName: string;
  languagePreference: string;
  timezone: string;
  isVerified: boolean;
  isActive: boolean;
  // Doctor-specific
  pmdcLicense?: string;
  specialization?: string;
  clinicName?: string;
  clinicAddress?: string;
  clinicCity?: string;
  clinicPhone?: string;
  // Patient-specific
  dateOfBirth?: string;
  bloodGroup?: string;
  height?: number;
  weight?: number;
  emergencyContactName?: string;
  emergencyContactPhone?: string;
  emergencyContactRelationship?: string;
  // Security
  mfaEnabled: boolean;
  mfaMethod?: string;
  passwordHash?: string;
}
