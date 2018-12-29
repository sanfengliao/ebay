<template>
  <el-container class="main-container">
    <el-aside class="menu-container" width="200px">
      <el-menu>
        <el-menu-item index="1" @click="goto('/product-list')">所有商品</el-menu-item>
        <el-menu-item index="2" @click="goto('/add-product')">上传商品</el-menu-item>
        <el-menu-item index="3" @click="goto('/my-products')">我的商品</el-menu-item>
        <el-menu-item index="4" @click="goto('/my-bids')">我的竞拍</el-menu-item>
      </el-menu>
    </el-aside>
    <el-container>
      <el-main>
        <router-view></router-view>
      </el-main>
    </el-container>
  </el-container>
</template>

<script>
export default {

  methods: {
    goto(path) {
      this.$router.push(path)
    }
  }
};
</script>

<style scoped>
  .main-container {
    height: 100%;
  }
  .menu-container {
    height: 100%;
    background-color: rgb(238, 241, 246);
  }
</style>