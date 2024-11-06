// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {MockArbSys} from "./arbitrum/MockArbSys.sol";
import {BaseTest, console} from "./BaseTest.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IExchangeRouter} from "@src/interfaces/gmx/IExchangeRouter.sol";
import {IReader} from "@src/interfaces/gmx/IReader.sol";

contract GmxBaseTest is BaseTest {
    uint256 forkId;

    // Gmx Infrastructure
    IExchangeRouter public exchangeRouter;
    IReader public reader;
    address public datastore;
    address public router;
    address public depositVault;
    address public orderVault;
    address public btcUsdMarket;

    // Token addresses
    address public USDC;

    // Users
    address public user;
    address public feeReceiver;

    function setUp() public virtual override {
        BaseTest.setUp();
        setUp_gmx();
    }

    function setUp_fork() public virtual override {
        string memory rpcUrl = vm.envString("ARBITRUM_RPC_URL");
        forkId = vm.createSelectFork(rpcUrl);

        MockArbSys mockArbSys = new MockArbSys();
        bytes memory bytecode = address(mockArbSys).code;
        vm.etch(0x0000000000000000000000000000000000000064, bytecode);
    }

    function setUp_tokens() public virtual override {
        USDC = 0xaf88d065e77c8cC2239327C5EDb3A432268e5831;
        vm.label(USDC, "USDC");
    }

    function setUp_users() public virtual override {
        user = address(1);
        deal(user, 1 ether);
        feeReceiver = address(2);
        vm.label(user, "User");
        vm.label(feeReceiver, "FeeReceiver");
    }

    function setUp_gmx() public virtual {
        datastore = 0xFD70de6b91282D8017aA4E741e9Ae325CAb992d8;
        reader = IReader(0x23D4Da5C7C6902D4C86d551CaE60d5755820df9E);
        exchangeRouter = IExchangeRouter(0x69C527fC77291722b52649E45c838e41be8Bf5d5);
        router = 0x7452c558d45f8afC8c83dAe62C3f8A5BE19c71f6;
        depositVault = 0xF89e77e8Dc11691C9e8757e84aaFbCD8A67d7A55;
        orderVault = 0x31eF83a530Fde1B38EE9A18093A333D8Bbbc40D5;
        btcUsdMarket = 0x47c031236e19d024b42f8AE6780E44A573170703;

        vm.label(address(exchangeRouter), "ExchangeRouter");
        vm.label(router, "Router");
        vm.label(depositVault, "DepositVault");
        vm.label(orderVault, "OrderVault");
    }

    function mintUsdc(address account, uint256 amount) public {
        uint256 balance = IERC20(USDC).balanceOf(account);
        deal(USDC, account, balance + amount);
    }
}
