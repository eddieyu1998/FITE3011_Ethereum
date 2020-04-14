const Crowdfunding = artifacts.require("Crowdfunding");

const DEBUG = false;

/**
 * test case:
 * 
 * campaign0 - goal=1000, endTime=+10s
 *      donor1 donate 500
 *      donor2 donate 500
 *      deposit = 1000
 *      state = achieved, donors cannot withdraw
 *      owner withdraw
 *      deposit = 0
 *      state = completed
 * 
 * campaign1 - goal=2000, endTime=+20s
 *      donor1 donate 1000
 *      donor2 donate 999
 *      deposit = 1999
 *      state = active, donors cannot withdraw
 *      owner cannot withdraw
 *      state = expired
 *      donor1 withdraw
 *      deposit = 999
 *      donor2 withdraw
 *      deposit = 0
 */
contract("Crowdfunding test", async accounts => {
    const owner1 = accounts[0];
    const owner2 = accounts[1];
    const donor1 = accounts[2];
    const donor2 = accounts[3];

    const goal0 = 1000;
    const goal1 = 2000;

    const donor1Donation1 = 500;
    const donor1Donation2 = 1000;
    const donor2Donation1 = 500;
    const donor2Donation2 = 999;

    let endTime0;
    let endTime1;

    let crowdfunding;
    
    before(async () => {
        crowdfunding = await Crowdfunding.deployed();
    });

    it (`should create campaign [0] by [owner1] with goal of [${goal0}] wei and endTime [+10s]`, async () => {
        const now = new Date();
        const secondsSinceUnixEpoch = Math.round(now.getTime()/1000);

        endTime0 = secondsSinceUnixEpoch + 10;

        let result = await crowdfunding.createCampaign(endTime0, goal0, {from: owner1});
        logTx(result);

        let log = result.logs[0];
        assert.equal(log.args.campaignId, 0);
    });

    it (`should create campaign [1] by [owner2] with goal of [${goal1}] wei and endTime [+20s]`, async () => {
        const now = new Date();
        const secondsSinceUnixEpoch = Math.round(now.getTime()/1000);

        endTime1 = secondsSinceUnixEpoch + 20;

        let result = await crowdfunding.createCampaign(endTime1, goal1, {from: owner2});
        logTx(result);

        let log = result.logs[0];
        assert.equal(log.args.campaignId, 1);
    });

    it (`should return [${goal0}] as goal of campaign [0]`, async () => {
        let result = await crowdfunding.getGoal.call(0);
        logTx(result);

        assert.equal(result, goal0);
    });

    it (`should return [now+10s] as endTime of campaign [0]`, async () => {
        let result = await crowdfunding.getEndTime.call(0);
        logTx(result);

        assert.equal(result, endTime0);
    });

    it (`should return [0] as deposit of campaign [0]`, async () => {
        let result = await crowdfunding.getDeposit.call(0);
        logTx(result);

        assert.equal(result, 0);
    });

    it (`should return [${goal1}] as goal of campaign [1]`, async () => {
        let result = await crowdfunding.getGoal.call(1);
        logTx(result);

        assert.equal(result, goal1);
    });

    it (`should return [now+20s] as endTime of campaign [1]`, async () => {
        let result = await crowdfunding.getEndTime.call(1);
        logTx(result);

        assert.equal(result, endTime1);
    });

    it (`should return [0] as deposit of campaign [1]`, async () => {
        let result = await crowdfunding.getDeposit.call(1);
        logTx(result);

        assert.equal(result, 0);
    });

    it (`should return [${donor1Donation1}] as donation from [donor1] to campaign [0]`, async () => {
        let result = await crowdfunding.donate(0, {from: donor1, value: donor1Donation1});
        logTx(result);

        let log = result.logs[0];
        assert.equal(log.args.amount, donor1Donation1);
    });

    it (`should return [${donor1Donation1}] as deposit of campaign [0]`, async () => {
        let result = await crowdfunding.getDeposit.call(0);
        logTx(result);

        assert.equal(result, donor1Donation1);
    });

    it (`should return [${donor2Donation1}] as donation from [donor2] to campaign [0]`, async () => {
        let result = await crowdfunding.donate(0, {from: donor2, value: donor2Donation1});
        logTx(result);

        let log = result.logs[0];
        assert.equal(log.args.amount, donor2Donation1);
    });

    it (`should return [${donor1Donation1+donor2Donation1}] as deposit of campaign [0]`, async () => {
        let result = await crowdfunding.getDeposit.call(0);
        logTx(result);

        assert.equal(result, donor1Donation1+donor2Donation1);
    });

    // try withdraw, it should fail
    it (`should throw exception as [donor1] withdraw when goal achieved`, async () => {
        try {
            let result = await crowdfunding.withdraw(0, {from: donor1});
            logTx(result);

            assert.fail("Exception not received");
        } catch (err) {
            logTx(err);

            const exception = err.message.search("You are not allowed to withdraw at this point") >= 0;
            assert(exception, "Exception not match. Got this instead\n"+err);
        }
    })

    it (`should return [${goal0}] as total deposit withdrawn by [owner1]`, async () => {
        let result = await crowdfunding.withdraw(0, {from: owner1});
        logTx(result);

        let log = result.logs[0];
        assert.equal(log.args.amount, goal0);
    });

    it (`should return [0] as deposit of campaign [0]`, async () => {
        let result = await crowdfunding.getDeposit.call(0);
        logTx(result);

        assert.equal(result, 0);
    });

    it (`should throw exception as [owner1] withdraw when state is completed`, async () => {
        try {
            let result = await crowdfunding.withdraw(0, {from: owner1});
            logTx(result);

            assert.fail("Exception not received");
        } catch (err) {
            logTx(err);

            const exception = err.message.search("You are not allowed to withdraw at this point") >= 0;
            assert(exception, "Exception not match. Got this instead\n"+err);
        }
    })

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