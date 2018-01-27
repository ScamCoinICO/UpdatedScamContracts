pragma solidity ^0.4.18;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}


contract Token {
    uint256 public totalSupply; // Total amount of tokens available
    function balanceOf(address _address) public constant returns (uint256 balance);  // Checks amount of tokens specific wallet holds
    function transfer(address _to, uint256 _value) public returns (bool success); // transfer _value tokens to wallet _to
    function transferFrom(address _from, address _to, uint256 _value) internal returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);

    // Events for logging
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _ownder, address indexed _spender, uint256 _value);
}

/**
 * ERC 20 token
*/

contract StandardToken is Token {
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

    function balanceOf(address _address) public constant returns (uint256 balance) {
        return balances[_address];
    }

    /**
     * Transfer tokens to another account
     *
     * @param _to - wallet address to send funds to
     * @param _value - amount of tokens to send
     */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        // Check 1 - _to address is not null
        // Check 2 - sender has enough tokens to send _value
        // Check 3 - no overflow / _value is greater than 0
        if (_to != 0x0
        && balanceOf(msg.sender) >= _value
        && (balanceOf(_to) + _value > balanceOf(_to))) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        }
        return false;
    }

    /**
     * Transfer tokens between different wallets
     *
     * @param _from - wallet address funds are coming from
     * @param _to - wallet address to send funds to
     * @param _value - amount of tokens to send
     */

    function transferFrom(address _from, address _to, uint256 _value) internal returns (bool success) {
        if ((_from != 0x0 && _to != 0x0)
        && balanceOf(_from) >= _value
        && (balanceOf(_to) + _value > balanceOf(_to))) {
            balances[_from] -= _value;
            balances[_to] += _value;
            allowed[_from][msg.sender] -= _value; // update allowance of sender given by _from
            Transfer(_from, _to, _value);
            return true;
        }
        return false;
    }

    /*
    * Set the allowance for other address, allows _spender to send no more than the specified _value
    *
    * @param _spender - address authorized to spend
    * @param _value - amount authorized to spend
    */

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}

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