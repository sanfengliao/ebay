import Web3 from "web3"

let _web3 = null
if (typeof web3 !== "undefined") {
    _web3 = new Web3(web3.currentProvider)
} else {
    _web3 =  new Web3(new Web3.providers.HttpProvider("http://localhost:8080/web3"))
}
window.web3 = _web3
export default _web3