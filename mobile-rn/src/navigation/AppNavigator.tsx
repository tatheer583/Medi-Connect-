import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { useSelector } from 'react-redux';

import { RootState } from '../store';

// ─── Stack Param Lists ───────────────────────────────────────

export type AuthStackParamList = {
  Login: undefined;
  Register: undefined;
  ForgotPassword: undefined;
  VerifyMFA: { userId: string };
};

export type PatientTabParamList = {
  Home: undefined;
  Appointments: undefined;
  HealthCard: undefined;
  Chat: undefined;
  Profile: undefined;
};

export type DoctorTabParamList = {
  Dashboard: undefined;
  Appointments: undefined;
  Patients: undefined;
  Chat: undefined;
  Profile: undefined;
};

export type RootStackParamList = {
  Auth: undefined;
  PatientMain: undefined;
  DoctorMain: undefined;
};

// ─── Navigators ──────────────────────────────────────────────

const RootStack = createStackNavigator<RootStackParamList>();
const AuthStack = createStackNavigator<AuthStackParamList>();
const PatientTab = createBottomTabNavigator<PatientTabParamList>();
const DoctorTab = createBottomTabNavigator<DoctorTabParamList>();

// ─── Placeholder Screens ─────────────────────────────────────
// These will be replaced with real screen components in later tasks.

import { View, Text, StyleSheet } from 'react-native';

function PlaceholderScreen({ name }: { name: string }): React.JSX.Element {
  return (
    <View style={styles.placeholder}>
      <Text style={styles.placeholderText}>{name}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  placeholder: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#f5f5f5',
  },
  placeholderText: {
    fontSize: 18,
    color: '#666',
  },
});

// ─── Auth Navigator ──────────────────────────────────────────

function AuthNavigator(): React.JSX.Element {
  return (
    <AuthStack.Navigator
      screenOptions={{
        headerShown: false,
      }}
    >
      <AuthStack.Screen
        name="Login"
        component={() => <PlaceholderScreen name="Login" />}
      />
      <AuthStack.Screen
        name="Register"
        component={() => <PlaceholderScreen name="Register" />}
      />
      <AuthStack.Screen
        name="ForgotPassword"
        component={() => <PlaceholderScreen name="Forgot Password" />}
      />
      <AuthStack.Screen
        name="VerifyMFA"
        component={() => <PlaceholderScreen name="Verify MFA" />}
      />
    </AuthStack.Navigator>
  );
}

// ─── Patient Tab Navigator ───────────────────────────────────

function PatientNavigator(): React.JSX.Element {
  return (
    <PatientTab.Navigator
      screenOptions={{
        headerShown: false,
        tabBarActiveTintColor: '#2196F3',
        tabBarInactiveTintColor: '#9E9E9E',
      }}
    >
      <PatientTab.Screen
        name="Home"
        component={() => <PlaceholderScreen name="Patient Home" />}
      />
      <PatientTab.Screen
        name="Appointments"
        component={() => <PlaceholderScreen name="Appointments" />}
      />
      <PatientTab.Screen
        name="HealthCard"
        component={() => <PlaceholderScreen name="Health Card" />}
      />
      <PatientTab.Screen
        name="Chat"
        component={() => <PlaceholderScreen name="Chat" />}
      />
      <PatientTab.Screen
        name="Profile"
        component={() => <PlaceholderScreen name="Profile" />}
      />
    </PatientTab.Navigator>
  );
}

// ─── Doctor Tab Navigator ────────────────────────────────────

function DoctorNavigator(): React.JSX.Element {
  return (
    <DoctorTab.Navigator
      screenOptions={{
        headerShown: false,
        tabBarActiveTintColor: '#2196F3',
        tabBarInactiveTintColor: '#9E9E9E',
      }}
    >
      <DoctorTab.Screen
        name="Dashboard"
        component={() => <PlaceholderScreen name="Doctor Dashboard" />}
      />
      <DoctorTab.Screen
        name="Appointments"
        component={() => <PlaceholderScreen name="Appointments" />}
      />
      <DoctorTab.Screen
        name="Patients"
        component={() => <PlaceholderScreen name="Patients" />}
      />
      <DoctorTab.Screen
        name="Chat"
        component={() => <PlaceholderScreen name="Chat" />}
      />
      <DoctorTab.Screen
        name="Profile"
        component={() => <PlaceholderScreen name="Profile" />}
      />
    </DoctorTab.Navigator>
  );
}

// ─── Root Navigator ──────────────────────────────────────────

export default function AppNavigator(): React.JSX.Element {
  const { isAuthenticated, userType } = useSelector(
    (state: RootState) => state.auth,
  );

  return (
    <NavigationContainer>
      <RootStack.Navigator screenOptions={{ headerShown: false }}>
        {!isAuthenticated ? (
          <RootStack.Screen name="Auth" component={AuthNavigator} />
        ) : userType === 'doctor' ? (
          <RootStack.Screen name="DoctorMain" component={DoctorNavigator} />
        ) : (
          <RootStack.Screen name="PatientMain" component={PatientNavigator} />
        )}
      </RootStack.Navigator>
    </NavigationContainer>
  );
}
