import Vue from 'vue'
import Router from 'vue-router'
import Login from "../components/Login.vue"
import DashBoard from "../components/DashBoard.vue"
import ProductList from "../components/ProductList.vue"
import AddProduct from "../components/AddProduct.vue"
import MyProducts from "../components/MyProducts.vue"
import MyBids from "../components/MyBids.vue"
Vue.use(Router)


let router = new Router({
  routes: [
    {
      path: '/',
      name: 'HelloWorld',
      redirect: "/login"
    },
    {
      path: '/login',
      component: Login
    },
    {
      path: '/dashboard',
      component: DashBoard,
      children: [
        {
          path: '',
          component: ProductList
        },
        {
          path: "/add-product",
          component: AddProduct
        },
        {
          path: "/product-list",
          component: ProductList
        },
        {
          path: "/my-products",
          component: MyProducts
        },
        {
          path: "/my-bids",
          component: MyBids
        }
      ]
    }
  ]
})

router.beforeEach((to, from, next) => {
  if (to.path !== '/login' && sessionStorage.getItem("address") == null) {
    next({
      path: '/login',
      query: {redirect: to.fullPath}
    })
  } else {
    next()
  }
})
export default router
