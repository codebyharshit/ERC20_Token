//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract ERC20_Abstr{
// Functions 

function name() virtual public view returns(string memory);
function symbol() virtual public view returns(string memory);
function decimals() virtual public view returns(uint8);

//Main functions
function totalSupply() virtual public view returns(uint256);
function balanceOf(address _owner) virtual public view returns(uint256 balance);
function transfer(address _to, uint256 _value) virtual public returns(bool success);
function transferFrom(address _from, address _to, uint256 _value) virtual public returns(bool success);
function approve(address _spender, uint256 _value) virtual public returns(bool success);
function allowance(address _owner, address _spender) virtual public view returns(uint256 remaining);

//Events
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}

contract Ownership{
    address public contractOwner; 
    address public proposedOwner;

    //Events 
    event ownershipTransferred(address indexed _oldOwner, address indexed _newOwner);

    // //custom Errors 
    // error onlyOwner();
    // error onlyNewOwner();
    // error insufficientAmount();

    constructor(){
        contractOwner = msg.sender;
    }
    //change owner function
    function transferOwnership(address _to) public{
        if(msg.sender != contractOwner){
            // revert onlyOwner();
        }
        proposedOwner = _to;
    }
    function acceptOwnership() public{
        if(msg.sender != proposedOwner){
            // revert onlyNewOwner();
        }
        contractOwner = proposedOwner;
        proposedOwner = address(0);
        emit ownershipTransferred(contractOwner, proposedOwner);
    }
}

contract ERC20 is ERC20_Abstr, Ownership{
    string public _name; 
    string public _symbol;
    uint8 public _decimal;
    uint256 public _totalSupply;
    address public _minter;
    mapping(address=>uint256) public tokenBalances;
    mapping(address=>mapping(address=>uint256)) public allowedAcc;

    constructor() {
        _name = "FREE";
        _symbol= "FR";
        _decimal = 3;
        _totalSupply = 1000;
        _minter = msg.sender;
        tokenBalances[msg.sender] = _totalSupply;
    }

    function name() override public view returns(string memory){
        return _name;
    }
    function symbol() override public view returns (string memory){
        return _symbol;
    }
    function decimals() override public view returns(uint8){
        return 3;
    }

    function totalSupply() override public view returns(uint256){
        return _totalSupply;
    }
    function balanceOf(address _owner) override public view returns (uint256 balance){
        return tokenBalances[_owner];
    }
    function transfer(address _to, uint256 _value) override public returns (bool success){
        if(tokenBalances[msg.sender] < _value){
            // revert insufficientAmount();
        }
    tokenBalances[msg.sender] -= _value;
    tokenBalances[_to] += _value;
    emit Transfer(msg.sender, _to, _value);
    return true;
    }
    function transferFrom(address _from, address _to, uint256 _value) override public returns (bool success){
        uint256 amts = allowedAcc[_from][msg.sender];
        if(amts < _value){
            // revert insufficientAmount();
        }
        tokenBalances[_from] -= _value;
        tokenBalances[_to] += _value;
        emit Transfer(_from, _to, _value);
        return true;
    }
    function approve(address _spender, uint256 _value) override public returns (bool success) {
        if(tokenBalances[msg.sender]< _value){
            // revert insufficientAmount();
    }
    allowedAcc[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
    }
    function allowance(address _owner, address _spender) override public view returns (uint256 remaining){
        uint256 allowedAmt = allowedAcc[_owner][_spender];
        return allowedAmt;
    }
}
