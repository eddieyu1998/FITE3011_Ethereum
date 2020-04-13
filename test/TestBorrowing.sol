pragma solidity ^0.5.16;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Borrowing.sol";

contract TestBorrowing {
	// The address of the borrowing contract to be tested
	Borrowing borrowing = Borrowing(DeployedAddresses.Borrowing());

	// The id of the book that will be used for testing
	uint expectedBookId = 8;
    
	//The expected owner of borrowed book is this contract
	address expectedBorrower = address(this);

	// Testing the borrow() function
	function testUserCanBorrowBook() public {
		uint returnedId = borrowing.borrow(expectedBookId);
		Assert.equal(returnedId, expectedBookId, "Borrowing of the expected book should match what is returned.");
	}

	// Testing retrieval of a single book's borrower
	function testGetBorrowerAddressByBookId() public {
		address borrower = borrowing.borrowers(expectedBookId);
		Assert.equal(borrower, expectedBorrower, "Borrower of the expected book should be this contract");
	}

	// Testing retrieval of all book owners
	function testGetBorrowerAddressByBookIdInArray() public {
		// Store borrowers in memory rather than contract's storage
		address[12] memory borrowers = borrowing.getBorrowers();
		Assert.equal(borrowers[expectedBookId], expectedBorrower, "Owner of the expected book should be this contract");
	}
}