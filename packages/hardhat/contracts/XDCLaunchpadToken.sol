// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract XDCLaunchpadToken is ERC20, Ownable, ERC20Permit, ReentrancyGuard, Pausable, AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    uint256 public constant TOTAL_SUPPLY = 21_000_000_000_000 * 10**18; // 21 trillion tokens
    uint256 public constant FEE_AMOUNT = 8 * 10**16; // 0.08 tokens (0.08 XDC equivalent in tokens)
    uint256 public constant MIN_STAKE_PERIOD = 7 days; // Minimum staking period
    uint256 public constant MAX_FEE_PERCENTAGE = 100; // 1% max fee

    // Staking variables
    mapping(address => uint256) public stakedBalances;
    mapping(address => uint256) public stakingTimestamps;
    uint256 public totalStaked;

    // Fee collection tracking
    uint256 public totalFeesCollected;
    uint256 public feePercentage = 8; // 0.08% fee (8/10000)

    // Emergency variables
    bool public emergencyMode;
    uint256 public lastEmergencyAction;

    event Staked(address indexed user, uint256 amount, uint256 timestamp);
    event Withdrawn(address indexed user, uint256 amount, uint256 timestamp);
    event FeeCollected(address indexed from, uint256 fee, uint256 totalCollected);
    event EmergencyModeActivated(address indexed activator, uint256 timestamp);
    event EmergencyModeDeactivated(address indexed deactivator, uint256 timestamp);
    event FeePercentageUpdated(uint256 oldFee, uint256 newFee);
    event NativeWithdrawn(address indexed to, uint256 amount);

    constructor(address initialOwner)
        ERC20("XDC Launchpad Token", "XDCLP")
        Ownable(initialOwner)
        ERC20Permit("XDC Launchpad Token")
    {
        _grantRole(DEFAULT_ADMIN_ROLE, initialOwner);
        _grantRole(ADMIN_ROLE, initialOwner);
        _grantRole(OPERATOR_ROLE, initialOwner);

        _mint(initialOwner, TOTAL_SUPPLY);

        // Initialize emergency mode as false
        emergencyMode = false;
        lastEmergencyAction = block.timestamp;
    }

    // Override transfer to include fee
    function transfer(address to, uint256 amount) public override whenNotPaused nonReentrant returns (bool) {
        require(to != address(0), "Cannot transfer to zero address");
        require(amount > 0, "Amount must be greater than 0");
        require(!emergencyMode, "Emergency mode active");

        uint256 fee = FEE_AMOUNT; // Fixed fee
        require(amount > fee, "Amount must be greater than fee");
        require(balanceOf(_msgSender()) >= amount, "Insufficient balance");

        uint256 amountAfterFee = amount - fee;

        // Transfer fee to owner
        _transfer(_msgSender(), owner(), fee);
        totalFeesCollected += fee;
        emit FeeCollected(_msgSender(), fee, totalFeesCollected);

        // Transfer remaining amount
        _transfer(_msgSender(), to, amountAfterFee);
        return true;
    }

    // Override transferFrom to include fee
    function transferFrom(address from, address to, uint256 amount) public override whenNotPaused nonReentrant returns (bool) {
        require(from != address(0), "Cannot transfer from zero address");
        require(to != address(0), "Cannot transfer to zero address");
        require(amount > 0, "Amount must be greater than 0");
        require(!emergencyMode, "Emergency mode active");

        uint256 fee = FEE_AMOUNT; // Fixed fee
        require(amount > fee, "Amount must be greater than fee");

        uint256 currentAllowance = allowance(from, _msgSender());
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");

        uint256 amountAfterFee = amount - fee;

        // Transfer fee to owner
        _transfer(from, owner(), fee);
        totalFeesCollected += fee;
        emit FeeCollected(from, fee, totalFeesCollected);

        // Transfer remaining amount
        _transfer(from, to, amountAfterFee);

        // Update allowance
        _approve(from, _msgSender(), currentAllowance - amount);

        return true;
    }

    // Deposit function (stake tokens)
    function deposit(uint256 amount) external whenNotPaused nonReentrant {
        require(amount > 0, "Amount must be greater than 0");
        require(balanceOf(_msgSender()) >= amount, "Insufficient balance");
        require(!emergencyMode, "Emergency mode active");

        _transfer(_msgSender(), address(this), amount);
        stakedBalances[_msgSender()] += amount;
        totalStaked += amount;
        stakingTimestamps[_msgSender()] = block.timestamp;

        emit Staked(_msgSender(), amount, block.timestamp);
    }

    // Withdraw function (unstake tokens)
    function withdraw(uint256 amount) external whenNotPaused nonReentrant {
        require(amount > 0, "Amount must be greater than 0");
        require(stakedBalances[_msgSender()] >= amount, "Insufficient staked balance");
        require(!emergencyMode, "Emergency mode active");

        // Check minimum staking period
        if (stakingTimestamps[_msgSender()] > 0) {
            require(block.timestamp >= stakingTimestamps[_msgSender()] + MIN_STAKE_PERIOD, "Minimum staking period not met");
        }

        stakedBalances[_msgSender()] -= amount;
        totalStaked -= amount;
        _transfer(address(this), _msgSender(), amount);

        emit Withdrawn(_msgSender(), amount, block.timestamp);
    }

    // Get staked balance
    function getStakedBalance(address user) external view returns (uint256) {
        return stakedBalances[user];
    }

    // Receive function to accept native currency
    receive() external payable {}

    // Withdraw native currency (only admin role)
    function withdrawNative(uint256 amount) external onlyRole(ADMIN_ROLE) nonReentrant {
        require(amount > 0, "Amount must be greater than 0");
        require(amount <= address(this).balance, "Insufficient contract balance");
        require(!emergencyMode, "Emergency mode active");

        payable(owner()).transfer(amount);
        emit NativeWithdrawn(owner(), amount);
    }

    // Emergency functions
    function activateEmergencyMode() external onlyRole(ADMIN_ROLE) {
        emergencyMode = true;
        lastEmergencyAction = block.timestamp;
        emit EmergencyModeActivated(_msgSender(), block.timestamp);
    }

    function deactivateEmergencyMode() external onlyRole(ADMIN_ROLE) {
        emergencyMode = false;
        lastEmergencyAction = block.timestamp;
        emit EmergencyModeDeactivated(_msgSender(), block.timestamp);
    }

    // Pause/unpause functions (admin only)
    function pause() external onlyRole(ADMIN_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(ADMIN_ROLE) {
        _unpause();
    }

    // Fee management functions
    function setFeePercentage(uint256 newFee) external onlyRole(ADMIN_ROLE) {
        require(newFee <= MAX_FEE_PERCENTAGE, "Fee percentage too high");
        uint256 oldFee = feePercentage;
        feePercentage = newFee;
        emit FeePercentageUpdated(oldFee, newFee);
    }

    // View functions for monitoring
    function getContractStats() external view returns (
        uint256 _totalSupply,
        uint256 _totalStaked,
        uint256 _totalFeesCollected,
        uint256 _contractBalance,
        bool _paused,
        bool _emergencyMode
    ) {
        return (
            totalSupply(),
            totalStaked,
            totalFeesCollected,
            address(this).balance,
            paused(),
            emergencyMode
        );
    }
}