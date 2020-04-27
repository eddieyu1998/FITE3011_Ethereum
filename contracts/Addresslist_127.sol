pragma solidity ^0.5.16;

/** Design
*   1. Address list with owner and mapping (string => address)
*   2. Owner can modify the list
*   3. add address to list
*   4. search address by name
*   5. update address
*   6. transfer with name and amount
*
*/

contract Addresslist
{
    struct AddressList
    {
        address owner;
        uint balance;
        mapping (string => address) clients;
    }
    uint numAddressList;
    AddressList[] addressList;

    event AddressListCreated (uint addressListId, address owner);
    event AddressAdded (uint addressListId, string name, address clientAddress);
    event AddressUpdated (uint addressListId, string name, address oldAddress, address newAddress);
    event AmountSentToClient (uint addressListId, string name, address clientAddress, uint amount);

    // Function to create address list
    function createAddressList () public
    {
        uint addressListId = numAddressList++;
        numAddressList = addressList.push(AddressList(msg.sender, 0));

        emit AddressListCreated(addressListId, msg.sender);
    }

    // Function to add address to list
    function addAddress (uint addressListId, string memory name, address clientAddress) public
    {
        require (addressListId < numAddressList, "Invalid addressListId");

        require (msg.sender == addressList[addressListId].owner, "Only owner can modify the list");

        addressList[addressListId].clients[name] = clientAddress;

        emit AddressAdded(addressListId, name, clientAddress);
    }

    // Function to search address by name
    function getAddress (uint addressListId, string memory name) public view returns (address)
    {
        require (addressListId < numAddressList, "Invalid addressListId");

        // require owner identity?

        return addressList[addressListId].clients[name];
    }

    // same as addAddress, just added existance checking
    function updateAddress (uint addressListId, string memory name, address newAddress) public
    {
        require (addressListId < numAddressList, "Invalid addressListId");
        
        require (msg.sender == addressList[addressListId].owner, "Only owner can modify the list");

        require (addressList[addressListId].clients[name] > 0, "Client does not exist");

        address oldAddress = addressList[addressListId].clients[name];
        addressList[addressListId].clients[name] = newAddress;

        emit AddressUpdated(addressListId, name, oldAddress, newAddress);
    }

    function sendToClient (uint addressListId, string memory name, uint amount) public payable
    {
        require (addressListId < numAddressList, "Invalid addressListId");

        require (msg.sender == addressList[addressListId].owner, "Only owner can use the list");

        // add list balance to it
        require (msg.value >= amount, "Balance not enough");

        require (addressList[addressListId].clients[name] > 0, "Client does not exist");

        addressList[addressListId].clients[name].transfer(amount);

        emit AmountSentToClient(addressListId, name, addressList[addressListId].clients[name], amount);
    }

    function addBalance (uint addressListId) public payable
    {
        require (addressListId < numAddressList, "Invalid addressListId");

        require (msg.sender == addressList[addressListId].owner, "Only owner can use the list");

        require (msg.value > 0, "Invalid donation amount");

        addressList[addressListId].balance += msg.value;

        // emit BalanceIncreased(addressListId, msg.value);
    }
}