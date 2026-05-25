import bcrypt from 'bcrypt';
import { ID, Query } from 'node-appwrite';
import { databases, users as appwriteUsers, DATABASE_ID, COLLECTIONS } from '../config/appwrite';
import { createError } from '../middleware/errorHandler';
import type { RegisterDoctorDto, RegisterPatientDto } from '../models/user.model';
import type { AppwriteUser } from '../types/appwrite.types';

const SALT_ROUNDS = 12;

// ─── Register Doctor ──────────────────────────────────────────────────────────

export async function registerDoctor(data: RegisterDoctorDto): Promise<AppwriteUser> {
  // Check if email already exists
  const existing = await findUserByEmail(data.email);
  if (existing) {
    throw createError('Email is already registered', 409, 'EMAIL_EXISTS');
  }

  // Create Appwrite auth account
  const authUser = await appwriteUsers.create(
    ID.unique(),
    data.email,
    data.phone,
    data.password,
    `${data.firstName} ${data.lastName}`,
  );

  // Hash password for our own record (Appwrite also stores it)
  const passwordHash = await bcrypt.hash(data.password, SALT_ROUNDS);

  // Store doctor profile in database
  const doc = await databases.createDocument<AppwriteUser>(
    DATABASE_ID,
    COLLECTIONS.USERS,
    authUser.$id,
    {
      email: data.email,
      phoneNumber: data.phone,
      userType: 'doctor',
      firstName: data.firstName,
      lastName: data.lastName,
      languagePreference: 'english',
      timezone: 'Asia/Karachi',
      isVerified: false,
      isActive: true,
      pmdcLicense: data.pmdcLicense,
      specialization: data.specialization,
      clinicName: data.clinicName ?? undefined,
      clinicAddress: data.clinicAddress ?? undefined,
      mfaEnabled: false,
      passwordHash, // stored for our JWT auth flow
    },
  );

  return doc;
}

// ─── Register Patient ─────────────────────────────────────────────────────────

export async function registerPatient(data: RegisterPatientDto): Promise<AppwriteUser> {
  const existing = await findUserByEmail(data.email);
  if (existing) {
    throw createError('Email is already registered', 409, 'EMAIL_EXISTS');
  }

  const authUser = await appwriteUsers.create(
    ID.unique(),
    data.email,
    data.phone,
    data.password,
    `${data.firstName} ${data.lastName}`,
  );

  const passwordHash = await bcrypt.hash(data.password, SALT_ROUNDS);

  const doc = await databases.createDocument<AppwriteUser>(
    DATABASE_ID,
    COLLECTIONS.USERS,
    authUser.$id,
    {
      email: data.email,
      phoneNumber: data.phone,
      userType: 'patient',
      firstName: data.firstName,
      lastName: data.lastName,
      languagePreference: 'english',
      timezone: 'Asia/Karachi',
      isVerified: false,
      isActive: true,
      dateOfBirth: data.dateOfBirth ?? null,
      bloodGroup: data.bloodGroup ?? undefined,
      emergencyContactName: data.emergencyContactName ?? undefined,
      emergencyContactPhone: data.emergencyContactPhone ?? undefined,
      mfaEnabled: false,
      passwordHash,
    },
  );

  return doc;
}

// ─── Find User ────────────────────────────────────────────────────────────────

export async function findUserByEmail(email: string): Promise<AppwriteUser | null> {
  try {
    const result = await databases.listDocuments<AppwriteUser>(
      DATABASE_ID,
      COLLECTIONS.USERS,
      [Query.equal('email', email), Query.limit(1)],
    );
    return result.documents[0] ?? null;
  } catch {
    return null;
  }
}

export async function findUserById(id: string): Promise<AppwriteUser | null> {
  try {
    const doc = await databases.getDocument<AppwriteUser>(
      DATABASE_ID,
      COLLECTIONS.USERS,
      id,
    );
    return doc;
  } catch {
    return null;
  }
}

// ─── Verify Password ──────────────────────────────────────────────────────────

export async function verifyPassword(plain: string, hash: string): Promise<boolean> {
  return bcrypt.compare(plain, hash);
}
