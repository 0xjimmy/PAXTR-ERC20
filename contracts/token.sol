/*
    PAX Token Reserve (PAXTR)
    ERC20 Token for the People
    https://paxco.in/
    -
    Developed by James Galbraith, https://Decentralised.Tech/
*/

pragma solidity ^0.5.11;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Owned {
    address public owner;
    address public newOwner;
    modifier onlyOwner {
        require(msg.sender == owner, 'Address not contract owner');
        _;
    }
    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner, 'Address not contract owner');
        owner = newOwner;
    }
}

contract PAXTR is Owned {
    using SafeMath for uint256;

    constructor(uint256 _endOfMonth) public payable {
        endOfMonth = _endOfMonth;
    }

    // Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Unlock(address indexed from, uint256 value);

    // Main Variables
    uint256 public constant decimals = 8;
    string public constant name = "PAX Treasure Reserve";
    string public constant symbol = "PAXTR";

    address public minterAddress;
    address public worldTresuryAddress;

    uint256 public createdAccounts = 0;
    uint256 public activeAccounts = 0;
    uint256 public maximumBaseSupply = 0;
    uint256 public circulatingBaseSupply = 0;
    uint256 public treasureAge = 79;

    uint256 public endOfMonth;
    uint256 public monthCount;

    // Demurrage base
    uint256 public demurrageBaseMultiplier = 1000000000000000000;

    // Balance Mapping
    mapping(address => uint256) public baseBalance;
    mapping(address => mapping(address => uint256)) public allowanceMapping;

    struct Treasure {
        uint256 totalClaimed;
        uint256 startMonth;
        mapping(uint256 => uint256) claimedInMonth;
    }
    mapping(address => Treasure) public treasure;
    mapping(address => bool) public hasTreasure;

    // Treasure
    function issueTreasure(address account) public {
        require(msg.sender == minterAddress, 'Only the minterAddress may call this function');
        require(hasTreasure[account] == false, 'Account has already been issued their Lifetime Treasure');
        hasTreasure[account] = true;

        uint256 _maxiumBaseSupply = (uint256(555500000000).mul(1000000000000000000)).div(demurrageBaseMultiplier);
        uint256 _circulatingSupply = (uint256(45550000000).mul(1000000000000000000)).div(demurrageBaseMultiplier);
        uint256 _baseBalance = (uint256(50000000).mul(1000000000000000000)).div(demurrageBaseMultiplier);
        uint256 _newWorldBalance = (uint256(45500000000).mul(1000000000000000000)).div(demurrageBaseMultiplier);
        maximumBaseSupply = maximumBaseSupply.add(_maxiumBaseSupply);
        circulatingBaseSupply = circulatingBaseSupply.add(_circulatingSupply);
        baseBalance[account] = baseBalance[account].add(_baseBalance);
        emit Transfer(address(0), account, 50000000);
        baseBalance[worldTresuryAddress] = baseBalance[worldTresuryAddress].add(_newWorldBalance);
        emit Transfer(address(0), worldTresuryAddress, 45500000000);

        treasure[account].totalClaimed = 50000000;
        treasure[account].startMonth = monthCount;
        treasure[account].claimedInMonth[monthCount] = 50000000;
        emit Unlock(account, 50000000);
    }

    function claim(address account, uint256 amount) internal returns (bool) {

    }

    // Issue refferal
    // Restore existing balance
    // restore existing treasure

    // New Month
    function newMonth() private {
        if (now <= endOfMonth) {
            endOfMonth = endOfMonth.add(2635200);
            uint256 bigInt = 1000000000000000000;
            demurrageBaseMultiplier = (demurrageBaseMultiplier*(bigInt))/(bigInt+(((treasureAge*bigInt)/12)/55555));
        }
    }

    // ERC20 Standard Functions

    function totalSupply() public view returns (uint256) {
        return (maximumBaseSupply.mul(demurrageBaseMultiplier)).div(1000000000000000000);
    }

    function circulatingSupply() public view returns (uint256) {
        return (circulatingBaseSupply.mul(demurrageBaseMultiplier)).div(1000000000000000000);
    }

    function balanceOf(address account) public view returns (uint256) {
        return (baseBalance[account].mul(demurrageBaseMultiplier)).div(1000000000000000000);
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        require(balanceOf(msg.sender) >= amount, 'Sender does not have enough balance');
        uint256 baseAmount = (amount.mul(1000000000000000000)).div(demurrageBaseMultiplier);
        baseBalance[msg.sender] = baseBalance[msg.sender].sub(baseAmount);
        baseBalance[recipient] = baseBalance[recipient].add(baseAmount);
        emit Transfer(msg.sender, recipient, amount);
        newMonth();
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return allowanceMapping[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowanceMapping[msg.sender][spender] = amount;
        newMonth();
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        require(allowanceMapping[sender][recipient] >= amount, 'Sender has not authorised this transaction');
        require(balanceOf(sender) >= amount, 'Sender does not have enough balance');
        uint256 baseAmount = (amount.mul(1000000000000000000)).div(demurrageBaseMultiplier);
        baseBalance[sender] = baseBalance[sender].sub(baseAmount);
        baseBalance[recipient] = baseBalance[recipient].add(baseAmount);
        allowanceMapping[sender][recipient] = allowanceMapping[sender][recipient].sub(baseAmount);
        emit Transfer(sender, recipient, amount);
        newMonth();
        return true;
    }
}