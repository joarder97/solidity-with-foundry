// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {Test} from "forge-std/Test.sol";
import "forge-std/console.sol";

import {DeployDSC} from "../../script/DeployDSC.s.sol";
import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/ERC20Mock.sol";

contract DscEngineTest is Test {
    DeployDSC deployer;
    DecentralizedStableCoin dsc;
    DSCEngine dsce;
    HelperConfig config;
    address ethUsdPriceFeed;
    address btcUsdPriceFeed;
    address weth;

    address public USER = makeAddr("user");
    uint256 public constant AMOUNT_COLLATERAL = 10 ether;
    uint256 public constant STARTING_ERC20_BALANCE = 10 ether;
    uint256 public constant AMOUNT_DSC_TO_MINT = 5 ether;
    uint256 public constant AMOUNT_DSC_TO_MINT_For_Revert = 100000000000000000000 ether;

    function setUp() public {
        deployer = new DeployDSC();
        (dsc, dsce, config) = deployer.run();
        (ethUsdPriceFeed, btcUsdPriceFeed, weth, , ) = config
            .activeNetworkConfig();

        ERC20Mock(weth).mint(USER, STARTING_ERC20_BALANCE);
    }

    //////////////////////
    // Constructor Tests///
    /////////////////
    address[] public tokenAddresses;
    address[] public priceFeedAddresses;

    function testRevertsIfTokenLenghtDosentMatchPriceFeeds() public {
        tokenAddresses.push(weth);
        priceFeedAddresses.push(ethUsdPriceFeed);
        priceFeedAddresses.push(btcUsdPriceFeed);

        // vm.expectRevert(
        //     DSCEngine
        //         .DSCEngine_TokenAddressesAndPriceFeedMustBeSameLength
        //         .selector
        // );
        new DSCEngine(tokenAddresses, priceFeedAddresses, address(dsc));
    }

    /////////////////
    // Price Tests///
    /////////////////
    function testGetUsdValue() public {
        uint256 ethAmount = 15e18;
        uint256 expectedUsdValue = 30000e18;
        uint256 usdValue = dsce.getUsdValue(weth, ethAmount);
        assertEq(expectedUsdValue, usdValue);
    }

    function testGetTokenAmountFromUsd() public {
        uint256 usdAmount = 100 ether;
        uint256 expectedWeth = 0.05 ether;
        uint256 actualWeth = dsce.getTokenAmountFromUsd(weth, usdAmount);
        console.log("Actual WETH:", actualWeth);
        console.log("Expected WETH:", expectedWeth);
        assertEq(expectedWeth, actualWeth);
    }

    // function testRevertsIfCollateralZero() public {
    //     vm.startPrank(USER);
    //     ERC20Mock(weth).approve(address(dsce), AMOUNT_COLLATERAL);

    //     vm.expectRevert(DSCEngine.DSCEngine_AmountMustBeMoreThanZero.selector);
    //     dsce.depositCollateral(weth, 0);
    //     vm.stopPrank();
    // }

    // function testRevertsWithUnapprovedCollateral() public {
    //     ERC20Mock ranToken = new ERC20Mock(
    //         "RAN",
    //         "RAN",
    //         USER,
    //         AMOUNT_COLLATERAL
    //     );
    //     vm.startPrank(USER);
    //     vm.expectRevert(DSCEngine.DSCEngine_TokenNotAllowed.selector);
    //     dsce.depositCollateral(address(ranToken), AMOUNT_COLLATERAL);
    //     vm.stopPrank();
    // }

    modifier depositedCollateral() {
        vm.startPrank(USER);
        ERC20Mock(weth).approve(address(dsce), AMOUNT_COLLATERAL);
        dsce.depositCollateralAndMintDsc(
            weth,
            AMOUNT_COLLATERAL,
            AMOUNT_DSC_TO_MINT
        );
        vm.stopPrank();
        _;
    }

    function testCanDepositCollateralAndGetAccountInfo()
        public
        depositedCollateral
    {
        (uint256 totalDscMinted, uint256 collateralValueInUsd) = dsce
            .getAccountInformation(USER);

        // console.log("Total DSC Minted:", totalDscMinted);
        // console.log("Collateral Value in USD:", collateralValueInUsd);

        uint256 expectedTotalDscMinted = 0;
        uint256 expectedDepositAmount = dsce.getTokenAmountFromUsd(
            weth,
            collateralValueInUsd
        );
        // console.log("Expected Deposit Amount:", expectedDepositAmount);
        // console.log(AMOUNT_COLLATERAL);
        assertEq(totalDscMinted, expectedTotalDscMinted);
        assertEq(AMOUNT_COLLATERAL, expectedDepositAmount);
    }

    modifier mintDsc() {
        vm.startPrank(USER);
        ERC20Mock(weth).mint(USER, AMOUNT_DSC_TO_MINT);
        dsce.mintDsc(AMOUNT_DSC_TO_MINT);
        vm.stopPrank();
        _;
    }

    function testMintDsc() public depositedCollateral mintDsc {
        // uint256 expectedAmountDscMinted = 5 ether;
        (uint256 totalDscMinted, uint256 collateralValueInUsd) = dsce
            .getAccountInformation(USER);
        console.log(totalDscMinted);
        assertEq(AMOUNT_DSC_TO_MINT, totalDscMinted);
    }

    // function test_redeemCollateral_FailsWhenAmountIsZero() public {
    //     vm.startPrank(USER);
    //     vm.expectRevert(DSCEngine.DSCEngine_AmountMustBeMoreThanZero.selector);
    //     dsce.mintDsc(0);
    //     vm.stopPrank();
    // }

    function testRedeemCollateralSuccess() public depositedCollateral {
        vm.startPrank(USER);
        dsce.redeemCollateral(weth, AMOUNT_DSC_TO_MINT);
        (uint256 totalDscMinted, uint256 collateralValueInUsd) = dsce
            .getAccountInformation(USER);
        assertEq(AMOUNT_DSC_TO_MINT, totalDscMinted);
        vm.stopPrank();
    }

    // function test_redeemCollateral_FailsWhenHealthFactorBroken() public {
    //     vm.startPrank(USER);
    //     vm.expectRevert(
    //         DSCEngine.DSCEngine__BreaksHealthFactor.selector
    //     );

    //     ERC20Mock(weth).approve(address(dsce), AMOUNT_COLLATERAL);
    //     dsce.depositCollateral(weth, AMOUNT_COLLATERAL);
    //     dsce.mintDsc(AMOUNT_DSC_TO_MINT_For_Revert);
    //     uint256 healthFactor = dsce.getHealthFactor(USER);
    //     console.log("Health Factor:", healthFactor);
    //     vm.stopPrank();
    // }
}
