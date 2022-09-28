const Bankloan = artifacts.require("Bankloan");

module.exports = function (deployer) {
  deployer.deploy(Bankloan);
};
