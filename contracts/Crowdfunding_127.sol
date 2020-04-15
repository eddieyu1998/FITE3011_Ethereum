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
    Campaign[] campaigns;

    event CampaignCreated (uint campaignId, address owner);
    event DonationReceived (uint campaignId, address donor, uint amount, uint deposit);
    event OwnerWithdrawn (uint campaignId, address owner, uint amount);
    event DonorWithdrawn (uint campaignId, address donor, uint amount);

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

    // Getter for current campaign state
    function getCampaignState (uint campaignId) public view returns (State)
    {
        require (campaignId < numCampaigns, "Invalid camapignId");
        return campaigns[campaignId].state;
    }

    // Function to create a campaign
    function createCampaign (uint endTime, uint goal) public
    {
        // validate endTime
        require (endTime > block.timestamp, "Invalid endTime");

        // validate goal
        require (goal > 0, "Invalid goal");

        uint campaignId = numCampaigns++;
        numCampaigns = campaigns.push(Campaign(msg.sender, endTime, goal, 0, 0, State.Active));

        emit CampaignCreated(campaignId, msg.sender);
    }

    // Function to check (and update) campaign state (from Active)
    function checkCampaignState (uint campaignId) public return (State)
    {
        // validate campaignId
        require (campaignId < numCampaigns, "Invalid camapignId");

        Campaign storage c = campaigns[campaignId];

        if (c.state == State.Active)
        {
            if (c.deposit >= c.goal)
            {
                c.state = State.Achieved;
            }
            else if (block.timestamp > c.endTime)
            {
                c.state = State.Expired;
            }
        }
        return c.state;
    }

    // Function to donate to a campaign
    function donate (uint campaignId) public payable
    {
        // validate campaignId
        require (campaignId < numCampaigns, "Invalid campaignId");

        State state = checkCampaignState(campaignId);

        // endTime not reached + goal not reached => state == Active
        require (state == State.Active, "The campaign is currently not accepting donation");

        Campaign storage c = campaigns[campaignId];

        // owner cannot donate to his own campaign
        require (c.owner != msg.sender, "Campaign owner cannot donate to his own campanign");

        // donor can only donate one time
        require (c.donors[msg.sender] == 0, "You can only donate once");

        // require transferring amount > 0
        require (msg.value > 0, "Invalid donation amount");

        // allow donation
        c.donors[msg.sender] = msg.value;
        c.numDonors++;
        c.deposit += msg.value;

        // check whether the goal is reached
        checkCampaignState(campaignId);

        emit DonationReceived(campaignId, msg.sender, msg.value, c.deposit);
    }

    // Function to withdraw from a campaign
    function withdraw (uint campaignId) public
    {
        // validate campaignId
        require (campaignId < numCampaigns, "Invalid campaignId");

        State state = checkCampaignState(campaignId);
        Campaign storage c = campaigns[campaignId];

        if (msg.sender == c.owner)
        {
            // check campaign state
            require (state == State.Achieved, "You are not allowed to withdraw at this point");

            // allow owner to withdrawn all deposit
            uint withdrawnAmount = c.deposit;
            msg.sender.transfer(withdrawnAmount);

            // set deposit to 0, then update state
            c.deposit = 0;
            c.state = State.Completed;

            emit OwnerWithdrawn(campaignId, msg.sender, withdrawnAmount);
        }
        else
        {
            // check campaign state
            require (state == State.Expired, "You are not allowed to withdraw at this point");

            // check if sender took part in it
            require (c.donors[msg.sender] > 0, "You have no donation that can be withdrawn");

            // allow refund, then remove from mapping
            uint refundAmount = c.donors[msg.sender];
            msg.sender.transfer(refundAmount);

            // update deposit, then delete sender from the donor list
            c.deposit -= refundAmount;
            delete c.donors[msg.sender];

            emit DonorWithdrawn(campaignId, msg.sender, refundAmount);
        }
    }
}