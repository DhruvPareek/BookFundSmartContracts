// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "node_modules/@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

interface IOracleEmail {
    function requestPriceData(string memory emailAddress) external returns (bytes32 requestId);
}

contract TheFund is Ownable {
    using SafeERC20 for IERC20;
    address private oracleContractAddr;
    IOracleEmail oracleEmailContract;
    IERC20 usdcToken = IERC20(0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238);

    mapping(string => address) public emailToAddress;

    event Payment(address indexed sender, uint256 amount);
    event Withdraw(address indexed recipient, uint256 amount);
    event WithdrawERC20(
        address indexed recipient,
        address indexed token,
        uint256 amount
    );

    constructor(address _oracleEmailContractAddr) {
        oracleEmailContract = IOracleEmail(_oracleEmailContractAddr);
        oracleContractAddr = _oracleEmailContractAddr;
    }

    receive() external payable {
        emit Payment(msg.sender, msg.value);
    }

    function getAddr(string calldata _email) external view returns (address) {
        return emailToAddress[_email];
    }

    //I THINK FOR TESTING PURPOSES ONLY
    function setEmailOracleAddress(address _oracleContractAddr) external onlyOwner {
        oracleEmailContract = IOracleEmail(_oracleContractAddr);
        oracleContractAddr = _oracleContractAddr;
    }

    function deposit() external payable {
        emit Payment(msg.sender, msg.value);
    }

    function requestWithdrawal(string memory email) external {
        require(address(this).balance > 0, "No Funds :(");
        emailToAddress[email] = msg.sender;
        oracleEmailContract.requestPriceData(email);
    }

    function withdraw() external onlyOwner {
        //TEMPORARY ONLY FOR TESTING PURPOSES
        uint256 amount = address(this).balance;

        (bool sent, ) = (msg.sender).call{value: amount}("");
        require(sent, "Failed to send Ether");

        emit Withdraw(msg.sender, amount);
    }

    function withdrawTo(string calldata emailAddr, uint256 amount) external {
        require(msg.sender == oracleContractAddr, "Only oracle can grant withdraw");
        address _to = emailToAddress[emailAddr];
        (bool sent, ) = _to.call{value: amount}("");
        require(sent, "Failed to send Ether");


        emit Withdraw(_to, amount);
    }

    //Specifically transferring USDC
    function transferUSDC(
        string calldata emailAddr,
        uint256 _amount
    ) external {
        require(msg.sender == oracleContractAddr, "Only oracle can grant withdraw");
        address _to = emailToAddress[emailAddr];
        usdcToken.safeTransfer(_to, 0.5 ether);
        emit WithdrawERC20(_to, 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238, 0.5 ether);
    }
}