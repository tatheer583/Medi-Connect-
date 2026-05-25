import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';

import en from './en.json';
import ur from './ur.json';

export const resources = {
  en: { translation: en },
  ur: { translation: ur },
} as const;

export type SupportedLanguage = keyof typeof resources;

i18n
  .use(initReactI18next)
  .init({
    resources,
    lng: 'en', // default language
    fallbackLng: 'en',
    interpolation: {
      escapeValue: false, // React already escapes values
    },
    compatibilityJSON: 'v3',
  });

export default i18n;
