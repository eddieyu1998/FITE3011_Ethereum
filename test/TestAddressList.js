const AddressList = artifacts.require("Addresslist");

const DEBUG = false;

const BN = web3.utils.BN;

var chai = require

/** test case:
 * 
 * address1 create list [0]
 * address2 create list [1]
 * address1 add address2 to list[0]
 * 
 * 
 * 
 * 
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