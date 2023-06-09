// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract RideFactory {
    address[] public rides;

    event RideCreated(address ride);

    constructor() {}

    function createRide(
        uint256 _price,
        address _driver,
        string calldata origin,
        string calldata desitnation
    ) public returns (address) {
        address newRide = address(
            new Ride(msg.sender, _price, _driver, origin, desitnation)
        );
        rides.push(newRide);
        emit RideCreated(newRide);
        return newRide;
    }

    function getRides() public view returns (address[] memory) {
        return rides;
    }
}

contract Ride {
    address public owner;
    address public driver;
    address public passenger;
    uint256 public price;
    bool destinationReached;
    uint256 destinationReachedTime;
    bool rideStarted;
    uint256 rideStartTime;
    uint256 rideEndTime;
    string public origin;
    string public destination;

    event PassengerAdded(address passenger);
    event RideStarted(uint256 rideStartTime);

    // constructor with the price of the ride and the owner of the ride and driver
    constructor(
        address _owner,
        uint256 _price,
        address _driver,
        string memory _origin,
        string memory _destination
    ) {
        owner = _owner;
        driver = _driver;
        price = _price;
        origin = _origin;
        destination = _destination;
    }

    // function to add a passenger to the ride and
    // take money deposit from the passenger. check if enough and send it to the owner
    function addPassenger(address _passenger) public payable {
        require(msg.value >= price, "Not enough money");
        require(passenger == address(0), "Passenger already added");
        require(!rideStarted, "Ride already started");
        passenger = _passenger;
        payable(owner).transfer(msg.value);
        emit PassengerAdded(passenger);
    }

    // function to start the ride by passenger
    function startRide() public {
        require(msg.sender == passenger, "Only passenger can start the ride");
        require(!rideStarted, "Ride already started");
        rideStarted = true;
        rideStartTime = block.timestamp;
        emit RideStarted(rideStartTime);
    }

    // function to end the ride by passenger and validate the ride
    function endRide() public {
        require(msg.sender == passenger, "Only passenger can end the ride");
        rideEndTime = block.timestamp;
        destinationReached = true;
        destinationReachedTime = block.timestamp;
    }

    // function to request money from the owner to the driver
    function requestMoney() public {
        require(msg.sender == driver, "Only driver can request money");
        require(
            destinationReached == true,
            "Destination not reached yet, can't request money"
        );
        payable(driver).transfer(price);
    }

    // function for the owner to refund the passenger
    function refundPassenger() public {
        require(msg.sender == owner, "Only owner can refund the passenger");
        require(
            destinationReached == false,
            "Destination reached, can't refund the passenger"
        );
        payable(passenger).transfer(price);
    }

    // function to override destinationReached by the owner after verification of the driver
    function overrideDestinationReached() public {
        require(msg.sender == owner, "Only owner can override");
        destinationReached = true;
    }
}
