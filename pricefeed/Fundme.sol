//SPDX-License-Identifier:MIT

pragma solidity ^0.8.17;

import {DataConsumerV3} from "cyfrin/fundme/DataConsumerV3.sol";

contract FundMe {
    address public owner;
    int256 public minimumUSD = 5;
    DataConsumerV3 public dataConsumer;

    int256 valueOfEth = dataConsumer.getChainlinkDataFeedLatestAnswer();
    uint256 val = uint256(minimumUSD/valueOfEth);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert("Not the owner");
        }
        _;
    }

    mapping(address => uint256) public fundings;

    function fund() public payable {
        if(msg.value < val) {
            revert("We cannot accept value less than 5 USD!");
        }
        fundings[msg.sender] = fundings[msg.sender] + msg.value;
    }

    function withdraw(uint256 amount) public onlyOwner {
        amount = amount*1e18;
        if(amount > address(this).balance) {
            revert("Not enough balance1");
        }

        (bool success,) = msg.sender.call{value: amount}("");
        if(!success){
            revert("Unable to withdraw"); 
        }
    }
}
