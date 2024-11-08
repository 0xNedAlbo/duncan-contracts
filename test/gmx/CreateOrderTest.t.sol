// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/src/Test.sol";
import {IERC20, GmxBaseTest, console, IExchangeRouter} from "../GmxBaseTest.t.sol";
import {Errors} from "@src/interfaces/gmx/Errors.sol";
import {CreateOrderParams, CreateOrderParamsAddresses, CreateOrderParamsNumbers, OrderType, DecreasePositionSwapType, PriceProps, SimulatePricesParams} from "@src/interfaces/gmx/IExchangeRouter.sol";
import {IOrderCallbackReceiver, OrderProps, EventUtils} from "@src/interfaces/gmx/IOrderCallbackReceiver.sol";

contract CreateOrderTest is GmxBaseTest {
    function test_openLongPosition() public {
        //uint256 leverage = 6;
        uint256 collateralUsd = 1000 * 1e30;
        uint256 usdcAmount = collateralUsd / 1e24;
        uint256 positionSizeUsd = 600 * 1e30;
        uint256 acceptablePriceUsd = 76000 * 1e22;

        uint256 wethAmount = 1 ether;
        mintUsdc(user, usdcAmount);
        mintEth(user, wethAmount);
        // Send tokens to GMX Order Vault
        vm.startPrank(user);
        IERC20(USDC).approve(address(0x7452c558d45f8afC8c83dAe62C3f8A5BE19c71f6), usdcAmount);
        exchangeRouter.sendTokens(USDC, orderVault, usdcAmount);
        exchangeRouter.sendWnt{value: wethAmount}(orderVault, wethAmount);
        vm.stopPrank();

        CreateOrderCallbackReceiver callback = new CreateOrderCallbackReceiver();

        // Create order params
        CreateOrderParamsAddresses memory addresses = CreateOrderParamsAddresses(
            user, //receiver
            address(0x0), // cancellationReceiver
            address(callback), // callbackContract
            feeReceiver, //
            btcUsdMarket,
            address(USDC), // initialCollateralToken
            new address[](0)
        );
        emit log_named_decimal_uint("collateralUsd", collateralUsd, 30);
        emit log_named_decimal_uint("sizeDeltaUsd", positionSizeUsd, 30);
        emit log_named_decimal_uint("acceptablePriceUsd", acceptablePriceUsd, 22);

        CreateOrderParamsNumbers memory numbers = CreateOrderParamsNumbers(
            positionSizeUsd, // sizeDeltaUsd
            0, // initialCollateralDeltaAmount
            0, // triggerPrice
            acceptablePriceUsd, // acceptablePrice
            wethAmount, // executionFee
            0, // callbackGasLimit
            0 // minOutputAmount
        );
        CreateOrderParams memory params = CreateOrderParams(
            addresses,
            numbers,
            OrderType.MarketIncrease,
            DecreasePositionSwapType.NoSwap,
            true, // isLong
            false, // shouldUnwrapNativeToken,
            false, // autoCancel
            bytes32(0x0) // referralCode
        );

        vm.prank(user);
        bytes32 key = exchangeRouter.createOrder(params);
        emit log_named_bytes32("=> orderKey", key);

        // Simulate order execution.
        address[] memory primaryTokens = new address[](3);
        primaryTokens[0] = WBTC;
        primaryTokens[1] = 0x47904963fc8b2340414262125aF798B9655E58Cd;
        primaryTokens[2] = USDC;
        PriceProps[] memory primaryPrices = new PriceProps[](3);
        primaryPrices[0] = PriceProps(75000 * 1e22, 75001 * 1e22);
        primaryPrices[1] = PriceProps(75000 * 1e22, 75001 * 1e22);
        primaryPrices[2] = PriceProps(0.99999 * 1e22, 1.000001 * 1e22);
        SimulatePricesParams memory pricesParams = SimulatePricesParams({
            primaryTokens: primaryTokens,
            primaryPrices: primaryPrices,
            minTimestamp: block.timestamp,
            maxTimestamp: block.timestamp
        });
        vm.expectRevert(Errors.EndOfOracleSimulation.selector);
        exchangeRouter.simulateExecuteOrder(key, pricesParams);
    }
}

contract CreateOrderCallbackReceiver is IOrderCallbackReceiver, Test {
    bool public afterOrderExecutionCalled = false;
    bool public afterOrderCancellationCalled = false;
    bool public afterOrderFrozenCalled = false;

    function afterOrderExecution(
        bytes32,
        OrderProps memory,
        EventUtils.EventLogData memory
    ) external override {
        emit log_string("afterOrderExecution() called");
        afterOrderExecutionCalled = true;
    }

    function afterOrderCancellation(
        bytes32,
        OrderProps memory,
        EventUtils.EventLogData memory
    ) external override {
        emit log_string("afterOrderCancellation() called");
        afterOrderCancellationCalled = true;
    }

    function afterOrderFrozen(
        bytes32,
        OrderProps memory,
        EventUtils.EventLogData memory
    ) external override {
        emit log_string("afterOrderFrozen() called");
        afterOrderFrozenCalled = true;
    }
}
