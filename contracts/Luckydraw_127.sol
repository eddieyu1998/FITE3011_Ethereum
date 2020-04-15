pragma solidity ^0.5.16;

contract Luckydraw
{
    uint entryFee = 10000000000000000;  // 0.01 ether
    uint limit = 20;    // max 20 participants
    uint numParticipants;
    address[20] participants;

    function participate () public payable
    {
        require (numParticipants < 20, "The lucky draw is full");

        require (msg.value == entryFee, "Entry fee of 0.01 is required");

        participants[numParticipants] = msg.sender;

        numParticipants++;

        if (numParticipants == 20)
        {
            // start lucky draw
        }
    }

    function startLuckyDraw () private
    {
        
    }
}