// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./Auction.sol";

contract VickreyAuction is Auction {

    struct Bid {
        uint bid;
        address bidder;
    }

    uint public minimumPrice;
    uint public biddingDeadline;
    uint public revealDeadline;
    uint public bidDepositAmount;
    mapping(address => bytes32) public commitments;
    Bid[] public bids;
    
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
        require(keccak256(abi.encodePacked(msg.value, nonce)) == commitments[msg.sender], "Bid does not match commitment");
        require(msg.sender == tx.origin, "Only the bidder can withdraw their deposit");
        commitments[msg.sender] = 0;

        withdrawable[msg.sender] += bidDepositAmount;
        bids.push(Bid(msg.value, msg.sender));

    }

    function getHighestBidder() private view returns (address, uint, uint) {
        require(time() >= revealDeadline, "Reveal period has not ended");
        require(bids.length > 0, "No bids have been made");
        
        uint highestBid = 0;
        uint secondHighestBid = 0;
        address highestBidder= address(0);

        for(uint i = 0; i < bids.length; i++) {
            if(bids[i].bid > highestBid) {
                secondHighestBid = highestBid;
                highestBid = bids[i].bid;
                highestBidder = bids[i].bidder;
            }
            else if(bids[i].bid > secondHighestBid) {
                secondHighestBid = bids[i].bid;
            }
        }
        if(secondHighestBid == 0) {
            secondHighestBid = minimumPrice;
        }
        return (highestBidder, highestBid, secondHighestBid);
    }

    // Need to override the default implementation
    function getWinner() public override view returns (address winner){

        (address highestBidder, uint highestBid, ) = getHighestBidder();

        if(highestBid < minimumPrice) {
            return address(0);
        }
        else {
            return highestBidder;
        }
        
    }

    function refundLosers(address winner) private{
        for(uint i = 0; i < bids.length; i++) {
            if(bids[i].bidder !=winner) {
                withdrawable[bids[i].bidder] += bids[i].bid;
            }
        }
    }

    // finalize() must be extended here to provide a refund to the winner
    // based on the final sale price (the second highest bid, or reserve price).
    function finalize() public override {

        (address highestBidder, uint highestBid, uint secondHighestBid ) = getHighestBidder();

        require(time()> revealDeadline, "Reveal period has not ended");
        require(highestBid >= minimumPrice, "Reserve price has not been met");

        winnerAddress = highestBidder;
        winningPrice = secondHighestBid;
        balances[winnerAddress] += winningPrice;
        withdrawable[winnerAddress] += highestBid - secondHighestBid;
        refundLosers(winnerAddress);


        // call the general finalize() logic
        super.finalize();
    }
}
