pragma solidity >=0.5.0 <0.6.0;

import "./zombiefeeding.sol";

contract ZombieHelper is ZombieFeeding {

  uint levelUpFee = 0.001 ether;

  modifier aboveLevel(uint _level, uint _zombieId) {
    require(zombies[_zombieId].level >= _level);
    _;
  }

  function withdraw() external onlyOwner {
    address _owner = owner();
    _owner.transfer(address(this).balance);
  }

  function setLevelUpFee(uint _fee) external onlyOwner {
    levelUpFee = _fee;
  }

  function levelUp(uint _zombieId) external payable {
    require(msg.value == levelUpFee);
    zombies[_zombieId].level++;
  }

  function changeName(uint _zombieId, string calldata _newName) external aboveLevel(2, _zombieId) ownerOf(_zombieId) {
    zombies[_zombieId].name = _newName;
  }

  function changeDna(uint _zombieId, uint _newDna) external aboveLevel(20, _zombieId) ownerOf(_zombieId) {
    zombies[_zombieId].dna = _newDna;
  }

  function getZombiesByOwner(address _owner) external view returns(uint[] memory) {
    uint[] memory result = new uint[](ownerZombieCount[_owner]);
    uint counter = 0;
    for (uint i = 0; i < zombies.length; i++) {
      if (zombieToOwner[i] == _owner) {
        result[counter] = i;
        counter++;
      }
    }
    return result;
  }

}


/*
    Notes:
1. *view* tells us that by running the functions, no data will be saved/changed.
*pure* tells us that not only does the function not save any data to the blockchain, but it also doens't read any data from the 
blockchain.
Both of these don't cost any gas to call if they're called from outside the contract, but the do cost gas if called internally by another function
because the calling function is eventually making changes on the blockchain.

2. The function modifiers can all be stacked together on a function definition, as follows:
    function test() external view onlyOwner anotherModifier {
        // Some function-y stuff
    }

3. The *payable* modifier:
They are a special type of functions that can recieve Ether.

In Ethereum, because both the money (Ether), the data (transaction payload), and the contract code itself all live on Ethereum, it's possible for you to call
a function and pay money to the contract at the same time.

This allows us to have some really cool logic, such as: requiring a certain payment to the contract in order to execute a function. 

Here's an example:
contract OnlineStore {
    function buySomething () external payable {
        require(msg.value == 0.01 ether); //ether is an inbuilt uint;
        transferStuff(msg.sender);
    }
}
msg.value is a way to see how much Ether was sent to the contract.
If a function is not marked as payable, and you try to send Ether to it, the function will reject your transaction.

4. The payment can only be done to a data type that's called address payable.
    Example:
    function withdraw() external onlyOwner() {
        address payable _owner = address(uint16(owner()));
        _owner.transfer(address(this).balance);
    }
    address(this).balance will return the total balance stored on the contract.

5. A make-shift way of generating random numbers in Solidity is as follows:
    // Generate a random number between 1 and 100:
    uint randNonce = 0;
    uint random = uint(keccak256(abi.encodePacked(now, msg.sender, randNonce))) % 100;
    randNonce++;
    uint random2 = uint(keccak256(abi.encodePacked(now, msg.sender, randNonce))) % 100;

    But, this is unsafe, because technically, this can be hacked. How? Read on:
    In Ethereum, when you call a function on a contract, you broadcast it to a node or nodes on the network 
    as a transaction. The nodes on the network then collect a bunch of transactions, try to be the first to 
    solve a computationally-intensive mathematical problem as a "Proof of Work", and then publish that group 
    of transactions along with their Proof of Work (PoW) as a block to the rest of the network.

    Once a node has solved the PoW, the other nodes stop trying to solve the PoW, verify that the other node's list 
    of transactions are valid, and then accept the block and move on to trying to solve the next block.

    This makes our random number function exploitable.

    Let's say we had a coin flip contract —heads you double your money, tails you lose everything. Let's say it used 
    the above random function to determine heads or tails. (random >= 50 is heads, random < 50 is tails).

    If I were running a node, I could publish a transaction only to my own node and not share it. I could then run the 
    coin flip function to see if I won — and if I lost, choose not to include that transaction in the next block I'm solving. 
    I could keep doing this indefinitely until I finally won the coin flip and solved the next block, and profit.

6. One relatively safe method is to use an Oracle to access a random number from outside the Ethereum blockchain

*/