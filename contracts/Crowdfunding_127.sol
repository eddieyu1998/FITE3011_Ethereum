pragma solidity ^0.5.16;

/** Design
*   1. need to store a list of crowdfunding campaign
*   2. Each contains a owner (address), endtime (uint), goal (uint), deposit (uint), number of donors (uint), each donor (address) and his amount (uint), +campaign state
*
*   methods:
*   1. Get the current total deposit
*   2. Get the endtime
*   3. Get the goal
*   4. Create campaign
*   5. Allow donor to donate (address, amount) -> check amount valid, goal haven't achieved, endtime not reached
*       + check donor != owner, donor hasn't donated before
*   6. Allow owner withdraw if goal achieved -> transfer
*   7. Allow donor withdraw if goal not achieved, when endtime reached
*
*   Problems:
*   1. Can owner double draw?: campaign state (active, achieved, expired, completed)
*       - active : endTime not reached, goal not reached, anyone can donate
*       - achieved : goal reached, independent of endTime, no one can donate or refund, owner can withdraw
*       - expired : endTime reached, goal not reached, donor can refund
*       - completed: owner has drawn from the campaign
*   2. endTime issue, last minute draw, time back donate: include a settledown period (+900s), after that can action be perform
*
*
*   Security:
*   1. variable private modifier needed?
*
* */

contract Crowdfunding
{
    // struct type representing a crowdfunding campaign
    struct Campaign
    {
        address owner;  // address of campaign owner
        uint endTime;   // endtime as seconds since unix epoch
        uint goal;      // amount of goal, in wei
        uint deposit;   // amount of current deposit, in wei
        uint numDonors; // total number of donors
        State state;    // state of the campaign
        mapping (address => uint) donors;    // mapping of donor to his donation
    }

    enum State
    {
        Active,
        Achieved,
        Expired,
        Completed
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
        campaigns[campaignId] = Campaign(msg.sender, endTime, goal, 0, 0, State.Active);
    }

    // Function to donate to a campaign
    function donate (uint campaignId) public payable
    {
        // validate campaignId
        require (campaignId < numCampaigns, "Invalid campaignId");

        Campaign storage c = campaigns[campaignId];

        // owner cannot donate to his own campaign
        require (c.owner != msg.sender, "Campaign owner cannot donate to his own campanign");

        // donor can only donate one time
        require (c.donors[msg.sender] == 0, "You can only donate once");

        // require endTime not reached
        require (c.endTime > block.timestamp, "EndTime reached");

        // require goal not reached, (allow the last donate to exceed goal)
        require (c.deposit < c.goal, "Goal has already been reached");

        // require transferring amount > 0
        require (msg.value > 0, "Invalid donation amount");

        // possibly redundant? endTime not reached + goal not reached => Active
        require (c.state = State.Active, "The campaign is currently not accepting donation");

        c.donors[msg.sender] = msg.value;
        c.deposit += msg.value;

        // check whether the goal is reached
    }

    // Function to withdraw from a campaign
    function withdraw (uint campaignId) public
    {
        // validate campaignId
        require (campaignId < numCampaigns, "Invalid campaignId");

        Campaign storage c = campaigns[campaignId];
        if (msg.sender == c.owner)
        {
            // check if goal is reached
            require (c.deposit >= c.goal, "Goal not reached");

            // check if fund has already been drawn (campaign state)

            //
            msg.sender.transfer(c.deposit);

            // prevent owner double draw
            // change state
        }
        else
        {
            // check if sender took part in it

            // allow refund, then remove from mapping
        }
    }
}