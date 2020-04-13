pragma solidity ^0.5.16;

contract Borrowing
{
    address[12] public borrowers;

    function borrow(uint bookId) public returns (uint)
    {
        require(bookId >= 0 && bookId <= 11);

        borrowers[bookId] = msg.sender;

        return bookId;
    }

    function getBorrowers() public view returns (address[12] memory)
    {
        return borrowers;
    }
}