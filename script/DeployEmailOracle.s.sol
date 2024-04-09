pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {EmailOracle} from "../src/EmailOracle.sol";

contract DeploySimpleStorage is Script {
    function run() external returns (EmailOracle) {
        //initializations of variables should go before startBroadcast
        vm.startBroadcast(); //everything inbetween these are transactions

        EmailOracle emailOracle = new EmailOracle(); //deploys contract

        vm.stopBroadcast();
        return emailOracle;
    }
}