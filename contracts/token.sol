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

    constructor() public payable {

    }

    // Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // Main Variables
    address public minterAddress;
    address public worldTresuryAddress;

    uint256 public createdAccounts = 0;
    uint256 public activeAccounts = 0;
    uint256 public maximumSupply = 0;
    uint256 public circulatingBaseSupply = 0;

    uint256 public endOfMonth;

    // Demurrage base
    uint256 public demurrageBaseMultiplier = 1000000000000000000;

    // Balance Mapping
    mapping(address => uint256) public baseBalance;

    struct Treasure {
        uint256 totalClaimed;
        mapping(uint256 => uint256) claimedInMonth;
    }
    mapping(address => Treasure) public treasure;
    mapping(address => bool) public hasTreasure;

    // Minting
    function issueTreasure(address account) public {
        require(msg.sender == minterAddress, 'Only the minterAddress may call this function');
        require(hasTreasure[account] == false, 'Account has already been issued their Lifetime Treasure');
        hasTreasure[account] = true;
        // To to
    }

    // ERC20 Standard Functions

    function totalSupply() public view returns (uint256) {
        return (circulatingBaseSupply.mul(demurrageBaseMultiplier)).div(1000000000000000000);
    }

    function balanceOf(address account) public view returns (uint256) {
        return (baseBalance[account].mul(demurrageBaseMultiplier)).div(1000000000000000000);
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        require(balanceOf(msg.sender) >= amount, 'Sender does not have enough balance');
        uint256 baseAmount = (amount.mul(1000000000000000000)).div(demurrageBaseMultiplier);
        baseBalance[msg.sender] = sub(baseBalance[msg.sender], baseAmount);
        baseBalance[recipient] = add(baseBalance[recipient], baseAmount);
        emit Transfer(msg.sender, recipient, amount);
        // Credit Treasure is eligible
        if (hasTreasure[msg.sender] == true && treasure[msg.sender].totalClaimed < && treasure[msg.sender].claimedInMonth[currentMonth]) {

        }
    }

    // function allowance(address owner, address spender) external view returns (uint256);

    // function approve(address spender, uint256 amount) external returns (bool);

    // function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

}