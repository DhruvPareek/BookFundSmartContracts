pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {EmailOracle} from "../src/EmailOracle.sol";
import {TheFund} from "../src/TheFund.sol";
import {IERC20} from "node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";

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

        uint256 amountToSendLink = 0.5 ether; //0.5 LINK
        IERC20 linkToken = IERC20(0x779877A7B0D9E8603169DdbD7836e478b4624789);
        linkToken.transfer(address(emailOracle), amountToSendLink);

        vm.stopBroadcast();
        return emailOracle;
    }
}