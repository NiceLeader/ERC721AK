# NFT Smart Contracts with Bulk Mint Discount and KYC Verification

This repository contains smart contracts for an NFT sales system that includes bulk minting discounts and KYC (Know Your Customer) verification. The contracts are designed to optimize gas costs when minting multiple NFTs and efficiently distribute rewards to NFT holders.

## Contracts Overview

### 1. MultiSend Contract
- **Purpose:** Batch multiple transactions into a single operation to optimize gas usage.
- **Functionality:** Allows sending multiple transactions in one go, ensuring all transactions are executed atomically (i.e., if one fails, all are reverted).

### 2. StandardERC721AWithKYC Contract
- **Purpose:** An ERC721A-based NFT contract with integrated sales, bulk minting discounts, and KYC verification.
- **Key Features:**
  - **Sales Management:** 
    - Adjustable NFT pricing.
    - Ability to activate or deactivate the sale.
    - Reserve NFTs for the owner.
    - Set a maximum supply of NFTs.
    - Implement a wallet limit for NFT purchases.
  - **KYC Verification:** 
    - Users must pass KYC verification before minting NFTs.
  - **Bulk Minting:** 
    - Reduces gas costs when minting multiple NFTs in one transaction.
  - **Reward Distribution:** 
    - Efficiently distributes rewards to NFT holders using the MultiSend contract.

### Usage

1. **Deploy the Contracts:**
   - Deploy `KYC.sol`.
   - Deploy `MultiSend.sol`.
   - Deploy `StandardERC721AWithKYC.sol` with the addresses of the deployed `KYC` and `MultiSend` contracts.

2. **Mint NFTs:**
   - Ensure users pass KYC verification.
   - Call the `mint` function with the number of NFTs to purchase.

3. **Distribute Rewards:**
   - Send ETH to the deployed `StandardERC721AWithKYC` contract.
   - Call the `distributeRewards` function to distribute ETH to all current NFT holders.

## Contributing

1. Fork the repository.
2. Create a new branch.
3. Make your changes.
4. Open a pull request.

## License

This project is licensed under the MIT License.

## Contact

For any questions or inquiries, please contact me on [Linkedin](https://www.linkedin.com/in/maciej-lewandowski-76b270207/) in or [Telegram](https://t.me/l3d3re)
.
