// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./Auction.sol";

contract VickreyAuction is Auction {

    uint public minimumPrice;
    uint public biddingDeadline;
    uint public revealDeadline;
    uint public bidDepositAmount;
    mapping(address => bytes32) public commitments;

    // constructor
    constructor(address _sellerAddress,
                            address _judgeAddress,
                            uint _minimumPrice,
                            uint _biddingPeriod,
                            uint _revealPeriod,
                            uint _bidDepositAmount)
             Auction (_sellerAddress, _judgeAddress, address(0), 0) {

        minimumPrice = _minimumPrice;
        bidDepositAmount = _bidDepositAmount;
        biddingDeadline = time() + _biddingPeriod;
        revealDeadline = time() + _biddingPeriod + _revealPeriod;
    }

    // Record the player's bid commitment
    // Make sure exactly bidDepositAmount is provided (for new bids)
    // Bidders can update their previous bid for free if desired.
    // Only allow commitments before biddingDeadline
    function commitBid(bytes32 bidCommitment) public payable {
        require(time() < biddingDeadline, "Bidding period has ended");
        if(commitments[msg.sender] == 0) {
            require(msg.value == bidDepositAmount, "Bid deposit amount is incorrect");
        }
        else {
            require(msg.value == 0, "Bid deposit amount is incorrect");
        }

        commitments[msg.sender] = bidCommitment;

    }

    // Check that the bid (msg.value) matches the commitment.
    // If the bid is correctly opened, the bidder can withdraw their deposit.
    function revealBid(uint nonce) public payable{
        require(time() >= biddingDeadline, "Bidding period has not ended");
        require(time() < revealDeadline, "Reveal period has ended");
        require(sha256(abi.encodePacked(msg.value, nonce)) == commitments[msg.sender], "Bid does not match commitment");

        withdrawable[msg.sender] += bidDepositAmount;

    }

    // Need to override the default implementation
    function getWinner() public override view returns (address winner){

        // TODO: place your code here

    }

    // finalize() must be extended here to provide a refund to the winner
    // based on the final sale price (the second highest bid, or reserve price).
    function finalize() public override {
 
        // TODO: place your code here

        // call the general finalize() logic
        super.finalize();
    }
}
