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
    address owner;
    mapping (string => address) clients;

    // Function to add address to list
    function addAddress (string name, address clientAddress) public
    {
        // only owner can modify the list
        require (msg.sender == owner, "Only owner can modify the list");

        clients[name] = clientAddress;
    }

    // Function to search address by name
    function getAddress (string name) public view returns (address)
    {
        address clientAddress = clients[name];
        return clientAddress;
    }

    // same as addAddress, just a more intuitive name
    function updateAddress (string name, address clientAddress) public
    {
        // only owner can modify the list
        require (msg.sender == owner, "Only owner can modify the list");

        clients[name] = clientAddress;
    }

    function sendToClient (address sender, string name, uint amount) public payable
    {
        // sender's balance should be larger than transfer amount
        require (msg.sender.balance >= amount, "You don't have enough balance");
    
        // check name exists in list
        address clientAddress = clients[name];
        require (clientAddress > 0, "Address does not exist");

        
    }
}