# Chainlink-CCIP-CNFT

## Project Overview

The Chainlink-CCIP-CNFT project demonstrates minting and cross-chain transfer of NFTs using Chainlink's Cross-Chain Interoperability Protocol (CCIP). The project provides scripts to deploy the XNFT contract on test networks such as Ethereum Sepolia and Arbitrum Sepolia, and facilitate the cross-chain transfer of NFTs between these networks. Additionally, Chainlink Local is integrated to simulate cross-chain transactions on forked networks, running 2000x faster than on live test networks, significantly improving development and testing efficiency.

## Directory Structure

```bash
.github/                   # GitHub configuration files
lib/                       # Project dependencies
  ├── ccip/                # Chainlink CCIP dependencies
  ├── chainlink/           # Chainlink contracts
  ├── chainlink-brownie-contracts/  # Chainlink Brownie contracts
  ├── chainlink-local/     # Chainlink Local simulator libraries
  ├── forge-std/           # Forge standard library
  ├── openzeppelin-contracts/ # OpenZeppelin contracts
out/                       # Contract compilation output
script/                    # Script files for deploying XNFT contracts
  ├── EncodeExtraArgs.s.sol   # Script to encode extra cross-chain transaction arguments
  ├── XNFTArbitrum.s.sol      # Script for deploying XNFT contract on Arbitrum Sepolia
  ├── XNFTSepolia.s.sol       # Script for deploying XNFT contract on Ethereum Sepolia
src/                       # Main contract files
  └── XNFT.sol              # XNFT main contract
test/                      # Test files
utils/                     # Utility contracts and test files
  ├── EncodeExtraArgs.sol   # Encoding utility contract
  ├── XNFTTest.t.sol        # Test file for XNFT contract
.env.example                # Environment variables file
.gitignore                 # Git ignore file
.gitmodules                # Git submodules configuration
foundry.toml               # Foundry configuration file
README.md                  # Project documentation
```

## Features Overview

- **NFT Minting and Deployment**: Deploy and mint NFTs via the `XNFT.sol` contract on Ethereum Sepolia and Arbitrum Sepolia test networks.
- **Cross-chain NFT Transfer**: Using Chainlink's CCIP protocol, NFTs can be transferred between the Ethereum Sepolia and Arbitrum Sepolia test networks.
- **Chainlink Local Simulator**: Chainlink Local is integrated to simulate cross-chain transactions on forked networks, enabling faster testing and development.

## Setup

### Prerequisites

Ensure you have the following tools installed:

- **Foundry**: A Solidity development toolkit for testing, compiling, and deploying.

### Clone the Project

First, clone this project locally:

```bash
git clone https://github.com/<your-repo>/chainlink-ccip-cnft.git
cd chainlink-ccip-cnft
```

### Install Dependencies

Install the required dependencies:

```bash
forge install
```

### Configure Environment Variables

Copy the `.env.example` file and rename it to `.env`, then fill in the following values:

```bash
ETHEREUM_SEPOLIA_RPC_URL=<your-ethereum-sepolia-rpc-url>
ARBITRUM_SEPOLIA_RPC_URL=<your-arbitrum-sepolia-rpc-url>
PRIVATE_KEY=<your-private-key>
```

### Compile Contracts

Compile the smart contracts:

```bash
forge build
```

## Usage: Minting NFTs and Cross-Chain Transfers

### 1. Deploy XNFT.sol on Ethereum Sepolia

Prepare the Chain Selector and CCIP Router & LINK Token contract addresses for the Ethereum Sepolia testnet. These can be obtained from [Chainlink's CCIP Documentation](https://docs.chain.link/ccip/supported-networks/v1_2_0/testnet).

Deploy the `XNFT.sol` contract using the following command:

```bash
forge create --rpc-url ethereumSepolia --private-key=$PRIVATE_KEY src/XNFT.sol:XNFT --constructor-args <CCIP_ROUTER_ETHEREUM_SEPOLIA> <LINK_TOKEN_ETHEREUM_SEPOLIA> <CHAIN_SELECTOR_ETHEREUM_SEPOLIA>
```

### 2. Deploy XNFT.sol on Arbitrum Sepolia

Deploy the `XNFT.sol` contract on the Arbitrum Sepolia testnet:

```bash
forge create --rpc-url arbitrumSepolia --private-key=$PRIVATE_KEY src/XNFT.sol:XNFT --constructor-args <CCIP_ROUTER_ARBITRUM_SEPOLIA> <LINK_TOKEN_ARBITRUM_SEPOLIA> <CHAIN_SELECTOR_ARBITRUM_SEPOLIA>
```

### 3. Enable Cross-Chain Transfer on Ethereum Sepolia

In the Ethereum Sepolia network, call the `enableChain` method:

```bash
cast send <XNFT_ADDRESS_ON_ETHEREUM_SEPOLIA> --rpc-url ethereumSepolia --private-key=$PRIVATE_KEY "enableChain(uint64,address,bytes)" <CHAIN_SELECTOR_ARBITRUM_SEPOLIA> <XNFT_ADDRESS_ON_ARBITRUM_SEPOLIA> 0x97a657c90000000000000000000000000000000000000000000000000000000000030d40
```

### 4. Enable Cross-Chain Transfer on Arbitrum Sepolia

In the Arbitrum Sepolia network, call the `enableChain` method:

```bash
cast send <XNFT_ADDRESS_ON_ARBITRUM_SEPOLIA> --rpc-url arbitrumSepolia --private-key=$PRIVATE_KEY "enableChain(uint64,address,bytes)" <CHAIN_SELECTOR_ETHEREUM_SEPOLIA> <XNFT_ADDRESS_ON_ETHEREUM_SEPOLIA> 0x97a657c90000000000000000000000000000000000000000000000000000000000030d40
```

### 5. Fund the XNFT Contract with LINK on Arbitrum Sepolia

Ensure that the XNFT contract on Arbitrum Sepolia is funded with LINK tokens to cover the CCIP transaction fees.

### 6. Mint a New xNFT on Arbitrum Sepolia

Mint a new xNFT on the Arbitrum Sepolia network:

```bash
cast send <XNFT_ADDRESS_ON_ARBITRUM_SEPOLIA> --rpc-url arbitrumSepolia --private-key=$PRIVATE_KEY "mint()"
```

### 7. Cross-Chain Transfer xNFT from Arbitrum Sepolia

To transfer the xNFT cross-chain, use the following command:

- **from**: Your EOA (Externally Owned Account) address
- **to**: The receiving address on the other chain (can be your own address)
- **tokenId**: The ID of the xNFT you wish to transfer
- **destinationChainSelector**: `16015286601757825753` (Ethereum Sepolia Chain Selector)
- **payFeesIn**: `1` (indicating that fees are paid in LINK)

```bash
cast send <XNFT_ADDRESS_ON_ARBITRUM_SEPOLIA> --rpc-url arbitrumSepolia --private-key=$PRIVATE_KEY "crossChainTransferFrom(address,address,uint256,uint64,uint8)" <YOUR_EOA_ADDRESS> <RECEIVER_ADDRESS> 0 16015286601757825753 1
```


## Success! Go to metamask import your NFT and check it!