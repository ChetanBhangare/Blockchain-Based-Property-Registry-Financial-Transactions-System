import { createRouter, createWebHistory } from 'vue-router'
import PropertyListing from '../views/PropertyListing.vue'
import RegisterProperty from '../views/RegisterProperty.vue'
import ListProperty from '../views/ListProperty.vue'
import BuyProperty from '../views/BuyProperty.vue'
import ApproveTransfer from '../views/ApproveTransfer.vue'
import CreateTransferRequest from '../views/CreateTransferRequest.vue'

const routes = [
  { path: '/', component: PropertyListing },
  { path: '/register', component: RegisterProperty },
  { path: '/list', component: ListProperty },
  { path: '/buy', component: BuyProperty },
  { path: '/approve', component: ApproveTransfer },
  { path: '/transfer', component: CreateTransferRequest }
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

export default router;
