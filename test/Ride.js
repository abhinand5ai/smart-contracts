const {
    time,
    loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");


describe("Ride", function () {
    const ONE_GWEI = 1_000_000_000;
    const price = ONE_GWEI;
    async function deployRideContract() {

        const [owner, driver, rider] = await ethers.getSigners();
        const Ride = await ethers.getContractFactory("Ride");
        const ride = await Ride.deploy(price, driver.address);
        return { ride, price, owner, driver, rider };
    }

    describe("Deployment", function () {
        it("Should set the right price", async function () {
            const { ride, price } = await loadFixture(deployRideContract);
            // console.log(ride);
            expect(await ride.price()).to.equal(price);
        });

        it("Owner should be the person who deployed the contract", async function () {
            const { ride, owner } = await loadFixture(deployRideContract);
            expect(await ride.owner()).to.equal(owner.address);
        });

        it("Driver should be the person passed in the constructor", async function () {
            const { ride, driver } = await loadFixture(deployRideContract);
            expect(await ride.driver()).to.equal(driver.address);
        });

        it("Add passneger fails if the price is not paid", async function () {
            const { ride, rider } = await loadFixture(deployRideContract);
            await expect(ride.addPassenger(rider.address)).to.be.revertedWith(
                "Not enough money"
            );
        });

        it("Add passnger fails if the ride is already started", async function () {
            const { ride, rider } = await loadFixture(deployRideContract);
            const encodedFunctionCall = ride.methods.addPassenger(rider.address).encodeABI();
            const gas = await ride.methods.addPassenger(rider.address).estimateGas({ from: riderAddress });
            const transactionObject = {
                from: riderAddress,
                to: rideAddress,
                gas: gas,
                data: encodedFunctionCall
                
            };

            const receipt = await web3.eth.sendTransaction(transactionObject);

            await ride.addPassenger(rider.address, { value: ONE_GWEI });
            // rider starts the ride
            await rider.sendTransaction({ to: ride.address, value: ONE_GWEI, gasLimit: 31000 });
            await expect(ride.addPassenger(rider.address, { value: ONE_GWEI })).to.be.revertedWith(
                "Ride already started"
            );
        });
    });

});


