pragma solidity ^0.4.24; 

pragma solidity ^0.4.24;
contract SupplyCore {
    
    constructor () public {
    }

    struct Supply {
        address consumer;
        uint256 payment;
        bytes32 nameOfMedicine;
        uint256 count;
        uint256 intervalTimeOfSupply;
        address suppliers;
        bool supplyFinish;
        bool paymentToSupplier;
    }

    mapping (uint256 => Supply[]) internal orders;
    address[]internal suppliers; 
    // @dev don't accept straight eth (normally comes with low gas)
    function () public payable {
        revert();
    } 
    
    function addSupplierPartners(address partner) {
        suppliers.push(partner);
    }

    function createSupply (
        uint256 priceTheMedicine, bytes32 nameOfMedicine,
        uint256 countOfMedicine, uint256 intervalTimeSupply) public payable {
        require (suppliers.length == 0, "supplier have not partners");
        require (msg.value <= priceTheMedicine, "consumer have not enough ethers for this supply");
    } 
}
