pragma solidity ^0.4.18;

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

    /**
    * Internal transfer, only can be called by this contract
    */

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

    /**
    * Transfer tokens to specified address from your account
    *
    * @param _to Address to send scamcoins to
    * @param _value amount sending
    */
    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }

    /**
    * Transfer coins between addresses
    */

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    /**
    * Set allowance for other address
    * allows _spender to send no more than specified allowance _value
    *
    * @param _spender address authorized to spend
    * @param _value value allowed to send
    */

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    /**
    * set allowance for other address and notify
    */

    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
        return false;
    }
    /**
      * Irreversibly removes specified amount of tokens from system
    */

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
