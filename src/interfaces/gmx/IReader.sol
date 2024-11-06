// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

struct MarketProps {
    address marketToken;
    address indexToken;
    address longToken;
    address shortToken;
}

interface IReader {
    function getMarkets(address dataStore, uint256 start, uint256 end) external view returns (MarketProps[] memory);
}
