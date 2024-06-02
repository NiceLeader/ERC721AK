// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "ERC721AK/@openzeppelin/contracts/access/Ownable.sol";
import "ERC721AK/@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "./ERC721A.sol";
import "./KYC.sol";
import "./MultiSend.sol";

/**
 * @title NFT Sale with bulk mint discount and KYC verification
 * @notice NFT, Sale, ERC721, ERC721A, KYC
 * @custom:version 1.0.9
 * @custom:address 15
 * @custom:default-precision 0
 * @custom:simple-description An NFT with a built-in sale that provides bulk minting discounts and KYC verification.
 * When minting multiple NFTs, gas costs are reduced compared to a normal NFT contract.
 * @dev ERC721A NFT with the following features:
 *
 *  - Built-in sale with an adjustable price.
 *  - Reserve function for the owner to mint free NFTs.
 *  - Fixed maximum supply.
 *  - Reduced Gas costs when minting many NFTs at the same time.
 *  - KYC verification for minting NFTs.
 *
 */
contract StandardERC721AWithKYC is ERC721A, Ownable {
    using Address for address payable;

    bool public saleIsActive = true;
    string private _baseURIextended;
    IKycValidity public kycValidity;
    MultiSend public multiSend;

    uint256 public immutable MAX_SUPPLY;
    uint256 public currentPrice;
    uint256 public walletLimit;

    /**
     * @param _name NFT Name
     * @param _symbol NFT Symbol
     * @param _uri Token URI used for metadata
     * @param price Initial Price | precision:18
     * @param maxSupply Maximum # of NFTs
     * @param kycContractAddress Address of the KYC contract
     * @param multiSendAddress Address of the MultiSend contract
     */
    constructor(
        string memory _name,
        string memory _symbol,
        string memory _uri,
        uint256 price,
        uint256 maxSupply,
        address kycContractAddress,
        address multiSendAddress
    ) ERC721A(_name, _symbol) Ownable() {
        _baseURIextended = _uri;
        currentPrice = price;
        MAX_SUPPLY = maxSupply;
        kycValidity = IKycValidity(kycContractAddress);
        multiSend = MultiSend(multiSendAddress);
    }

    modifier onlyKYCVerified() {
        require(kycValidity.hasValidToken(msg.sender), "User has not passed KYC verification");
        _;
    }

    /**
     * @dev An external method for users to purchase and mint NFTs. Requires that the sale
     * is active, that the minted NFTs will not exceed the `MAX_SUPPLY`, and that a
     * sufficient payable value is sent.
     * @param amount The number of NFTs to mint.
     */
    function mint(uint256 amount) external payable onlyKYCVerified {
        uint256 ts = totalSupply();

        require(saleIsActive, "Sale must be active to mint tokens");
        require(ts + amount <= MAX_SUPPLY, "Purchase would exceed max tokens");
        require(currentPrice * amount == msg.value, "Value sent is not correct");

        _safeMint(msg.sender, amount);
    }

    /**
     * @dev A way for the owner to reserve a specific number of NFTs without having to
     * interact with the sale.
     * @param to The address to send reserved NFTs to.
     * @param amount The number of NFTs to reserve.
     */
    function reserve(address to, uint256 amount) external onlyOwner {
        uint256 ts = totalSupply();
        require(ts + amount <= MAX_SUPPLY, "Purchase would exceed max tokens");
        _safeMint(to, amount);
    }

    /**
     * @dev A way for the owner to withdraw all proceeds from the sale.
     */
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(owner()).sendValue(balance);
    }

    /**
     * @dev Sets whether or not the NFT sale is active.
     * @param isActive Whether or not the sale will be active.
     */
    function setSaleIsActive(bool isActive) external onlyOwner {
        saleIsActive = isActive;
    }

    /**
     * @dev Sets the price of each NFT during the initial sale.
     * @param price The price of each NFT during the initial sale | precision:18
     */
    function setCurrentPrice(uint256 price) external onlyOwner {
        currentPrice = price;
    }

    /**
     * @dev Updates the baseURI that will be used to retrieve NFT metadata.
     * @param baseURI_ The baseURI to be used.
     */
    function setBaseURI(string memory baseURI_) external onlyOwner {
        _baseURIextended = baseURI_;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseURIextended;
    }

    /**
     * @dev Sets a new KYC contract.
     * @param kycContractAddress The address of the new KYC contract.
     */
    function setKYCContractAddress(address kycContractAddress) external onlyOwner {
        kycValidity = IKycValidity(kycContractAddress);
    }

    /**
     * @dev Receive function to accept ETH
     */
    receive() external payable {}

    /**
     * @dev Distribute rewards to current NFT holders using MultiSend to optimize gas usage.
     * @param rewardAmount The total amount of rewards to distribute.
     */
    function distributeRewards(uint256 rewardAmount) external onlyOwner {
        uint256 totalSupply = totalSupply();
        uint256 rewardPerNFT = rewardAmount / totalSupply;

        bytes memory transactions;

        for (uint256 tokenId = 0; tokenId < totalSupply; tokenId++) {
            address owner = ownerOf(tokenId);
            transactions = abi.encodePacked(
                transactions,
                uint8(0), // call operation
                owner,
                rewardPerNFT,
                uint256(0),
                bytes("")
            );
        }

        delegateMultiSend(transactions);
    }

    function delegateMultiSend(bytes memory transactions) internal {
        (bool success, ) = address(multiSend).delegatecall(
            abi.encodeWithSignature("multiSend(bytes)", transactions)
        );
        require(success, "MultiSend failed");
    }
}