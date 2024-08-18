// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";

contract EncodeExtraArgs {
    // 以下是一个使用存储的简单示例（所有消息使用相同的参数），该示例允许在不升级dapp的情况下添加新选项。
    // 请注意，额外参数是由链种类决定的（比如，gasLimit是EVM特有的等），并且始终向后兼容，即升级是可选择的。
    // 我们可以在链下计算V1 extraArgs：
    //    Client.EVMExtraArgsV1 memory extraArgs = Client.EVMExtraArgsV1({gasLimit: 300_000});
    //    bytes memory encodedV1ExtraArgs = Client._argsToBytes(extraArgs);
    // 如果V2增加了一个退款功能，可按照以下方式计算V2 extraArgs并用新的extraArgs更新存储：
    //    Client.EVMExtraArgsV2 memory extraArgs = Client.EVMExtraArgsV2({gasLimit: 300_000, destRefundAddress: 0x1234});
    //    bytes memory encodedV2ExtraArgs = Client._argsToBytes(extraArgs);
    // 如果不同的消息需要不同的选项，如：gasLimit不同，可以简单地基于(chainSelector, messageType)而不是只基于chainSelector进行存储。

    function encode(uint256 gasLimit) external pure returns (bytes memory extraArgsBytes) {
        Client.EVMExtraArgsV1 memory extraArgs = Client.EVMExtraArgsV1({gasLimit: gasLimit});
        extraArgsBytes = Client._argsToBytes(extraArgs);
    }
}
