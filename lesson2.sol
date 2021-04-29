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
1. Addresses:
    The ethereum blockchain is made up of accounts, which you can think of as bank accounts.
    An account has a balance of Ether, and you can send and recieve Ether payments to other accounts, just like your bank account can wire transfer money to other bank accounts

    Each bank account has an address which you can think of like a bank account number.Its a unique identifier that points to an account.
    An address is owned by a specific user or a smart contract.

   Mapping:
    So we can use it as a unique ID for ownership of our zombies. When a user creates new zombies by interacting with our app, we'll set ownership of those zombies
    to the Ethereum address that called the function

    A mapping is essentially a key-value store for storing and looking up data
        mapping(uint => string) userIdToName;

2. msg.sender
    In solidity, there are certain global variables that are available to all functions. One of them is msg.sender

    msg.sender refers to the address of the person (or the smart contract) who called the current function

    In solidity, function execution always needs to start with an external caller. A contract will just sit on the blockchain doing nothing until someone calls one of its functions. So, 
    there will always be a msg.sender

3. require is a keyword in Solidity used for condition checking. If this condition is met, then only a function is executed otherwise, it terminates with an error.
    Example:
    function sayHiToVitalik (string memory _name) public returns (string memory) {
        require(keccak256(abi.encodePacked(_name)) == keccak256(abi.encodePacked("Vitalik")));
        return "Hi Vitalik, thank you for Ethereum!!";
    }

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