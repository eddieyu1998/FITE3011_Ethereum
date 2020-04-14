pragma solidity ^0.5.16;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Crowdfunding_127.sol";

contract TestCrowdfunding {
    Crowdfunding crowdfunding = Crowdfunding(DeployedAddresses.Crowdfunding());

    uint campaignId;
    uint endTime = block.timestamp + 180;
    uint goal = 10000;

    uint public initialBalance = 101 wei;

    //testing the createCampaign() function
    function testCreateCampaign() public
    {
        campaignId = crowdfunding.createCampaign(endTime, goal);
        Assert.equal(campaignId, 0, "Expected campaignId not equal");
    }

    // testing the getGoal() function
    function testGetGoal() public
    {
        uint r = crowdfunding.getGoal(campaignId);
        Assert.equal(r, goal, "Expected goal not equal");
    }

    // testing the getEndTime() function
    function testGetEndTime() public
    {
        uint r = crowdfunding.getEndTime(campaignId);
        Assert.equal(r, endTime, "Expected endTime not equal");
    }

    // testing the getDeposit() function
    function testGetDeposit() public
    {
        uint r = crowdfunding.getDeposit(campaignId);
        Assert.equal(r, 0, "Expected deposit not equal");
    }

    // test donate and withdraw with js
}