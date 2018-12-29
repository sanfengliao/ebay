<template>
  <div class="add-product-container">
    <el-row>
      <el-col :span="9">
        商品名称:<el-input v-model='name' placeholder="请输入商品名称"></el-input>
        商品描述:<el-input v-model='desc' type="textarea" :rows="4" placeholder="请输入内容"></el-input>
        起价:<el-input v-model='startPrice' :rows="4" placeholder="请输入内容"></el-input>
        <div>拍卖时间:</div>
        <div><el-date-picker v-model="date" type="datetimerange" range-separator="至" start-placeholder="开始日期" end-placeholder="结束日期"></el-date-picker></div>
        <el-button type="primary" @click="submit">提交</el-button>
      </el-col>
    </el-row>
  </div>
</template>

<script>
  import web3 from "../util"
  import BlindAution from "../util/blindAution.js"
  export default {
    data() {
      return {
        date: null,
        name: '',
        desc: '',
        startPrice: ''
      }
    },
    methods: {
      submit() {
        console.log(typeof this.date[0])
        let auctionStartTime = parseInt(this.date[0].getTime()/1000)
        let auctionEndTime = parseInt(this.date[1].getTime() / 1000)
        BlindAution.deployed().then(i => {
          return i.addProduct(this.name, this.desc, auctionStartTime, auctionEndTime, parseFloat(this.startPrice), {from: sessionStorage.getItem("address"), gas: 99999999999})
        }).then(info => {
          this.$message({
            message: "添加成功",
            type: "success"
          })
        }).catch((err) => {
          console.log(err)
          this.$message.error("添加失败")
        })
      }
    }
  };
</script>

<style scoped>
  .el-col {
    margin: 50px 100px;
  }
  .el-input, .el-textarea{
    margin-bottom: 20px;
  }
  .el-button {
    margin-top: 20px;
  }
</style>