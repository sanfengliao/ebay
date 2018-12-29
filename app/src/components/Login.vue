<template>
    <el-form label-position="left" label-width="0px"  class="demo-ruleForm login-container">
        <h3 class="title">用户登录</h3>
        <el-form-item prop="username">
            <el-input type="text" auto-complete="off" v-model="username" placeholder="账号"></el-input>
        </el-form-item>
        <!--<el-checkbox v-model="checked" checked class="remember">记住密码</el-checkbox>-->
        <el-form-item style="width:100%;">
            <el-button type="primary" style="width:100%;" @click.prevent="login">登录</el-button>
        </el-form-item>
    </el-form>
</template>

<script>
    import web3 from "../util"
    export default {
        data() {
            return {
                username: "",
                rules: {
                    username: [
                        {required: true, message:"请输入账号", trigger: 'blur'}
                    ]
                }
            }
        },
        methods: {
            login() {
                if (web3.eth.accounts.indexOf(this.username) !== -1) {
                    sessionStorage.setItem("address", this.username)
                    let path = this.$route.query.redirect ? this.$route.query.redirect : "/dashboard"
                    this.$router.replace(path)
                } else {
                    this.$message.error("没有该账号")
                }
            }
        }
    }
</script>

<style scoped>
   .login-container {
        width: 400px;
        margin: 160px auto;
        padding: 15px 35px 15px 35px;
        border-radius: 5px;
        background: #fff;
        border: 1px solid #eaeaea;
        box-shadow: 0 0 25px #cac6c6;
   }

</style>