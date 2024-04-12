pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {EmailOracle} from "../src/EmailOracle.sol";
import {TheFund} from "../src/TheFund.sol";
import {IERC20} from "node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DeploySimpleStorage is Script {
    address linkTokenAddr = 0x779877A7B0D9E8603169DdbD7836e478b4624789;
    address usdcTokenAddr = 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238;

    function run() external returns (EmailOracle) {
        //initializations of variables should go before startBroadcast
        vm.startBroadcast(); //everything inbetween these are transactions

        // Deploy EmailOracle without TheFund address
        EmailOracle emailOracle = new EmailOracle(address(0));

        // Deploy TheFund with EmailOracle address
        TheFund theFund = new TheFund(address(emailOracle));

        // Update EmailOracle with TheFund address
        emailOracle.setTheFundAddress(address(theFund));

        uint256 amountToSendLink = 0.4 ether; //0.5 LINK
        IERC20 linkToken = IERC20(linkTokenAddr);
        linkToken.transfer(address(emailOracle), amountToSendLink);

        // uint256 amountToSendUSDC = 1000000; //1 USDC
        // IERC20 usdcToken = IERC20(usdcTokenAddr);
        // usdcToken.transfer(address(theFund), amountToSendUSDC);

        vm.deal(address(theFund), 0.05 ether);
        (bool sent,) = address(theFund).call{value: 0.05 ether}("");
        require(sent, "Failed to send Ether");

        vm.stopBroadcast();
        return emailOracle;
    }
}