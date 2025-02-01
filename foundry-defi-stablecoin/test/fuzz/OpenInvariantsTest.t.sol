// SPDX-License-Identifier: MIT

import {Test} from "forge-std/Test.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {deployDSC} from "../../script/DeployDSC.s.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
impoer {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract InvariantsTest is StdInvariant, Test {
    deployDSC deployer;
    DSCEngine dsce;
    DecentralizedStableCoin dsc;
    HelperConfig config;

    function setup() external {
        deployer = new deployDSC();
        (dsc, dsce, config) = deployer.run();
        targetContract(address(dsce));
    }

}