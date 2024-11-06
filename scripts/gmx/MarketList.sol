// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/src/Script.sol";

import {IReader, MarketProps} from "@src/interfaces/gmx/IReader.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

contract MarketList is Script {
    IReader reader = IReader(0x23D4Da5C7C6902D4C86d551CaE60d5755820df9E);
    address datastore = 0xFD70de6b91282D8017aA4E741e9Ae325CAb992d8;

    function run() public view {
        MarketProps[] memory markets = reader.getMarkets(datastore, 0, 25);
        for (uint i = 0; i < markets.length; i++) {
            MarketProps memory market = markets[i];
            string memory marketSymbol = IERC20Metadata(market.marketToken).symbol();
            string memory longSymbol = IERC20Metadata(market.longToken).symbol();
            string memory shortSymbol = IERC20Metadata(market.shortToken).symbol();
            console.log("%s-%s/%s", marketSymbol, longSymbol, shortSymbol);
            console.log("%s", market.marketToken);

            console.log("indexToken: ", market.indexToken);
            console.log("longToken:  ", market.longToken);
            console.log("shortToken:  ", market.shortToken);

            console.log(".-.");
        }
    }
}
