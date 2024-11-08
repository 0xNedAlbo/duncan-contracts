// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {MockArbSys} from "./arbitrum/MockArbSys.sol";
import {BaseTest, console} from "./BaseTest.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IExchangeRouter} from "@src/interfaces/gmx/IExchangeRouter.sol";

import {MintableToken} from "@gmx-synthetics/mock/MintableToken.sol";
import {IReader, Market} from "src/interfaces/gmx/IReader.sol";

contract GmxBaseTest is BaseTest {
    uint256 forkId;

    // Gmx Infrastructure
    IExchangeRouter public exchangeRouter;
    IReader public reader;
    address public datastore;
    address public router;
    address public depositVault;
    address public orderVault;
    Market.Props public btcUsdMarket;

    // Token addresses
    address public USDC;
    address public WBTC;

    // Users
    address public user;
    address public feeReceiver;

    function setUp() public virtual override {
        BaseTest.setUp();
        setUp_gmx();
    }

    function setUp_fork() public virtual override {
        forkId = vm.createSelectFork("http://localhost:8545");

        MockArbSys mockArbSys = new MockArbSys();
        bytes memory bytecode = address(mockArbSys).code;
        vm.etch(0x0000000000000000000000000000000000000064, bytecode);
    }

    function setUp_tokens() public virtual override {
        USDC = gmxContractAddress("USDC");
        WBTC = gmxContractAddress("WBTC");
        vm.label(USDC, "USDC");
        vm.label(WBTC, "WBTC");
    }

    function setUp_users() public virtual override {
        user = vm.addr(1);
        deal(user, 1 ether);
        feeReceiver = vm.addr(2);
        vm.label(user, "User");
        vm.label(feeReceiver, "FeeReceiver");
    }

    function setUp_gmx() public virtual {
        datastore = gmxContractAddress("Datastore");
        reader = IReader(gmxContractAddress("Reader"));
        exchangeRouter = IExchangeRouter(gmxContractAddress("ExchangeRouter"));
        router = gmxContractAddress("Router");
        orderVault = gmxContractAddress("OrderVault");
        btcUsdMarket = gmxFindMarket(USDC, WBTC);

        vm.label(address(exchangeRouter), "ExchangeRouter");
        vm.label(router, "Router");
        vm.label(depositVault, "DepositVault");
        vm.label(orderVault, "OrderVault");
    }

    function mintUsdc(address account, uint256 amount) public {
        MintableToken(USDC).mint(account, amount);
    }

    function mintWbtc(address account, uint256 amount) public {
        MintableToken(WBTC).mint(account, amount);
    }

    function gmxContractAddress(
        string memory contractName
    ) public view returns (address contractAddress) {
        string memory root = vm.projectRoot();
        string memory path = string.concat(
            root,
            "/lib/gmx-synthetics/deployments/localhost/",
            contractName,
            ".json"
        );
        string memory json = vm.readFile(path);
        contractAddress = vm.parseJsonAddress(json, ".address");
    }

    function gmxFindMarket(
        address shortToken,
        address longToken
    ) public view returns (Market.Props memory) {
        require(
            longToken != address(0x0) && shortToken != address(0x0),
            "gmxFindMarket(): zero token address"
        );
        uint256 page = 0;
        address market = address(0x0);
        while (market == address(0x0) && page < 10) {
            Market.Props[] memory markets = reader.getMarkets(datastore, page * 10, 10);
            for (uint256 marketIdx = 0; marketIdx < markets.length; marketIdx++) {
                Market.Props memory marketProps = markets[marketIdx];
                if (marketProps.longToken == longToken && marketProps.shortToken == shortToken) {
                    return marketProps;
                }
            }
        }
        revert("Unable to find gmx market");
    }
}
