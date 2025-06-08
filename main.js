import { createApp } from 'vue'
import App from './App.vue'
import router from './router'
import { ethers } from 'ethers'

const app = createApp(App)
app.config.globalProperties.$ethers = ethers
app.use(router)
app.mount('#app')
