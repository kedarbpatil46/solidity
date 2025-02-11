// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import OpenZeppelin contracts
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/extensions/AccessControlDefaultAdminRules.sol";

contract ReviveToken is ERC20, AccessControlDefaultAdminRules {
    // Role for burning tokens
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    // Treasury wallet address  
    address public treasuryWallet;

    // Constructor to initialize the token
    constructor(
        address _treasuryWallet,
        address adminWallet,
        address burnRoleWallet,
        uint48 adminTransferDelay // Delay in seconds for admin role transfers
    )
        ERC20("ReviveToken", "RVV")
        AccessControlDefaultAdminRules(adminTransferDelay, adminWallet)
    {
        require(
            _treasuryWallet != address(0),
            "Treasury wallet cannot be zero address"
        );
        require(
            adminWallet != address(0),
            "Admin wallet cannot be zero address"
        );
        require(
            burnRoleWallet != address(0),
            "Burn role wallet cannot be zero address"
        );

        // Set the treasury wallet
        treasuryWallet = _treasuryWallet;

        // Mint the total supply to the treasury wallet
        _mint(treasuryWallet, 10_000_000_000 * 10**decimals());

        // Grant roles
        _grantRole(BURNER_ROLE, burnRoleWallet);
    }

    // Function to burn tokens (only callable by addresses with BURNER_ROLE)
    function burn(address to, uint256 amount) public onlyRole(BURNER_ROLE) {
        _burn(to, amount);
    }
}