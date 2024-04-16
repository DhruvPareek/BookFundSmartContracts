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

    mapping(string => address payable) public emailToAddress;

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

    event USDCdeposit(address indexed sender, uint256 amount);

    function depositUSDC(uint256 amount) external {
        require(usdcToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        emit USDCdeposit(msg.sender, amount);
    }

    function setEmailOracleAddress(address _oracleContractAddr) external onlyOwner {
        oracleEmailContract = IOracleEmail(_oracleContractAddr);
        oracleContractAddr = _oracleContractAddr;
    }

    function claimFunds(string memory emailAddr) external {
        require(usdcToken.balanceOf(address(this)) > 0, "No Funds :(");
        emailToAddress[emailAddr] = payable(msg.sender);
        oracleEmailContract.requestPriceData(emailAddr);
    }

    //Specifically transferring USDC
    function transferUSDC(string calldata emailAddr, uint256 _amount) external {
        require(msg.sender == oracleContractAddr, "Only oracle can grant withdraw");
        address payable _to = emailToAddress[emailAddr];
        usdcToken.safeTransfer(_to, _amount);
        emit WithdrawERC20(_to, 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238, _amount);
    }
}