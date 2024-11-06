// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IArbSys} from "./IArbSys.sol";

contract MockArbSys is IArbSys {
    function arbBlockNumber() external view override returns (uint256) {
        return block.number;
    }

    function arbBlockHash(uint256 arbBlockNum) external view override returns (bytes32) {
        return blockhash(arbBlockNum);
    }

    function arbChainID() external pure override returns (uint256) {
        return 42161;
    }

    function arbOSVersion() external pure override returns (uint256) {
        return 87;
    }

    function getStorageGasAvailable() external pure override returns (uint256) {
        return 0;
    }

    function isTopLevelCall() external pure override returns (bool) {
        return true;
    }

    function mapL1SenderContractAddressToL2Alias(
        address /* sender */,
        address /* unused */
    ) external pure override returns (address) {
        return address(0);
    }

    function wasMyCallersAddressAliased() external pure override returns (bool) {
        return false;
    }

    function myCallersAddressWithoutAliasing() external pure override returns (address) {
        return address(0);
    }

    function withdrawEth(address /* destination */) external payable override returns (uint256) {
        return 0;
    }

    function sendTxToL1(
        address /* destination */,
        bytes calldata /* data */
    ) external payable override returns (uint256) {
        return 0;
    }

    function sendMerkleTreeState()
        external
        pure
        override
        returns (uint256 size, bytes32 root, bytes32[] memory partials)
    {
        size = 0;
        root = bytes32(0);
        partials = new bytes32[](0);
    }
}
