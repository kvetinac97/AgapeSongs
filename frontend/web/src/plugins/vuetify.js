// Styles
import '@mdi/font/css/materialdesignicons.css'
import 'vuetify/styles'

// Vuetify
import { createVuetify } from 'vuetify'

export default createVuetify({
    components: [],
    theme: {
        defaultTheme: 'customLight',
        themes: {
            customLight: {
                dark: false,
                colors: {
                    anchor: '#0000ff',
                    progress: '#b388ff',
                    mermaidBg: '#ffffff',
                }
            },
            customDark: {
                dark: true,
                colors: {
                    anchor: '#a9edfe',
                    progress: '#6200ea',
                    mermaidBg: '#202020',
                }
            },
        }
    }
})
