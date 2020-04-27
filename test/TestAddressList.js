const AddressList = artifacts.require("Addresslist");

const DEBUG = false;

/** test case:
 * 
 * address1 create list [0]
 * address2 create list [1]
 * 
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
    const address1 = accounts[0];
    const address2 = accounts[1];
    const address3 = accounts[2];
    const address4 = accounts[3];

    let addressList;
    
    before(async () => {
        addressList = await AddressList.deployed();
    });

    it (`should create addresslist [0] by [address1]`, async () => {
        let result = await addressList.createAddressList();
        logTx(result);

        let log = result.logs[0];
        expect(log.args.addressListId, `addressListId`).to.equal(0);
        expect(log.args.owner, `owner address`).to.equal(address1);
        // assert.equal(log.args.addressListId, 0);
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