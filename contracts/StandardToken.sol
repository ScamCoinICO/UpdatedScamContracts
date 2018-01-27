pragma solidity ^0.4.18;


/**
 * Token Interface
*/

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