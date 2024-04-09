pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {EmailOracle} from "../src/EmailOracle.sol";
import {TheFund} from "../src/TheFund.sol";

contract DeploySimpleStorage is Script {
    function run() external returns (EmailOracle) {
        //initializations of variables should go before startBroadcast
        vm.startBroadcast(); //everything inbetween these are transactions

        // Deploy EmailOracle without TheFund address
        EmailOracle emailOracle = new EmailOracle(address(0));

        // Deploy TheFund with EmailOracle address
        TheFund theFund = new TheFund(address(emailOracle));

        // Update EmailOracle with TheFund address
        emailOracle.setTheFundAddress(address(theFund));

        vm.stopBroadcast();
        return emailOracle;
    }
}