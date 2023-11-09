// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./Auction.sol";

contract EnglishAuction is Auction {

    uint public initialPrice;
    uint public biddingPeriod;
    uint public minimumPriceIncrement;
    uint public lastBid;
    uint public highestBid;
    address public highestBidder;

    // constructor
    constructor(address _sellerAddress,
                          address _judgeAddress,
                          uint _initialPrice,
                          uint _biddingPeriod,
                          uint _minimumPriceIncrement)
             Auction (_sellerAddress, _judgeAddress, address(0), 0) {

        initialPrice = _initialPrice;
        biddingPeriod = _biddingPeriod;
        minimumPriceIncrement = _minimumPriceIncrement;
        lastBid = time();
        highestBid = initialPrice;
    }

    function bid() public payable{
        require(time() < lastBid + biddingPeriod, "Bidding period has ended");
        if (highestBid==initialPrice)
            require(msg.value >= highestBid, "Bid value not high enough");
        else
            require(msg.value >= highestBid + minimumPriceIncrement, "Bid value not high enough");

        withdrawable[highestBidder] += highestBid;

        highestBidder = msg.sender;
        highestBid = msg.value;
        lastBid = time();

    }

    // Need to override the default implementation
    function getWinner() public override view returns (address winner){

        if (time() < lastBid + biddingPeriod)
            return address(0);
        else 
            return highestBidder;

    }
}
