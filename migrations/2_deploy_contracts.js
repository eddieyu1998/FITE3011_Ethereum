var Borrowing = artifacts.require("Borrowing");

module.exports = function(deployer)
{
    deployer.deploy(Borrowing);
}