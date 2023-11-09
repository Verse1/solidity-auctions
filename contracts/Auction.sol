// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Auction {

    address internal judgeAddress;
    address internal timerAddress;
    address internal sellerAddress;
    address internal winnerAddress;
    uint winningPrice;
    bool finalized;
    mapping(address => uint) bids;

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
        bids[winnerAddress] = winningPrice;
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
        require(msg.sender == judgeAddress || msg.sender == winnerAddress, "Only judge or buyer can finalize");
        finalized = true;
        bids[winnerAddress]-=winningPrice;
        bids[sellerAddress]+=winningPrice;
    }

    // This can ONLY be called by seller or the judge (if a judge exists).
    // Money should only be refunded to the winner.
    function refund() public {

        // TODO: place your code here

    }

    // Withdraw funds from the contract.
    // If called, all funds available to the caller should be refunded.
    // This should be the *only* place the contract ever transfers funds out.
    // Ensure that your withdrawal functionality is not vulnerable to
    // re-entrancy or unchecked-spend vulnerabilities.
    function withdraw() public {

        //TODO: place your code here

    }

}
