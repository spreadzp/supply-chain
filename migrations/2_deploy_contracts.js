const SupplyCore = artifacts.require("./SupplyCore.sol");

module.exports = function (deployer, network, accounts) {
  return deployer.deploy(SupplyCore,
    { gasLimit: 6721970, from: accounts[0] })
};
