// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20, GmxBaseTest, console, IExchangeRouter} from "../GmxBaseTest.t.sol";

import {Order, IBaseOrderUtils} from "@src/interfaces/gmx/IExchangeRouter.sol";

import {UD60x18, ud, intoUint256} from "@prb/math/src/UD60x18.sol";

contract CreateOrderTest is GmxBaseTest {
    function test_createOrder() public {
        uint256 usdcAmount = 100000000;
        uint256 wethAmount = 86904363000000;
        mintUsdc(user, usdcAmount);
        mintEth(user, wethAmount);
        // Send tokens to GMX Order Vault
        vm.startPrank(user);
        IERC20(USDC).approve(address(0x7452c558d45f8afC8c83dAe62C3f8A5BE19c71f6), usdcAmount);
        exchangeRouter.sendTokens(USDC, orderVault, usdcAmount);
        exchangeRouter.sendWnt{value: wethAmount}(orderVault, wethAmount);
        vm.stopPrank();

        // Create order params
        IBaseOrderUtils.CreateOrderParamsAddresses memory addresses = IBaseOrderUtils.CreateOrderParamsAddresses(
            user, //receiver
            address(0x0), // cancellationReceiver
            address(0x0), //callbackContract
            0xff00000000000000000000000000000000000001, //
            btcUsdMarket,
            address(USDC), // initialCollateralToken
            new address[](0)
        );
        IBaseOrderUtils.CreateOrderParamsNumbers memory numbers = IBaseOrderUtils.CreateOrderParamsNumbers(
            597449487298891841484000000000000, // sizeDeltaUsd
            0, // initialCollateralDeltaAmount
            0, // triggerPrice
            706238670482152412942752995, // acceptablePrice
            86904363000000, // executionFee
            0, // callbackGasLimit
            0 // minOutputAmount
        );
        IBaseOrderUtils.CreateOrderParams memory params = IBaseOrderUtils.CreateOrderParams(
            addresses,
            numbers,
            Order.OrderType.MarketIncrease,
            Order.DecreasePositionSwapType.NoSwap,
            true, // isLong
            false, // shouldUnwrapNativeToken,
            false, // autoCancel
            bytes32(0x0) // referralCode
        );

        vm.prank(user);
        exchangeRouter.createOrder(params);
    }
}
