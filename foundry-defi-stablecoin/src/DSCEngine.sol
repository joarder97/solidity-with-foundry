// SPDX-License-Identifier: MIT

// This is considered an Exogenous, Decentralized, Anchored (pegged), Crypto Collateralized low volitility coin

// Layout of Contract:
// version
// imports
// interfaces, libraries, contracts
// errors
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

pragma solidity ^0.8.19;

import {DecentralizedStableCoin} from "./DecentralizedStableCoin.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
/*
 * @title DSCEngine
 * @author Masudul Hasan Joarder
 *
 * The system is designed to be as minimal as possible, and have the tokens maintain a 1 token == $1 peg at all times.
 * This is a stablecoin with the properties:
 * - Exogenously Collateralized
 * - Dollar Pegged
 * - Algorithmically Stable
 *
 * It is similar to DAI if DAI had no governance, no fees, and was backed by only WETH and WBTC.
 *
 * Our DSC system should always be "overcollateralized". At no point, should the value of
 * all collateral < the $ backed value of all the DSC.
 *
 * @notice This contract is the core of the Decentralized Stablecoin system. It handles all the logic
 * for minting and redeeming DSC, as well as depositing and withdrawing collateral.
 * @notice This contract is based on the MakerDAO DSS system
 */

contract DSCEngine is ReentrancyGuard {
    error DSCEngine_AmountMustBeMoreThanZero();
    error DSCEngine_TokenAddressesAndPriceFeedMustBeSameLength();
    error DSCEngine_TokenNotAllowed();
    error DSCEngine_TransferFailed();

    event CollateralDeposited(address indexed user, address indexed token, uint256 amount);

    modifier moreThanZero(uint256 amount) {
        if (amount <= 0) {
            revert DSCEngine_AmountMustBeMoreThanZero();
        }
        _;
    }

    modifier isAllowedToken(address token) {
        revert DSCEngine_TokenNotAllowed();
    }

    mapping(address token => address priceFeed) public s_priceFeed;
    mapping(address user => mapping(address token => uint256 amount)) private s_collateralDeposited;
    mapping(uint256 user => uint256 amount) private s_dscMinted;

    DecentralizedStableCoin private immutable i_dsc;

    constructor(address[] memory tokenAddresses, address[] memory priceFeedAddresses, address dscAddress) {
        if (tokenAddresses.length != priceFeedAddresses.length) {
            revert DSCEngine_TokenAddressesAndPriceFeedMustBeSameLength();
        }

        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            s_priceFeed[tokenAddresses[i]] = priceFeedAddresses[i];
        }
        i_dsc = DecentralizedStableCoin(dscAddress);
    }

    function depositCollateralAndMintDsc() external {}

    /*
    * @param tokenCollateralAddress The address of the token to deposit as collateral
    * @param amountCollateral The amount of the token to deposit as collateral
    */
    function depositCollateral(address tokenCollateralAddress, uint256 amountCollateral)
        external
        moreThanZero(amountCollateral)
        isAllowedToken(tokenCollateralAddress)
        nonReentrant
    {
        s_collateralDeposited[msg.sender][tokenCollateralAddress] += amountCollateral;
        emit CollateralDeposited(msg.sender, tokenCollateralAddress, amountCollateral);
        bool success = IERC20(tokenCollateralAddress).transferFrom(msg.sender, address(this), amountCollateral);
        if (!success) {
            revert DSCEngine_TransferFailed();
        }
    }

    function redeemCollateralForDsc() external {}
    function redeemCollateral() external {}
    function mintDsc(uint256 amountDscToMint) external moreThanZero(amountDscToMint) nonReentrant() {
        s_dscMinted[msg.sender] += amountDscToMint;
         
    }
    function burnDsc() external {}
    function liquidate() external {}
    function getHealthFactor() external view {}
}
