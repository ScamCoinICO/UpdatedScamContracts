pragma solidity ^0.4.18;

import "./StandardToken.sol";
import "./SafeMath.sol";

contract ScamToken is StandardToken {
    // token metadata
    string public constant name = "Scam Token";
    string public constant symbol = "SCAM";
    uint256 public constant decimals = 18;
    string public version = "1.0.0";

    // crowdsale parameters
    bool public isFinalized;
    uint256 public ICOEndTime;      // end time of ICO
    uint256 public constant scamFund = 250000000 * 10**decimals; // 250M SCAM tokens
    uint256 public constant tokenExchangeRate = 6969; // 6969 SCAM tokens to 1 ETH
    uint256 public constant tokenCreationCap = 750000000 * 10**decimals; // capped at 750M tokens
    uint256 public constant tokenCreationMin = 0;


    // contracts
    address public ethFundDeposit; // deposit address for ETH
    address public scamFundDeposit; // deposit address for SCAM

    // events
    event CreateSCAM(address indexed _to, uint256 _value);

    /*
    * Constructor Function
    */

    function ScamToken(address _ethFundDeposit, address _scamFundDeposit, uint256 _lengthOfICO) payable public {
        isFinalized = false;
        ethFundDeposit = _ethFundDeposit;
        scamFundDeposit = _scamFundDeposit;
        ICOEndTime = now + _lengthOfICO* 1 minutes;
        totalSupply = scamFund;                // total number of scam tokens
        balances[scamFundDeposit] = scamFund;  // Deposit scam token cap to admin wallet
        CreateSCAM(scamFundDeposit, scamFund);      // logs remaining SCAM funds distributable
    }

    /**
     * @dev Accepts ether and creates additional SCAM tokens
     */
    function () payable external {
        /* EVM wants require() over throw
        if (isFinalized || block.number < ICOStartBlock || block.number > ICOEndBlock || msg.value == 0) throw;
        */
        require(!isFinalized);
        require(now <= ICOEndTime);
        require(msg.value != 0);

        uint256 amountEth = msg.value;

        uint256 scamRequested = SafeMath.mul(amountEth, tokenExchangeRate);
        uint256 checkedSupply = SafeMath.add(scamRequested, totalSupply);

        // if (tokenCreationCap < checkedSupply) throw;
        require(tokenCreationCap >= checkedSupply);

        totalSupply = checkedSupply;
        balances[msg.sender] += scamRequested;
        CreateSCAM(msg.sender, scamRequested);
    }

    /**
     * @dev Ends funding period and sends ETH to wallet
     */
    function finalize() external {
        // Check 1 - check that funding period has not already been isFinalized
        // Check 2 - check that the address calling this function is our address
        // Check 3 - check the funding period has ended
        if (!isFinalized
        && msg.sender == ethFundDeposit
        && now > ICOEndTime) {
            bool check = ethFundDeposit.send(this.balance); // send eth to our wallet
            require(check);
            isFinalized = true;
        }
    }

    /**
     * @dev allows users to "recover ether" XDDDDD
     */
    function refund() external pure {
    }
}

/*
interface tokenRecipient {
    function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public;
}

contract ScamTokenERC20 {
    string public name;
    string public symbol;
    uint8 public decimals = 18; // don't change
    uint256 public totalSupply;

    // Array with all balances
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    // public event on blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);

    // notifies clients about amount burnt
    event Burn(address indexed from, uint256 value);

    function ScamTokenERC20(uint256 initialSupply, string tokenName, string tokenSymbol) public {
        totalSupply = initialSupply*10**uint256(decimals); // Update total supply with decimal amount
        balanceOf[msg.sender] = totalSupply;
        name = tokenName;
        symbol = tokenSymbol;
    }

    *//**
    * Internal transfer, only can be called by this contract
    *//*

    function _transfer(address _from, address _to, uint _value) internal {
        // Prevent transfer to 0x0 address. Use burn() instead
        require(_to != 0x0);
        // check if sender has enough coins
        require(_value <= balanceOf[_from]);
        // Check for overflows
        require(balanceOf[_to] + _value > balanceOf[_to]);
        // Save this for an assertion in the future
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        // update sender balanceOf
        balanceOf[_from] -= _value;
        // update receiver balanceOf
        balanceOf[_to] += _value;
        Transfer(_from, _to, _value);
        // Assert should not fail, used to find bugs in code
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    *//**
    * Transfer tokens to specified address from your account
    *
    * @param _to Address to send scamcoins to
    * @param _value amount sending
    *//*
    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }

    *//**
    * Transfer coins between addresses
    *//*

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    *//**
    * Set allowance for other address
    * allows _spender to send no more than specified allowance _value
    *
    * @param _spender address authorized to spend
    * @param _value value allowed to send
    *//*

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    *//**
    * set allowance for other address and notify
    *//*

    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
        return false;
    }
    *//**
      * Irreversibly removes specified amount of tokens from system
    *//*

    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        totalSupply -= _value;
        Burn(msg.sender, _value);
        return true;
    }

    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value);
        require(_value <= allowance[_from][msg.sender]);
        balanceOf[_from] -= _value;
        allowance[_from][msg.sender] -= _value;
        totalSupply -= _value;
        Burn(_from, _value);
        return true;
    }
}
*/