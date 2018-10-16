pragma solidity ^0.4.24;
contract SupplyCore {
    
    event NewSupply(uint256 _sumTheMedicine, string _nameOfMedicine, uint256 _countOfMedicine, uint256 _intervalTimeSupply);
    event NewHash(bytes32 _hash);
    struct Supply {
        address consumer;
        uint256 payment;
        string nameOfMedicine;
        uint256 countOfMedicine;
        uint256 intervalTimeOfSupply;
        address supplier;
        bool supplyFinish;
        bool paymentToSupplier;
    }
    
    struct Drug {
        string nameDrug;
        uint256 priceDrug;
        address supplier;
    }
    
    mapping (bytes32 => Drug[]) public drugs;
    mapping (address => bytes32[]) public medicinesOfSupplier;
    mapping (address => bytes32[]) public consumerHashes;
    mapping (bytes32 => Supply[]) public supplies;
    mapping (address => address[]) public partnersOfSupplier;
    address[]internal _suppliers; 
    
    // @dev don't accept straight eth (normally comes with low gas)
    function () public payable {
        revert();
    }
    
    // add modifier supplier
    function addDrug(string name, uint256 price) public {
        Drug memory newDrug = Drug({
            nameDrug: name,
            priceDrug: price,
            supplier: msg.sender
        });
        bytes32 hashMedicine = keccak256(abi.encodePacked(name,  price, msg.sender));
        medicinesOfSupplier[msg.sender].push(hashMedicine);
        drugs[hashMedicine].push(newDrug);
    }
    
    function getMedicines(bytes32 hashDrug) public view returns(string nameDrug,
        uint256 priceDrug, address supplier) {
        return (drugs[hashDrug][0].nameDrug, drugs[hashDrug][0].priceDrug,
        drugs[hashDrug][0].supplier);
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
        bytes32 _hashDrug, uint256 _countOfMedicine, uint256 _intervalTimeSupply) public payable {
        // require (_suppliers.length == 0, "supplier have not partners");
        uint256 sumOfConsumer = drugs[_hashDrug][0].priceDrug * _countOfMedicine;
        require (msg.value >= sumOfConsumer, "consumer have not enough ethers for this supply");
        bytes32 newHashSupply = createHashSupply(_countOfMedicine, _intervalTimeSupply);
        consumerHashes[msg.sender].push(newHashSupply);
        Supply memory newSupply = Supply({
            consumer: msg.sender, payment: msg.value,
            nameOfMedicine: drugs[_hashDrug][0].nameDrug,
            countOfMedicine: _countOfMedicine,
            intervalTimeOfSupply: _intervalTimeSupply, supplier: drugs[_hashDrug][0].supplier,
            supplyFinish: false, paymentToSupplier: false});
        supplies[newHashSupply].push(newSupply);
        emit NewSupply(msg.value, drugs[_hashDrug][0].nameDrug, _countOfMedicine, _intervalTimeSupply);
    }
    
    
    function createHashSupply(uint256 countOfMedicine, uint256 intervalTimeSupply) public returns (bytes32) {
        bytes32 hash = keccak256(abi.encodePacked(countOfMedicine,  intervalTimeSupply, now));
        emit NewHash(hash);
        return hash;
    }
}
