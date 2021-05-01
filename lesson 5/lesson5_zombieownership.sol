pragma solidity >=0.5.0 <0.6.0;

import "./zombieattack.sol";
import "./erc721.sol";
import "./safemath.sol";

contract ZombieOwnership is ZombieAttack, ERC721 {

  using SafeMath for uint256;

  mapping (uint => address) zombieApprovals;

  function balanceOf(address _owner) external view returns (uint256) {
    return ownerZombieCount[_owner];
  }

  function ownerOf(uint256 _tokenId) external view returns (address) {
    return zombieToOwner[_tokenId];
  }

  function _transfer(address _from, address _to, uint256 _tokenId) private {
    ownerZombieCount[_to] = ownerZombieCount[_to].add(1);
    ownerZombieCount[msg.sender] = ownerZombieCount[msg.sender].sub(1);
    zombieToOwner[_tokenId] = _to;
    emit Transfer(_from, _to, _tokenId);
  }

  function transferFrom(address _from, address _to, uint256 _tokenId) external payable {
      require (zombieToOwner[_tokenId] == msg.sender || zombieApprovals[_tokenId] == msg.sender);
      _transfer(_from, _to, _tokenId);
    }

  function approve(address _approved, uint256 _tokenId) external payable onlyOwnerOf(_tokenId) {
      zombieApprovals[_tokenId] = _approved;
      emit Approval(msg.sender, _approved, _tokenId);
    }

}


/*
Notes:
1. Tokens on Ethereum:
    A token on Ethereum is basically just a smart contract that follows some common rules — namely it implements
    a standard set of functions that all other token contracts share.

    The token standard that's a much better fit for crypto-collectibles like CryptoZombies — is called ERC721 tokens.

    ERC721 tokens are not interchangeable since each one is assumed to be unique, and are not divisible. You can 
    only trade them in whole units, and each one has a unique ID. 

    using a standard like ERC721 has the benefit that we don't have to implement the auction or escrow logic within our 
    contract that determines how players can trade / sell our zombies. If we conform to the spec, someone else could build
    an exchange platform for crypto-tradable ERC721 assets, and our ERC721 zombies would be usable on that platform. So there
    are clear benefits to using a token standard instead of rolling your own trading logic.

2. The contract of ERC721 standard looks pretty much like an interface, waiting to be implemented:
    contract ERC721 {
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    function balanceOf(address _owner) external view returns (uint256);
    function ownerOf(uint256 _tokenId) external view returns (address);
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function approve(address _approved, uint256 _tokenId) external payable;
    }

3. In Solidity, we can inheirt from multiple contracts.

4. To avoid overflows and underflows, we use the SafeMath library. A library is a special type of contract in Solidity. 
One of the things it is useful for is to attach functions to native data types.

For example, with the SafeMath library, we'll use the syntax using SafeMath for uint256. The SafeMath library has 4 functions
 — add, sub, mul, and div. And now we can access these functions from uint256 as follows:

    using SafeMath for uint256;

    uint256 a = 5;
    uint256 b = a.add(3); // 5 + 3 = 8
    uint256 c = a.mul(2); // 5 * 2 = 10

5. assert is similar to require, where it will throw an error if false. The difference between assert and require is that 
require will refund the user the rest of their gas when a function fails, whereas assert will not. So most of the time you 
want to use require in your code; assert is typically used when something has gone horribly wrong with the code (like a uint overflow).

6. The standard in the Solidity community is to use a format called natspec.

*/