// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract RealEstateToken {
    string public name = "Real Estate Token";
    string public symbol = "RET";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    uint256 public tokenPrice = 0.01 ether;
    address public owner;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event TokensPurchased(address indexed buyer, uint256 amount);
    event Withdrawn(address indexed owner, uint256 amount);
    event PriceUpdated(uint256 newPrice);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    constructor(uint256 _initialSupply) {
        owner = msg.sender;
        totalSupply = _initialSupply * 10 ** uint256(decimals);
        balanceOf[address(this)] = totalSupply; // contract holds all tokens initially
        emit Transfer(address(0), address(this), totalSupply);
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function _transfer(address _from, address _to, uint256 _value) internal {
        require(_to != address(0), "Zero address");
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceOf[_from], "Insufficient balance");
        require(_value <= allowance[_from][msg.sender], "Allowance exceeded");
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    function buyTokens() public payable {
        require(msg.value > 0, "Send ETH to buy tokens");
        uint256 amount = (msg.value * 10 ** uint256(decimals)) / tokenPrice;
        require(balanceOf[address(this)] >= amount, "Not enough tokens in contract");
        _transfer(address(this), msg.sender, amount);
        emit TokensPurchased(msg.sender, amount);
    }

    function withdrawFunds() public onlyOwner {
        uint256 amount = address(this).balance;
        payable(owner).transfer(amount);
        emit Withdrawn(owner, amount);
    }

    function updateTokenPrice(uint256 _newPrice) public onlyOwner {
        require(_newPrice > 0, "Price must be positive");
        tokenPrice = _newPrice;
        emit PriceUpdated(_newPrice);
    }

    receive() external payable {
        buyTokens();
    }
}

