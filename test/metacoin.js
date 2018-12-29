var MetaCoin = artifacts.require('./MetaCoin.sol')
var BlindAuction = artifacts.require("./BlindAuction.sol")
var ethUtil = require("ethereumjs-util")
contract("BlindAuction", (accounts) => {
  let contract;
  it("addProductTest", () => {
    return BlindAuction.deployed().then((instance) => {
      contract = instance;
      return instance.addProduct("iphone", "iphone好用啊", Date.now()/1000, Date.now()/1000 + 1000, 100);
    }).then((result) => {
      //console.log(result)
    })
  })
  it("getProductInfoTest", () => {
    return BlindAuction.deployed().then(instance => {
      return instance.getProductInfo(1)
    }).then(obj => {
      console.log(obj)
    })
  })

  it("bidTestAndreadBidTest", () => {
    let account1 = accounts[1]
    let account2 = accounts[2]
    let account3 = accounts[3]
    let contract

    return BlindAuction.deployed().then(instance => {
        contract = instance;
        return instance.getcheck(101)
    }).then(result => {
      return contract.bid(1, result, {from: account1, value: 110});
    }).then((obj) => {
      return contract.getcheck(150)
    }).then((result) => {
      return contract.bid(1, result, {from: account2, value: 160})
    }).then((obj) => {
      return contract.getcheck(200)
    }).then((result) => {
      return contract.bid(1, result, {from: account3, value: 210}) // 最高出价为accounts[3]
    })
  })

  it("revealBidTest", () => {
    let account1 = accounts[1]
    let account2 = accounts[2]
    let account3 = accounts[3]
    let contract
    return BlindAuction.deployed().then(instance => {
      contract = instance;
      // console.log(contract)
      return instance.revealBid(1, 101, "abc", {from: account1})
    }).then(obj => {
      return contract.revealBid(1, 150, "abc", {from: account2})
    }).then(obj =>{   
      return contract.revealBid(1, 200, "abc", {from: account3})
    }).then(obj => {
      return contract.getProductAuctionInfo(1)
    }).then(result => {
      console.log("seller: ", accounts[0])
      console.log("highestBidder: ", account3)
      console.log(result)
    })
  })

  it("checkAuctionTest, payCheckedToBuyer", () => {
    let buyer = accounts[3];
    let seller = accounts[0];
    let arbiter = accounts[4];
    let contract
    return BlindAuction.deployed().then((instance) => {
      contract = instance;
      return contract.checkAuction(1, {from: arbiter})
    }).then(() => {
      return contract.payCheckedToSeller(1, {from: arbiter})
    }).then(() => {
      return contract.payCheckedToSeller(1, {from: buyer})
    }).then(() => {
      return contract.getProductAuctionInfo(1)
    }).then((result) => {
      console.log(result)
    })
  })

})

// contract('MetaCoin', function (accounts) {
//   it('should put 10000 MetaCoin in the first account', function () {
//     return MetaCoin.deployed().then(function (instance) {
//       return instance.getBalance.call(accounts[0])
//     }).then(function (balance) {
//       assert.equal(balance.valueOf(), 10000, "10000 wasn't in the first account")
//     })
//   })
//   it('should call a function that depends on a linked library', function () {
//     var meta
//     var metaCoinBalance
//     var metaCoinEthBalance

//     return MetaCoin.deployed().then(function (instance) {
//       meta = instance
//       return meta.getBalance.call(accounts[0])
//     }).then(function (outCoinBalance) {
//       metaCoinBalance = outCoinBalance.toNumber()
//       return meta.getBalanceInEth.call(accounts[0])
//     }).then(function (outCoinBalanceEth) {
//       metaCoinEthBalance = outCoinBalanceEth.toNumber()
//     }).then(function () {
//       assert.equal(
//         metaCoinEthBalance,
//         2 * metaCoinBalance,
//         'Library function returned unexpeced function, linkage may be broken'
//       )
//     })
//   })

//   it('should send coin correctly', function () {
//     var meta

//     //    Get initial balances of first and second account.
//     var accountOne = accounts[0]
//     var accountTwo = accounts[1]

//     var accountOneStartingBalance
//     var accountTwoStartingBalance
//     var accountOneEndingBalance
//     var accountTwoEndingBalance

//     var amount = 10

//     return MetaCoin.deployed().then(function (instance) {
//       meta = instance
//       return meta.getBalance.call(accountOne)
//     }).then(function (balance) {
//       accountOneStartingBalance = balance.toNumber()
//       return meta.getBalance.call(accountTwo)
//     }).then(function (balance) {
//       accountTwoStartingBalance = balance.toNumber()
//       return meta.sendCoin(accountTwo, amount, { from: accountOne })
//     }).then(function () {
//       return meta.getBalance.call(accountOne)
//     }).then(function (balance) {
//       accountOneEndingBalance = balance.toNumber()
//       return meta.getBalance.call(accountTwo)
//     }).then(function (balance) {
//       accountTwoEndingBalance = balance.toNumber()

//       assert.equal(
//         accountOneEndingBalance,
//         accountOneStartingBalance - amount,
//         "Amount wasn't correctly taken from the sender"
//       )
//       assert.equal(
//         accountTwoEndingBalance,
//         accountTwoStartingBalance + amount,
//         "Amount wasn't correctly sent to the receiver"
//       )
//     })
//   })
// })
