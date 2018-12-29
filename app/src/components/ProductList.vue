<template>
  <div>
    <div class="open-products" style="overflow:hidden">
        <h2>正在拍卖</h2>
        <el-card v-for="(product, index) in openProducts" :key="index">
          <div class="name">名字: {{product.name}}</div>
          <div class="desc">描述: {{product.desc}}</div>
          <div class="start-time">起始时间: {{product.startTime}}</div>
          <div class="end-time">结束时间: {{product.endTime}}</div>
          <div class="start-price">最高出价: {{product.highestPrice}}</div>
          <el-input v-model="bidPrices[index]" placeholder="请输入你的出价" style="margin-top: 20px"></el-input>
          <el-button type="primary" @click="bid(index)">提交</el-button>
        </el-card>
    </div>
    <div class="open-products" style="overflow:hidden">
      <h2>准备拍卖</h2>
      <el-card v-for="(product, index) in prepareProducts" :key="index">
        <div class="name">名字: {{product.name}}</div>
        <div class="desc">描述: {{product.desc}}</div>
        <div class="start-time">起始时间: {{product.startTime}}</div>
        <div class="end-time">结束时间: {{product.endTime}}</div>
        <div class="start-price">起拍价: {{product.startPrice}}</div>
      </el-card>
    </div>
  </div>
</template>

<script>
import BlindAution from "../util/blindAution.js"
import Product from "../base/Product.js"
import web3 from "../util"
export default {
  data() {
    return {
      openProducts: [],
      prepareProducts: [],
      revealProducts: [],
      bidPrices: []
    }
  },
  created() {
    let instance;
    BlindAution.deployed().then(i => {
        instance = i;
        return instance.getProductCount()
    }).then(result => {
      // 获取商品的数量
      let productCount = result.c[0];
      for (let i = 1; i <= productCount; ++i) {
        // 获取所有商品的信息
        instance.getProductInfo(i).then(info => {
          console.log(info)
          if (info[6].c[0] == 0 && info[3].c[0] * 1000 < Date.now() && info[4].c[0] * 1000 > Date.now()){
            // 正在进行的拍卖
            let p = new Product(info[0].c[0], info[1], info[2], new Date(info[3].c[0] * 1000).toLocaleString(), new Date(info[4].c[0] * 1000).toLocaleString(), info[5].c[0], info[6].c[0])
            this.openProducts.push(p)
          } else if (info[6].c[0] == 0 && info[3].c[0] * 1000 > Date.now() ) {
            // 准备进行的拍卖
            let p = new Product(info[0].c[0], info[1], info[2], new Date(info[3].c[0] * 1000).toLocaleString(), new Date(info[4].c[0] * 1000).toLocaleString(), info[5].c[0], info[6].c[0])
            this.prepareProducts.push(p)
          }
        })
      }
    })
  },
  methods: {
    bid(index) {
      console.log(this.bidPrices[index])
      let instance = null
      BlindAution.deployed().then(i => {
        instance = i
        return instance.bid(this.openProducts[index].id, {from: sessionStorage.getItem("address"), value: parseInt(this.bidPrices[index]), gas: 99999999999})
      }).then((info) => {
        return instance.getProductInfo(this.openProducts[index].id)
      }).then(result => {
        this.openProducts[index].highestPrice = result[5].c[0]
        this.$message({
          message: "出价成功",
          type: "success"
        })
        
      }).catch((err) => {
        console.log(err)
       this.$message.error("出价失败")
      })
    }
  }
};
</script>

<style scoped>
  .el-card {
    margin: 10px;
    float: left;
    width: 30%;
  }
  .el-card > .el-card__body > div {
    margin-top: 5px;
  }
  .el-input {
    margin: 40px 0 20px 0;
  }
</style>