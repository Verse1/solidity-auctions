// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import "hardhat/console.sol";

contract Auction {

    address internal judgeAddress;
    address internal timerAddress;
    address internal sellerAddress;
    address internal winnerAddress;
    uint winningPrice;
    bool finalized;
    mapping(address => uint) balances;
    mapping(address => uint) withdrawable;

    // constructor
    constructor(address _sellerAddress,
                address _judgeAddress,
                address _winnerAddress,
                uint _winningPrice) payable {

        judgeAddress = _judgeAddress;
        sellerAddress = _sellerAddress;
        if (sellerAddress == address(0))
          sellerAddress = msg.sender;
        winnerAddress = _winnerAddress;
        winningPrice = _winningPrice;
        finalized = false;
        balances[winnerAddress] = 0;
        balances[sellerAddress] = 0;
        withdrawable[winnerAddress] = 0;
        withdrawable[sellerAddress] = 0;
        balances[winnerAddress]+=winningPrice;
    }

    // This is used in testing.
    // You should use this instead of block.number directly.
    // You should not modify this function.
    function time() public view returns (uint) {
        return block.number;
    }

    function getWinner() public view virtual returns (address winner) {
        return winnerAddress;
    }

    function getWinningPrice() public view returns (uint price) {
        return winningPrice;
    }

    // If no judge is specified, anybody can call this.
    // If a judge is specified, then only the judge or winning bidder may call.
    function finalize() public virtual {
        require(!finalized, "Auction already finalized");
        require(getWinner() != address(0), "Auction not complete");
        if (judgeAddress != address(0)) {
            require(msg.sender == judgeAddress || msg.sender == winnerAddress, "Only judge or winner can finalize");
        }
        finalized = true;
        balances[winnerAddress]-=winningPrice;
        withdrawable[sellerAddress]+=winningPrice;
    }

    // This can ONLY be called by seller or the judge (if a judge exists).
    // Money should only be refunded to the winner.
    function refund() public {
        require(!finalized, "Auction already finalized");
        require(msg.sender == judgeAddress || msg.sender == sellerAddress, "Only judge or seller can refund");
        require(getWinner() != address(0), "Auction not complete");
        require(balances[winnerAddress]>=winningPrice, "Buyer does not have a refund");
        balances[winnerAddress]-=winningPrice;
        withdrawable[winnerAddress]+=winningPrice;
        finalized = true;
    }

    // Withdraw funds from the contract.
    // If called, all funds available to the caller should be refunded.
    // This should be the *only* place the contract ever transfers funds out.
    // Ensure that your withdrawal functionality is not vulnerable to
    // re-entrancy or unchecked-spend vulnerabilities.
    function withdraw() public {
        uint tmp = withdrawable[msg.sender];

        if(tmp > 0){
            withdrawable[msg.sender] = 0;
            balances[msg.sender] = 0;
            (bool success, ) = msg.sender.call{value: tmp}("");
            
            if (!success) {
                withdrawable[msg.sender] = tmp;
                // balances[msg.sender] = tmp2;
                revert("Transfer failed.");
            }
        }
    }

}
