pragma solidity >= 0.8.4;

contract ZombieFactory {
    event NewZombie (uint zombieId, string name, uint dna);

    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits; //(10^16)

    struct Zombie {
        string name;
        uint dna;
    }

    Zombie[] public zombies;

    mapping (uint => address) public zombieToOwner;
    mapping (address => uint) ownerZombieCount;

    function _createZombie(string memory _name, uint _dna) private {
        zombies.push(Zombie(_name, _dna));
        uint id = zombies.length - 1;
        zombieToOwner[id] = msg.sender;
        ownerZombieCount[msg.sender]++;
        emit NewZombie(id, _name, _dna);
    }

    function _generateRandomDna(string memory _str) private view returns (uint) {
        uint rand = uint(keccak256(abi.encodePacked(_str)));
        return rand % dnaModulus;
    }

    function createRandomZombie(string memory _name) public {
        uint randDna = _generateRandomDna(_name);
        _createZombie(_name, randDna);
    }
}

/* Notes
1. 


4. Solidity does not support string comparison natively, so we simply compare the keccak256 hashes of the two strings.

5. Solidity supports inheritence. Hence, instead of writing one big long contract, it makes sense to split your code logic across multiple
    contracts to organize the code.

6.  Really cool and succint inheritence syntax:
    contract cat is animal {

    } // Here the contract cat inherits from the contract animal :D

7. Syntax to import one file into another:
    import './someOtherContract.sol';
    contract newContract is someOtherContract {

    }

8. In Solidity you can return more than one value from a function :D
*/