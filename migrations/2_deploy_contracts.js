const Holy = artifacts.require("./Holy.sol");

module.exports = function (deployer, network, accounts) {
  return deployer.deploy(Holy,
    accounts[1], // player1
    accounts[2], // player2 ,
    { gasLimit: 6721970, from: accounts[0] })
};
