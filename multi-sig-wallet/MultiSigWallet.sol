//SPDX-License-Identifier:MIT

pragma solidity ^0.8.7;

contract MultiSigWallet {
    event Deposit(address indexed sender, uint256 amount, uint256 balance);
    event SubmitTransaction(address indexed owner, uint256 indexed txIndex, address indexed to, uint256 value, bytes data);
    event ConfirmTransaction(address indexed owner, uint256 indexed txIndex);
    event RevokeConfirmation(address indexed owner, uint256 indexed txIndex);
    event ExecuteTransaction(address indexed owner, uint256 indexed txIndex);

    address[] public owners;
    mapping(address => bool) public isOwner;
    uint256 public numberOfConfirmations;

    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
        uint256 numConfirmations;
    }

    mapping(uint256 => mapping(address => bool)) public isConfirmed;
    Transaction[] public transactions;

    modifier onlyOwner {
        require(isOwner[msg.sender], "This address is not one of the owners!");
        _;
    }

    modifier txExists(uint256 _txNum) {
        require(_txNum < transactions.length, "Invalid Transaction index!");
        _;
    }

    modifier notExectuted(uint256 _txNum) {
        require(!transactions[_txNum].executed, "Transaction is already executed");
        _;
    }

    modifier notConfirmed(uint256 _txNum) {
        require(!isConfirmed[_txNum][msg.sender], "Transaction is already confirmed with this address!");
        _;
    }

    constructor(address[] memory _owners, uint256 _numOfConfirmations) { 
        require(_owners.length > 0, "Enter the owners");
        require(_numOfConfirmations > 0 && _numOfConfirmations < _owners.length);

        for(uint256 i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "Invalid address");
            require(!isOwner[owner], "Address not unique");

            isOwner[owner] = true;
            owners.push(owner);
        }

        numberOfConfirmations = _numOfConfirmations;
    }
    
    receive() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    function submitTransaction(address _to, uint256 amount, bytes memory _data) public onlyOwner {
        uint256 txIndex = transactions.length;

        transactions.push(Transaction({
            to: _to,
            value: amount,
            data: _data,
            executed: false,
            numConfirmations: 0
        }));

        emit SubmitTransaction(msg.sender, txIndex, _to, amount, _data);
    }

    function confirmTransaction(uint256 txIndex) public onlyOwner txExists(txIndex) notExectuted(txIndex) notConfirmed(txIndex){
        Transaction storage transaction = transactions[txIndex];
        transaction.numConfirmations+=1;
        isConfirmed[txIndex][msg.sender] = true;
        emit ConfirmTransaction(msg.sender, txIndex);
    }

    function executeTransaction(uint256 txIndex) public onlyOwner txExists(txIndex) notExectuted(txIndex) {
        Transaction storage transaction = transactions[txIndex];

        require(transaction.numConfirmations >= numberOfConfirmations, "Cannot execute transaction");
        transaction.executed = true;

        (bool success,) = transaction.to.call{value:transaction.value}(transaction.data);
        require(success, "Transaction failed");
        
        emit ExecuteTransaction(msg.sender, txIndex);
    }

    function revokeConfirmation(uint256 txIndex) public onlyOwner txExists(txIndex) notExectuted(txIndex) {
        Transaction storage transaction = transactions[txIndex];
        require(isConfirmed[txIndex][msg.sender], "Transaction is not confirmed by this address");

        transaction.numConfirmations -= 1;
        isConfirmed[txIndex][msg.sender] = false;

        emit RevokeConfirmation(msg.sender, txIndex);
    }

    function getTransactionStatus(uint256 txIndex) public view returns(Transaction memory) {
        return transactions[txIndex];
    }
}