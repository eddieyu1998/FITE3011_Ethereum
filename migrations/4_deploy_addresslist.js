var AddressList = artifacts.require("Addresslist");

module.exports = function(deployer)
{
    deployer.deploy(AddressList);
}