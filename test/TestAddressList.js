const AddressList = artifacts.require("Addresslist");

const DEBUG = false;


/** test case:
 * 
 * address0 create list [0]
 * address1 create list [1]
 * address0 add address1,2,3 to list[0]
 * address0 get address1,2,3 from name
 * address0 update address: 1<->3
 * address0 get address1,2,3 from name
 * address0 send to address1,2,3
 * 
 * 
 * 
 * 
 */
contract("Addresslist test", async accounts => {
    const address0 = accounts[0];
    const address1 = accounts[1];
    const address2 = accounts[2];
    const address3 = accounts[3];

    let addressList;
    
    before(async () => {
        addressList = await AddressList.deployed();
    });

    it (`should create [list0] by [address0]`, async () => {
        let result = await addressList.createAddressList({from:address0});
        logTx(result);

        let log = result.logs[0];
        assert.equal(log.args.addressListId.valueOf(), 0);
        assert.equal(log.args.owner, address0);
    });

    it (`should create [list1] by [address1]`, async () => {
        let result = await addressList.createAddressList({from:address1});
        logTx(result);

        let log = result.logs[0];
        assert.equal(log.args.addressListId.valueOf(), 1);
        assert.equal(log.args.owner, address1);
    });

    it (`should add [address1] to list [0] by [address0]`, async () => {
        let result = await addressList.addAddress(0, "Address1", address1, {from:address0});
        logTx(result);

        let log = result.logs[0];
        assert.equal(log.args.addressListId.valueOf(), 0);
        assert.equal(log.args.name, "Address1");
        assert.equal(log.args.clientAddress, address1);
    });

    it (`should add [address2] to list [0] by [address0]`, async () => {
        let result = await addressList.addAddress(0, "Address2", address2, {from:address0});
        logTx(result);

        let log = result.logs[0];
        assert.equal(log.args.addressListId.valueOf(), 0);
        assert.equal(log.args.name, "Address2");
        assert.equal(log.args.clientAddress, address2);
    });

    it (`should add [address3] to list [0] by [address0]`, async () => {
        let result = await addressList.addAddress(0, "Address3", address3, {from:address0});
        logTx(result);

        let log = result.logs[0];
        assert.equal(log.args.addressListId.valueOf(), 0);
        assert.equal(log.args.name, "Address3");
        assert.equal(log.args.clientAddress, address3);
    });

    it (`should add [address3] to list [0] by [address0]`, async () => {
        let result = await addressList.addAddress(0, "Address3", address3, {from:address0});
        logTx(result);

        let log = result.logs[0];
        assert.equal(log.args.addressListId.valueOf(), 0);
        assert.equal(log.args.name, "Address3");
        assert.equal(log.args.clientAddress, address3);
    });

    it (`should return address1`, async () => {
        let result = await addressList.getAddress.call(0, "Address1", {from:address0});
        logTx(result);
        
        assert.equal(result, address1);
    });

    it (`should return address2`, async () => {
        let result = await addressList.getAddress.call(0, "Address2", {from:address0});
        logTx(result);
        
        assert.equal(result, address2);
    });

    it (`should return address3`, async () => {
        let result = await addressList.getAddress.call(0, "Address3", {from:address0});
        logTx(result);
        
        assert.equal(result, address3);
    });

    it (`should update address1 as address3`, async () => {
        let result = await addressList.updateAddress(0, "Address1", address3, {from:address0});
        logTx(result);
        
        let log = result.logs[0];
        assert.equal(log.args.addressListId.valueOf(), 0);
        assert.equal(log.args.name, "Address1");
        assert.equal(log.args.oldAddress, address1);
        assert.equal(log.args.newAddress, address3);
    });

    it (`should update address3 as address1`, async () => {
        let result = await addressList.updateAddress(0, "Address3", address1, {from:address0});
        logTx(result);
        
        let log = result.logs[0];
        assert.equal(log.args.addressListId.valueOf(), 0);
        assert.equal(log.args.name, "Address3");
        assert.equal(log.args.oldAddress, address3);
        assert.equal(log.args.newAddress, address1);
    });

    it (`should return address3`, async () => {
        let result = await addressList.getAddress.call(0, "Address1", {from:address0});
        logTx(result);
        
        assert.equal(result, address3);
    });

    it (`should return address2`, async () => {
        let result = await addressList.getAddress.call(0, "Address2", {from:address0});
        logTx(result);
        
        assert.equal(result, address2);
    });

    it (`should return address1`, async () => {
        let result = await addressList.getAddress.call(0, "Address3", {from:address0});
        logTx(result);
        
        assert.equal(result, address1);
    });

    it (`should send [10] to address3 from address0`, async () => {
        let result = await addressList.sendToClient(0, "Address1", 10, {from: address0, value: 10});
        logTx(result);
        
        let log = result.logs[0];
        assert.equal(log.args.addressListId.valueOf(), 0);
        assert.equal(log.args.name, "Address1");
        assert.equal(log.args.clientAddress, address3);
        assert.equal(log.args.amount, address1);
    });


    /*
    it (``, async () => {
        let result = await crowdfunding;
        logTx(result);

        assert.equal(result, );
    });
    */
});

const logTx = tx => {
    if (!DEBUG) return;
    console.log('---------------');
    console.log(tx);
    console.log('---------------');
}

const getState = async (campaignId, instance) => {
    result = {};

    let state = await instance.getCampaignState.call(campaignId);
    result.state = state;

    let deposit = await instance.getDeposit.call(campaignId);
    result.deposit = deposit;

    let goal = await instance.getGoal.call(campaignId);
    result.goal = goal;

    let endTime = await instance.getEndTime.call(campaignId);
    result.endTime = endTime;

    return result;
}