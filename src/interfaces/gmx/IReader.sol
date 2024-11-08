// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Market} from "@gmx-synthetics/market/Market.sol";

interface IReader {
    function getMarkets(
        address dataStore,
        uint256 start,
        uint256 end
    ) external view returns (Market.Props[] memory);
}
