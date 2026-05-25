import { createSlice, PayloadAction } from '@reduxjs/toolkit';
import { Appointment } from '../../types';

interface AppointmentState {
  appointments: Appointment[];
  selectedAppointment: Appointment | null;
  isLoading: boolean;
  error: string | null;
}

const initialState: AppointmentState = {
  appointments: [],
  selectedAppointment: null,
  isLoading: false,
  error: null,
};

const appointmentSlice = createSlice({
  name: 'appointments',
  initialState,
  reducers: {
    fetchAppointmentsStart(state) {
      state.isLoading = true;
      state.error = null;
    },
    fetchAppointmentsSuccess(state, action: PayloadAction<Appointment[]>) {
      state.isLoading = false;
      state.appointments = action.payload;
    },
    fetchAppointmentsFailure(state, action: PayloadAction<string>) {
      state.isLoading = false;
      state.error = action.payload;
    },
    selectAppointment(state, action: PayloadAction<Appointment | null>) {
      state.selectedAppointment = action.payload;
    },
    addAppointment(state, action: PayloadAction<Appointment>) {
      state.appointments.unshift(action.payload);
    },
    updateAppointment(state, action: PayloadAction<Appointment>) {
      const index = state.appointments.findIndex(
        (a) => a.id === action.payload.id,
      );
      if (index !== -1) {
        state.appointments[index] = action.payload;
      }
    },
    removeAppointment(state, action: PayloadAction<string>) {
      state.appointments = state.appointments.filter(
        (a) => a.id !== action.payload,
      );
    },
  },
});

export const {
  fetchAppointmentsStart,
  fetchAppointmentsSuccess,
  fetchAppointmentsFailure,
  selectAppointment,
  addAppointment,
  updateAppointment,
  removeAppointment,
} = appointmentSlice.actions;

export default appointmentSlice.reducer;
