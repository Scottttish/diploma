import { createI18n } from 'vue-i18n'
import ru from './ru'
import en from './en'
import kk from './kk'

export default createI18n({
  legacy: false,
  locale: localStorage.getItem('locale') || 'ru',
  fallbackLocale: 'ru',
  messages: { ru, en, kk },
})
