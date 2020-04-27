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
        mapping (string => address payable) clients;
    }
    uint numAddressList;
    AddressList[] addressList;

    event AddressListCreated (uint addressListId, address payable owner);
    event AddressAdded (uint addressListId, string name, address payable clientAddress);
    event AddressUpdated (uint addressListId, string name, address payable oldAddress, address payable newAddress);
    event AmountSentToClient (uint addressListId, string name, address payable clientAddress, uint amount);
    event BalanceIncreased (uint addressListId, uint newBalance);

    // Function to create address list
    function createAddressList () public
    {
        uint addressListId = numAddressList++;
        numAddressList = addressList.push(AddressList(msg.sender, 0));

        emit AddressListCreated(addressListId, msg.sender);
    }

    // Function to add address to list
    function addAddress (uint addressListId, string memory name, address payable clientAddress) public
    {
        require (addressListId < numAddressList, "Invalid addressListId");

        require (msg.sender == addressList[addressListId].owner, "Only owner can modify the list");

        addressList[addressListId].clients[name] = clientAddress;

        emit AddressAdded(addressListId, name, clientAddress);
    }

    // Function to search address by name
    function getAddress (uint addressListId, string memory name) public view returns (address payable)
    {
        require (addressListId < numAddressList, "Invalid addressListId");

        // require owner identity?

        return addressList[addressListId].clients[name];
    }

    // same as addAddress, just added existance checking
    function updateAddress (uint addressListId, string memory name, address payable newAddress) public
    {
        require (addressListId < numAddressList, "Invalid addressListId");
        
        require (msg.sender == addressList[addressListId].owner, "Only owner can modify the list");

        require (addressList[addressListId].clients[name] != address(0x0), "Client does not exist");

        address payable oldAddress = addressList[addressListId].clients[name];
        addressList[addressListId].clients[name] = newAddress;

        emit AddressUpdated(addressListId, name, oldAddress, newAddress);
    }

    function sendToClient (uint addressListId, string memory name, uint amount) public payable
    {
        require (addressListId < numAddressList, "Invalid addressListId");

        require (msg.sender == addressList[addressListId].owner, "Only owner can use the list");

        require (addressList[addressListId].clients[name] != address(0x0), "Client does not exist");

        require (msg.value + addressList[addressListId].balance >= amount, "Balance not enough");

        address payable clientAddress = addressList[addressListId].clients[name];
        clientAddress.transfer(amount);

        emit AmountSentToClient(addressListId, name, clientAddress, amount);
    }

    function addBalance (uint addressListId) public payable
    {
        require (addressListId < numAddressList, "Invalid addressListId");

        require (msg.sender == addressList[addressListId].owner, "Only owner can use the list");

        require (msg.value > 0, "Invalid amount");

        addressList[addressListId].balance += msg.value;

        emit BalanceIncreased(addressListId, addressList[addressListId].balance);
    }
}