import { Router } from 'express';
import { registerDoctorHandler, registerPatientHandler } from '../controllers/auth.controller';

const router = Router();

/**
 * POST /api/v1/auth/register/doctor
 * Register a new doctor account
 */
router.post('/register/doctor', registerDoctorHandler);

/**
 * POST /api/v1/auth/register/patient
 * Register a new patient account
 */
router.post('/register/patient', registerPatientHandler);

export default router;
