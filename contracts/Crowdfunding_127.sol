pragma solidity ^0.5.16;

/** Design
*   1. need to store a list of crowdfunding campaign
*   2. Each contains a owner (address), endtime (uint), goal (uint), deposit (uint), number of donors (uint), each donor (address) and his amount (uint)
*   methods:
*   1. Get the current total deposit
*   2. Get the endtime
*   3. Get the goal
*   4. Create campaign
*   5. Allow donor to back (address, amount) -> check amount valid, goal haven't achieved, endtime not reached (allow re-donation??)
*   6. Allow owner withdraw if goal achieved -> transfer
*   7. Allow donor withdraw if goal not achieved, when endtime reached
* */

contract Crowdfunding
{
    // struct type representing a crowdfunding campaign
    struct Campaign
    {
        address owner;      // address of campaign owner
        uint endTime;    // endtime as seconds since unix epoch
        uint goal;       // amount of goal, in wei
        uint deposit;    // amount of current deposit, in wei
        uint numDonors;   // total number of donors
        mapping (uint => Donor) donors;    // list of donation storing each donor and his amount
    }

    // struct type representing a donor
    struct Donor
    {
        address donor;  // address of the donor
        uint amount; // amount of the donation
    }

    uint numCampaigns;  // total number of campaigns
    mapping (uint => Campaign) campaigns;

    // Getter for goal of a campaign
    function getGoal (uint campaignId) public view returns (uint)
    {
        require (campaignId < numCampaigns, "Invalid campaignId");
        return campaigns[campaignId].goal;
    }

    // Getter for endtime of a campaign
    function getEndTime (uint campaignId) public view returns (uint)
    {
        require (campaignId < numCampaigns, "Invalid campaignId");
        return campaigns[campaignId].endTime;
    }

    // Getter for current deposit of a campaign
    function getDeposit (uint campaignId) public view returns (uint)
    {
        require (campaignId < numCampaigns, "Invalid campaignId");
        return campaigns[campaignId].deposit;
    }

    // Function to create a campaign
    function createCampaign (uint endTime, uint goal) public returns (uint campaignId)
    {
        // validate endTime
        require (endTime > block.timestamp, "Invalid endTime");

        // validate goal
        require (goal > 0, "Invalid goal");

        campaignId = numCampaigns++;
        campaigns[campaignId] = Campaign(msg.sender, endTime, goal, 0, 0);
    }

    // Function to donate to a campaign
    function donate (uint campaignId) public payable
    {
        // validate campaignId
        require (campaignId < numCampaigns, "Invalid campaignId");
        
        Campaign storage c = campaigns[campaignId];

        // require endTime not reached
        require (c.endTime > block.timestamp, "EndTime reached");

        // require goal not reached, (allow the last donate to exceed goal)
        require (c.deposit < c.goal, "Goal reached");

        // require transferring amount > 0
        require (msg.value > 0, "Invalid donation amount");
        
        c.donors[c.numDonors++] = Donor(msg.sender, msg.value);
        c.deposit += msg.value;
    }

    // Function to withdraw from a campaign
}