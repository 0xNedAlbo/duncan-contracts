// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {console, Test} from "forge-std/src/Test.sol";

import {IExchangeRouter} from "@src/interfaces/gmx/IExchangeRouter.sol";

abstract contract BaseTest is Test {
    function setUp() public virtual {
        setUp_fork();
        setUp_tokens();
        setUp_users();
    }

    function setUp_fork() public virtual;

    function setUp_users() public virtual;

    function setUp_tokens() public virtual;

    function mintEth(address user, uint256 ethAmount) public {
        uint256 userBalance = user.balance;
        deal(user, userBalance + ethAmount);
    }
}
