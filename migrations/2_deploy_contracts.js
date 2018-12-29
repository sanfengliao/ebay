/*var ConvertLib = artifacts.require('./ConvertLib.sol')
var MetaCoin = artifacts.require('./MetaCoin.sol')*/

/*module.exports = function (deployer) {
  deployer.deploy(ConvertLib)
  deployer.link(ConvertLib, MetaCoin)
  deployer.deploy(MetaCoin)
}*/

var BlindAuction = artifacts.require('./BlindAuction.sol')
var Escrow = artifacts.require('./Escrow.sol')

module.exports = function (deployer) {
  //deployer.deploy(Escrow)
  //deployer.link(Escrow, BlindAuction)
  deployer.deploy(BlindAuction)
}