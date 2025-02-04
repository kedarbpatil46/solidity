//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

contract Escrow {

    address payable owner;
    uint256 deposit_amount;

    constructor() {
        owner = payable(msg.sender);
    }

    modifier onlyOwner{
        require(msg.sender == owner, "Not owner");
        _;
    }

    mapping(address => uint256) public deposits;

    function deposit() public payable {
        require(msg.value >= deposit_amount, "Not enough amount");

        deposits[msg.sender] += msg.value;
    }

    function withdrawtoOwner(uint256 amount) public onlyOwner{
        (bool success,) = payable(owner).call{value: amount}("");
        require(success);
    }

    function withdraw(address payable _to, uint256 amount) public onlyOwner returns(bytes memory){
        (bool success, bytes memory name) =  _to.call{value:amount}(abi.encodeWithSignature("setName(string)", "kedar"));
        require(success);
        return abi.decode(name, (bytes));
    }
}