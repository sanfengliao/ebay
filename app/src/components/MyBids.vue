<template>
  <div>
    <div class="open-products" style="overflow:hidden">
      <h2>待确认</h2>
      <el-card v-for="(product, index) in myBidProducts" :key="index">
        <div class="name">名字: {{product.name}}</div>
        <div class="desc">描述: {{product.desc}}</div>
        <div class="pric">价格: {{product.highestPrice}}</div>
        <el-button type="primary" @click="payCheckedToSeller(index)">同意付款</el-button>
        <el-button type="primary" @click="refundCheckedToBuyer(index)">我要退款</el-button>
      </el-card>
    </div>
    <div class="open-products" style="overflow:hidden">
      <h2>已成交</h2>
      <el-card v-for="(product, index) in myPurchases" :key="index">
        <div class="name">名字: {{product.name}}</div>
        <div class="desc">描述: {{product.desc}}</div>
        <div class="pric">成交金额: {{product.highestPrice}}</div>
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
        myBidProducts: [],
        myPurchases: []
      }
    },
    created() {
      this.getAllProduct()
    },
    methods: {
       getAllProduct() {
        let instance
        this.myBidProducts = []
        BlindAution.deployed().then(i => {
          instance = i
          return instance.getProductCount()
        }).then(result => {
          // 获取商品的数量
          let productCount = result.c[0];
          for (let i = 1; i <= productCount; ++i) {
            // 获取所有商品的信息
            instance.getProductInfo(i).then(info => {
              console.log(info)
              if (info[8] === sessionStorage.getItem("address")) {
                if (info[6].c[0] == 1) {
                   let p = new Product(info[0].c[0], info[1], info[2], new Date(info[3].c[0] * 1000).toLocaleString(), new Date(info[4].c[0] * 1000).toLocaleString(), info[5].c[0], info[6].c[0])
                  this.myBidProducts.push(p)
                } else if(info[6].c[0] == 2) {
                   let p = new Product(info[0].c[0], info[1], info[2], new Date(info[3].c[0] * 1000).toLocaleString(), new Date(info[4].c[0] * 1000).toLocaleString(), info[5].c[0], info[6].c[0])
                   this.myPurchases.push(p)
                }
               
              }
            })    
          }
        })
      },
       payCheckedToSeller(index) {
        let instance
        BlindAution.deployed().then(i => {
          instance = i
          return instance.payCheckedToSeller(this.myBidProducts[index].id, {from: sessionStorage.getItem("address")})
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
          return instance.refundCheckedToBuyer(this.myBidProducts[index].id, {from: sessionStorage.getItem("address")})
        }).then(result => {
          console.log("result", result)
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
</style>