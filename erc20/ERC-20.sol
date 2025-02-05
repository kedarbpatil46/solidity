//SPDX-License-Identifier:MIT

pragma solidity ^0.8.7;

contract ERC20 {
    uint256 public totalSupply;
    address public owner;
    uint256 public _decimals;

    mapping(address => uint256) private balanceOf;
    mapping(address => mapping(address => uint256)) private approvals;

    string public tokenName;
    string public tokenSymbol;

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed from, address indexed to, uint256 allowance);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only Owner can perform this function");
        _;
    }

    constructor(string memory _name, string memory _symbol, uint256 supply, uint256 dec) {
        tokenName = _name;
        tokenSymbol = _symbol;
        _decimals = dec;
        totalSupply = supply * (10**_decimals);
        owner = msg.sender;
    }

    function name() public view returns(string memory) {
        return tokenName;
    }

    function symbol() public view returns(string memory) {
        return tokenSymbol;
    }

    function decimals() public view returns(uint256) {
        return _decimals;
    }

    function transfer(address receiver, uint256 amount) public returns(bool) {
        require(amount <= balanceOf[msg.sender], "Not enough balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[receiver] += amount;
        emit Transfer(msg.sender, receiver, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public returns(bool) {
        require(spender != address(0), "Enter a valid address");
        approvals[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address spender, address receiver, uint256 amount) public returns(bool) {
        require(approvals[spender][msg.sender] >= amount);
        require(balanceOf[spender] >= amount);
        balanceOf[spender] -= amount;
        balanceOf[receiver] += amount;
        approvals[spender][msg.sender] -= amount;
        return true;
    }

    function mint(address receiver, uint256 amount) public onlyOwner returns(bool) {
        balanceOf[receiver] += amount;
        totalSupply += amount;
        emit Transfer(msg.sender, receiver, amount);
        return true;
    }

    function minerReward() public onlyOwner {
        mint(block.coinbase, 4*(10**_decimals));
    }
}