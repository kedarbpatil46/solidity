//SPDX-License-Identifier:MIT

pragma solidity ^0.8.7;

contract Receive {

    string _name;


    event set(string name);
    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }

    receive() external payable{}

    fallback() external payable {}

    function setName(string memory name) public payable returns(string memory){
        _name = name;
        return(_name);
    }

    function getName() public view returns(string memory) {
        return _name;
    }
}