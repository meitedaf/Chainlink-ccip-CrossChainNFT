// script/XNFTArbitrum.s.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {XNFT} from "../src/XNFT.sol";

contract DeployXNFTArbitrum is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address ccipRouterAddressArbitrumSepolia = 0x2a9C5afB0d0e4BAb2BCdaE109EC4b0c4Be15a165;
        address linkTokenAddressArbitrumSepolia = 0xb1D4538B4571d411F07960EF2838Ce337FE1E80E;
        uint64 chainSelectorArbitrumSepolia = 3478487238524512106;

        XNFT xNft =
            new XNFT(ccipRouterAddressArbitrumSepolia, linkTokenAddressArbitrumSepolia, chainSelectorArbitrumSepolia);

        console.log("XNFT deployed to ", address(xNft));

        vm.stopBroadcast();
    }
}
