pragma solidity ^0.5.16;

    // until the draw, everything is public. The last person enrolling has big advantage
    // the possible variants to introduce randomness are:
    // block info (now miner has the advantage, but majority of miners should be honest, not too many attempts can be performed before others broadcase a valid block)
    // user based variants e.g.address, user-picked random number (again, all publicly seen by the later participants)
    // variable not known at time of draw e.g.future blocks (too complicated to implement)

    // block.difficulty, block.timestamp
contract Luckydraw
{
    struct LuckyDraw
    {
        address organizer;
        uint entryFee;  // 0.01 ether
        uint limit;    // max 20 participants
        uint numParticipants;
        uint numRevealed;
        State state;
        mapping (address => bytes32) randomNumberHashs;
        address payable[] candidates;
        uint[] secretNumbers;
    }
    uint numLuckyDraw;
    LuckyDraw[] luckyDraws;

    enum State
    {
        Open,
        Revealing,
        Completed
    }

    event LuckyDrawCreated (uint luckyDrawId, address organizer);
    event EnterRevealingStage (uint luckyDrawId);
    event LuckyDrawCompleted (uint luckyDrawId, address payable winner);

    function createLuckyDraw () public payable
    {
        require(msg.value == 10 ether, "10 ether is required for prize");
        uint luckyDrawId = numLuckyDraw++;
        address payable[] memory candidates = new address payable[](20);
        uint[] memory secretNumbers = new uint[](20);
        numLuckyDraw = luckyDraws.push(LuckyDraw(msg.sender, 0.01 ether, 20, 0, 0, State.Open, candidates, secretNumbers));

        emit LuckyDrawCreated (luckyDrawId, msg.sender);
    }

    function participate (uint luckyDrawId, bytes32 randomNumberHash) public payable
    {
        require (luckyDraws[luckyDrawId].state == State.Open, "The luckydraw is not open for participation");

        require (luckyDraws[luckyDrawId].numParticipants < 20, "The lucky draw is full");

        require (msg.value == luckyDraws[luckyDrawId].entryFee, "Entry fee of 0.01 is required");

        luckyDraws[luckyDrawId].randomNumberHashs[msg.sender] = randomNumberHash;

        luckyDraws[luckyDrawId].numParticipants++;

        if (luckyDraws[luckyDrawId].numParticipants == 20)
        {
            luckyDraws[luckyDrawId].state = State.Revealing;

            emit EnterRevealingStage (luckyDrawId);
        }
    }

    function submitSecretNumber (uint luckyDrawId, uint secret) public
    {
        require (luckyDraws[luckyDrawId].state == State.Revealing, "Cannot submit secret number at this stage");

        require (luckyDraws[luckyDrawId].numRevealed < 20, "Cannot submit secret number at this stage");

        require (keccak256(abi.encodePacked(msg.sender, secret)) == luckyDraws[luckyDrawId].randomNumberHashs[msg.sender], "Your secret number does not match");

        luckyDraws[luckyDrawId].secretNumbers[luckyDraws[luckyDrawId].numRevealed] = secret;

        luckyDraws[luckyDrawId].candidates[luckyDraws[luckyDrawId].numRevealed] = msg.sender;

        luckyDraws[luckyDrawId].numRevealed++;

        if (luckyDraws[luckyDrawId].numRevealed == 20)
        {
            address payable winner = determineWinner(luckyDrawId);

            winner.transfer(10 ether);

            luckyDraws[luckyDrawId].state = State.Completed;

            emit LuckyDrawCompleted (luckyDrawId, winner);
        }
    }

    function determineWinner (uint luckyDrawId) private returns (address payable)
    {
        uint randomNumber = luckyDraws[luckyDrawId].secretNumbers[0];

        for (uint i = 1; i < luckyDraws[luckyDrawId].numRevealed; i++)
        {
            randomNumber ^= luckyDraws[luckyDrawId].secretNumbers[i];
        }

        address payable winner = luckyDraws[luckyDrawId].candidates[(randomNumber % 20)];

        return winner;
    }
}