// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "ERC721AK/@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title An interface for checking whether an address has a valid kycNFT token
 */
interface IKycValidity {
    /// @dev Check whether a given address has a valid kycNFT token
    /// @param _addr Address to check for tokens
    /// @return valid Whether the address has a valid token
    function hasValidToken(address _addr) external view returns (bool valid);
}

contract KYC is Ownable, IKycValidity {
    mapping(address => bool) public isKYCVerified;

    constructor() Ownable() {}

    /**
     * @dev Adds a user's address to the list of KYC verified users.
     * @param user The address of the user who has passed KYC verification.
     */
    function addKYCVerifiedUser(address user) external onlyOwner {
        isKYCVerified[user] = true;
    }

    /**
     * @dev Removes a user's address from the list of KYC verified users.
     * @param user The address of the user who has not passed KYC verification or has been removed from the list.
     */
    function removeKYCVerifiedUser(address user) external onlyOwner {
        isKYCVerified[user] = false;
    }

    /**
     * @dev Checks if a user has passed KYC verification.
     * @param user The address of the user to check.
     * @return valid The KYC verification status.
     */
    function hasValidToken(address user) external view override returns (bool valid) {
        return isKYCVerified[user];
    }
}
