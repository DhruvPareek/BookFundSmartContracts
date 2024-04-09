// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

contract TipJar is Ownable {
    using SafeERC20 for IERC20;
    address private oracleContract = 0xc01b63416c8d29df9424Db486943f99cdD0cFD6f;

    event Payment(address indexed sender, uint256 amount);
    event Withdraw(address indexed recipient, uint256 amount);
    event WithdrawERC20(
        address indexed recipient,
        address indexed token,
        uint256 amount
    );

    receive() external payable {
        emit Payment(msg.sender, msg.value);
    }

    function deposit() external payable {
        emit Payment(msg.sender, msg.value);
    }

    function requestWithdrawal(string memory email) external {
        require(address(this).balance==0, "No funds to disperse :(");

        

        payable(oracleContract).transfer(_amount);
    }

    function withdraw() external onlyOwner {
        //TEMPORARY ONLY FOR TESTING PURPOSES
        uint256 amount = address(this).balance;

        (bool sent, ) = (msg.sender).call{value: amount}("");
        require(sent, "Failed to send Ether");

        emit Withdraw(msg.sender, amount);
    }

    function withdrawTo(address _to, uint256 memory amount) external onlyOwner {

        (bool sent, ) = _to.call{value: amount}("");
        require(sent, "Failed to send Ether");


        emit Withdraw(_to, amount);
    }

//     function transferERC20(
//         address _token,
//         address _to,
//         uint256 _amount
//     ) external onlyOwner {
//         IERC20(_token).safeTransfer(_to, _amount);
//         emit WithdrawERC20(_to, _token, _amount);
//     }
}