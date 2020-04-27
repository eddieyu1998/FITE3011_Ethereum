var AddressList = artifacts.require("AddressList");

module.exports = function(deployer)
{
    deployer.deploy(AddressList);
}