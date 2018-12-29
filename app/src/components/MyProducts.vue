<template>
  <div>
    <div class="open-products" style="overflow:hidden">
      <h2>正在拍卖</h2>
        <el-card v-for="(product, index) in myOpenProducts" :key="index">
          <div class="name">名字: {{product.name}}</div>
          <div class="desc">描述: {{product.desc}}</div>
          <div class="start-time">起始时间: {{product.startTime}}</div>
          <div class="end-time">结束时间: {{product.endTime}}</div>
          <div class="start-price">最高出价: {{product.highestPrice}}</div>
          <el-button type="primary" @click="done(index)">成交</el-button>
        </el-card>
    </div>
    <div class="open-products" style="overflow:hidden">
      <h2>待确认</h2>
        <el-card v-for="(product, index) in myDoneProducts" :key="index">
          <div class="name">名字: {{product.name}}</div>
          <div class="desc">描述: {{product.desc}}</div>
          <div class="start-time">起始时间: {{product.startTime}}</div>
          <div class="end-time">结束时间: {{product.endTime}}</div>
          <div class="start-price">最高出价: {{product.highestPrice}}</div>
          <el-button type="primary" @click="payCheckedToSeller(index)">同意收款</el-button>
          <el-button type="primary" @click="refundCheckedToBuyer(index)">同意退款</el-button>
        </el-card>
    </div>
    <div class="open-products" style="overflow:hidden">
      <h2>已卖出</h2>
        <el-card v-for="(product, index) in mySoldedProducts" :key="index">
          <div class="name">名字: {{product.name}}</div>
          <div class="desc">描述: {{product.desc}}</div>
          <div class="start-price">最高出价: {{product.highestPrice}}</div>
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
        myOpenProducts: [], // 还未结束拍卖的商品
        myDoneProducts: [],  // 成交但还未付款的商品
        mySoldedProducts: [], // 拍卖完全结束付款的商品(包括退款或者未卖出的
      }
    },
    created() {
      this.getAllProduct()
    },
    methods: {
      getAllProduct() {
        let instance
        this.myOpenProducts = []
        this.myDoneProducts = []
        this.mySoldedProducts = []
        BlindAution.deployed().then(i => {
          instance = i
          return instance.getProductCount()
        }).then(result => {
          // 获取商品的数量
          let productCount = result.c[0];
          for (let i = 1; i <= productCount; ++i) {
            // 获取所有商品的信息
            instance.getProductInfo(i).then(info => {
              if (info[7] === sessionStorage.getItem("address")) {
                console.log(info)
                if (info[6].c[0] === 0) {
                  let p = new Product(info[0].c[0], info[1], info[2], new Date(info[3].c[0] * 1000).toLocaleString(), new Date(info[4].c[0] * 1000).toLocaleString(), info[5].c[0], info[6].c[0])
                  this.myOpenProducts.push(p)
                } else if(info[6].c[0] === 1) {
                  let p = new Product(info[0].c[0], info[1], info[2], new Date(info[3].c[0] * 1000).toLocaleString(), new Date(info[4].c[0] * 1000).toLocaleString(), info[5].c[0], info[6].c[0])
                  this.myDoneProducts.push(p)
                } else {
                  let p = new Product(info[0].c[0], info[1], info[2], new Date(info[3].c[0] * 1000).toLocaleString(), new Date(info[4].c[0] * 1000).toLocaleString(), info[5].c[0], info[6].c[0])
                  this.mySoldedProducts.push(p)
                }
              }
            })
          }
        })
      },
      done(index) {
        let instance;
        BlindAution.deployed().then(i => {
          instance = i
          return instance.done(this.myOpenProducts[index].id, {from: sessionStorage.getItem("address")})
        }).then(result => {
          // 生成仲裁，这里就没有去写选举功能了，默认一个账号吧
          return instance.checkAuction(this.myOpenProducts[index].id, {from: web3.eth.accounts[9]})
        }).then(result => {
          console.log(result)
          this.$message({
            message: "商品已成交, 待确认",
            type: "success"
          })
          this.getAllProduct()
        }).catch(err => {
          console.log(err)
          this.$message.error("商品成交确认失败")
        })
      },
      payCheckedToSeller(index) {
        let instance
        BlindAution.deployed().then(i => {
          instance = i
          return instance.payCheckedToSeller(this.myDoneProducts[index].id, {from: sessionStorage.getItem("address")})
        }).then(result => {
          console.log(result)
          this.$message({
            message: "确认成功",
            type: "success"
          })
          this.getAllProduct()
        }).catch(err => {
          console.log(err)
          this.$message.error("确认失败")
        })
      },
      refundCheckedToBuyer(index) {
        let instance
        BlindAution.deployed().then(i => {
          instance = i
          return instance.refundCheckedToBuyer(this.myDoneProducts[index].id, {from: sessionStorage.getItem("address")})
        }).then(result => {
          console.log("result: ",result)
          this.$message({
            message: "确认成功",
            type: "success"
          })
          this.getAllProduct()
        }).catch(err => {
          console.log(err)
          this.$message.error("确认失败")
        })
      }
    }
  }
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

  .el-button {
    margin: 20px 0 20px 0;
  }
</style>