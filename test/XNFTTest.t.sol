// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {CCIPLocalSimulatorFork, Register} from "@chainlink/local/src/ccip/CCIPLocalSimulatorFork.sol";

import {XNFT} from "../src/XNFT.sol";
import {EncodeExtraArgs} from "./utils/EncodeExtraArgs.sol";

contract XNFTTest is Test {
    CCIPLocalSimulatorFork public ccipLocalSimulatorFork;
    uint256 ethSepoliaFork;
    uint256 arbSepoliaFork;
    Register.NetworkDetails ethSepoliaNetworkDetails;
    Register.NetworkDetails arbSepoliaNetworkDetails;

    address alice;
    address bob;

    XNFT public ethSepoliaXNFT;
    XNFT public arbSepoliaXNFT;

    EncodeExtraArgs public encodeExtraArgs;

    function setUp() public {
        alice = makeAddr("alice");
        bob = makeAddr("bob");

        string memory ETHEREUM_SEPOLIA_RPC_URL = vm.envString("ETHEREUM_SEPOLIA_RPC_URL");
        string memory ARBITRUM_SEPOLIA_RPC_URL = vm.envString("ARBITRUM_SEPOLIA_RPC_URL");
        ethSepoliaFork = vm.createSelectFork(ETHEREUM_SEPOLIA_RPC_URL);
        arbSepoliaFork = vm.createFork(ARBITRUM_SEPOLIA_RPC_URL);

        ccipLocalSimulatorFork = new CCIPLocalSimulatorFork();
        vm.makePersistent(address(ccipLocalSimulatorFork));

        // 步骤 1) 在Ethereum Sepolia网络中部署XNFT.sol
        assertEq(vm.activeFork(), ethSepoliaFork);

        ethSepoliaNetworkDetails = ccipLocalSimulatorFork.getNetworkDetails(block.chainid); // 目前我们处于Ethereum Sepolia的分叉网络中
        assertEq(
            ethSepoliaNetworkDetails.chainSelector,
            16015286601757825753,
            "Sanity check: Ethereum Sepolia chain selector should be 16015286601757825753"
        );

        ethSepoliaXNFT = new XNFT(
            ethSepoliaNetworkDetails.routerAddress,
            ethSepoliaNetworkDetails.linkAddress,
            ethSepoliaNetworkDetails.chainSelector
        );

        // 步骤 2) 在Arbitrum Sepolia网络中部署XNFT.sol
        vm.selectFork(arbSepoliaFork);
        assertEq(vm.activeFork(), arbSepoliaFork);

        arbSepoliaNetworkDetails = ccipLocalSimulatorFork.getNetworkDetails(block.chainid); // 目前我们处于Arbitrum Sepolia的分叉网络中
        assertEq(
            arbSepoliaNetworkDetails.chainSelector,
            3478487238524512106,
            "Sanity check: Arbitrum Sepolia chain selector should be 421614"
        );

        arbSepoliaXNFT = new XNFT(
            arbSepoliaNetworkDetails.routerAddress,
            arbSepoliaNetworkDetails.linkAddress,
            arbSepoliaNetworkDetails.chainSelector
        );
    }

    function testShouldMintNftOnArbitrumSepoliaAndTransferItToEthereumSepolia() public {
        // 步骤 3) 在Ethereum Sepolia网络中, 调用enableChain方法
        vm.selectFork(ethSepoliaFork);
        assertEq(vm.activeFork(), ethSepoliaFork);

        encodeExtraArgs = new EncodeExtraArgs();

        uint256 gasLimit = 200_000;
        bytes memory extraArgs = encodeExtraArgs.encode(gasLimit);
        assertEq(extraArgs, hex"97a657c90000000000000000000000000000000000000000000000000000000000030d40"); // 该值来源于 https://cll-devrel.gitbook.io/ccip-masterclass-3/ccip-masterclass/exercise-xnft#step-3-on-ethereum-sepolia-call-enablechain-function

        ethSepoliaXNFT.enableChain(arbSepoliaNetworkDetails.chainSelector, address(arbSepoliaXNFT), extraArgs);

        // 步骤 4) 在Arbitrum Sepolia网络中, 调用enableChain方法
        vm.selectFork(arbSepoliaFork);
        assertEq(vm.activeFork(), arbSepoliaFork);

        arbSepoliaXNFT.enableChain(ethSepoliaNetworkDetails.chainSelector, address(ethSepoliaXNFT), extraArgs);

        // 步骤 5) 在Arbitrum Sepolia网络中, 向XNFT.sol充值3 LINK
        assertEq(vm.activeFork(), arbSepoliaFork);

        ccipLocalSimulatorFork.requestLinkFromFaucet(address(arbSepoliaXNFT), 3 ether);

        // 步骤 6) 在Arbitrum Sepolia网络中, 增发新的xNFT
        assertEq(vm.activeFork(), arbSepoliaFork);

        vm.startPrank(alice);

        arbSepoliaXNFT.mint();
        uint256 tokenId = 0;
        assertEq(arbSepoliaXNFT.balanceOf(alice), 1);
        assertEq(arbSepoliaXNFT.ownerOf(tokenId), alice);

        // 步骤 7) 在Arbitrum Sepolia网络中, 跨链转移xNFT
        arbSepoliaXNFT.crossChainTransferFrom(
            address(alice), address(bob), tokenId, ethSepoliaNetworkDetails.chainSelector, XNFT.PayFeesIn.LINK
        );

        vm.stopPrank();

        assertEq(arbSepoliaXNFT.balanceOf(alice), 0);

        // 在Ethereum Sepolia中验证xNFT已成功跨链转移
        ccipLocalSimulatorFork.switchChainAndRouteMessage(ethSepoliaFork); // 这行代码将更换CHAINLINK CCIP DONs, 不要遗漏
        assertEq(vm.activeFork(), ethSepoliaFork);

        assertEq(ethSepoliaXNFT.balanceOf(bob), 1);
        assertEq(ethSepoliaXNFT.ownerOf(tokenId), bob);
    }
}
