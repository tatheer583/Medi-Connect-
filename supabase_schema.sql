-- Profiles table (extends Supabase Auth users)
create table profiles (
  id uuid references auth.users on delete cascade primary key,
  email text unique not null,
  full_name text not null,
  role text check (role in ('doctor', 'patient')) not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Doctors table
create table doctors (
  id uuid references profiles(id) on delete cascade primary key,
  pmdc_license text unique not null,
  specialty text not null,
  experience_years int,
  bio text,
  photo_url text,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Clinics table
create table clinics (
  id uuid primary key default gen_random_uuid(),
  doctor_id uuid references doctors(id) on delete cascade not null,
  name text not null,
  address text not null,
  working_hours jsonb, -- e.g. {"mon": ["09:00", "17:00"], ...}
  fee decimal(10, 2),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Patients table
create table patients (
  id uuid references profiles(id) on delete cascade primary key,
  cnic text unique,
  blood_group text,
  weight decimal(5, 2),
  height decimal(5, 2),
  allergies text[],
  chronic_conditions text[],
  emergency_contact jsonb, -- {"name": "...", "phone": "..."}
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Appointments table
create table appointments (
  id uuid primary key default gen_random_uuid(),
  doctor_id uuid references doctors(id) on delete cascade not null,
  patient_id uuid references patients(id) on delete cascade not null,
  clinic_id uuid references clinics(id) on delete cascade not null,
  scheduled_at timestamp with time zone not null,
  status text check (status in ('pending', 'confirmed', 'cancelled', 'completed')) default 'pending' not null,
  type text check (type in ('first_visit', 'follow_up', 'teleconsultation')) not null,
  notes text,
  ai_summary text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Prescriptions table
create table prescriptions (
  id uuid primary key default gen_random_uuid(),
  appointment_id uuid references appointments(id) on delete cascade not null,
  doctor_id uuid references doctors(id) not null,
  patient_id uuid references patients(id) not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Medicines table
create table medicines (
  id uuid primary key default gen_random_uuid(),
  prescription_id uuid references prescriptions(id) on delete cascade not null,
  name text not null,
  dosage text not null,
  frequency text not null,
  duration text,
  start_date date default current_date not null,
  is_active boolean default true not null
);

-- Lab Results table
create table lab_results (
  id uuid primary key default gen_random_uuid(),
  patient_id uuid references patients(id) on delete cascade not null,
  appointment_id uuid references appointments(id) on delete set null,
  name text not null,
  file_url text not null,
  uploaded_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- RLS (Row Level Security) Policies (Basic Setup)
alter table profiles enable row level security;
alter table doctors enable row level security;
alter table clinics enable row level security;
alter table patients enable row level security;
alter table appointments enable row level security;
alter table prescriptions enable row level security;
alter table medicines enable row level security;
alter table lab_results enable row level security;

-- Example policy: Everyone can read profiles
create policy "Public profiles are viewable by everyone." on profiles for select using (true);

-- Users can only update their own profile
create policy "Users can update own profile." on profiles for update using (auth.uid() = id);
