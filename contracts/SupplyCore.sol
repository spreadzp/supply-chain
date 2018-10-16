pragma solidity ^0.4.24;
contract SupplyCore {
    
    event NewSupply(uint256 _priceTheMedicine, string _nameOfMedicine, uint256 _countOfMedicine, uint256 _intervalTimeSupply);
    event NewHash(bytes32 _hash);
    struct Supply {
        address consumer;
        uint256 payment;
        string nameOfMedicine;
        uint256 countOfMedicine;
        uint256 intervalTimeOfSupply;
        address[] suppliers;
        bool supplyFinish;
        bool paymentToSupplier;
    }
    
    struct Drug {
        string nameDrug;
        uint256 priceDrug;
    }
    
    mapping (address => Drug[]) public drugs;
    mapping (address => bytes32[]) public consumerHashes;
    mapping (bytes32 => Supply[]) public supplies;
    address[]internal _suppliers; 
    // @dev don't accept straight eth (normally comes with low gas)
    function () public payable {
        revert();
    }
    
    function addDrug(string name, uint256 price) public {
        Drug memory newDrug = Drug({
            nameDrug: name,
            priceDrug: price
        });
        drugs[msg.sender].push(newDrug);
    }
    
    function addSupplierPartners(address partner) public {
        _suppliers.push(partner);
    }
    
    function getSupplierPartners() public view returns (address[]){
        return _suppliers;
    }
    
    function getConsumerHashes(address _consumer) public view returns (bytes32[]){
        return consumerHashes[_consumer];
    }
    
    function checkSupplyFinish(bytes32 hash) public view returns (bool){
        return supplies[hash][0].supplyFinish;
    }
    
    function getSupply(bytes32 hash) public view returns (address _consumer,
        uint256 _payment,
        string _nameOfMedicine, 
        uint256 _countOfMedicine,
        uint256 _intervalTimeOfSupply) {
        return (supplies[hash][0].consumer, supplies[hash][0].payment,
        supplies[hash][0].nameOfMedicine, 
        supplies[hash][0].countOfMedicine,
        supplies[hash][0].intervalTimeOfSupply);
    }
    
    function checkPaymentToSupplier(bytes32 hash) public view returns (bool){
        return supplies[hash][0].paymentToSupplier;
    }
    

    function createSupply (
        uint256 _priceTheMedicine, string _nameOfMedicine,
        uint256 _countOfMedicine, uint256 _intervalTimeSupply) public payable {
        // require (_suppliers.length == 0, "supplier have not partners");
        require (msg.value != 0, "consumer have not enough ethers for this supply");
        bytes32 newHashSupply = createHashSupply(_countOfMedicine, _intervalTimeSupply);
        consumerHashes[msg.sender].push(newHashSupply);
        Supply memory newSupply = Supply({
            consumer: msg.sender, payment: msg.value,
            nameOfMedicine: _nameOfMedicine,
            countOfMedicine: _countOfMedicine,
            intervalTimeOfSupply: _intervalTimeSupply, suppliers: _suppliers,
            supplyFinish: false, paymentToSupplier: false});
        supplies[newHashSupply].push(newSupply);
        emit NewSupply(_priceTheMedicine, _nameOfMedicine, _countOfMedicine, _intervalTimeSupply);
    }
    
    
    function createHashSupply(uint256 countOfMedicine, uint256 intervalTimeSupply) public returns (bytes32) {
       
        bytes32 hash = keccak256(abi.encodePacked(countOfMedicine,  intervalTimeSupply, now));
        emit NewHash(hash);
        return hash;
    }
}
