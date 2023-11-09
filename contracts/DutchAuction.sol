// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./Auction.sol";

contract DutchAuction is Auction {

    uint public initialPrice;
    uint public biddingPeriod;
    uint public offerPriceDecrement;
    uint public startTime;

    // constructor
    constructor(address _sellerAddress,
                          address _judgeAddress,
                          uint _initialPrice,
                          uint _biddingPeriod,
                          uint _offerPriceDecrement)
             Auction (_sellerAddress, _judgeAddress, address(0), 0) {

        initialPrice = _initialPrice;
        biddingPeriod = _biddingPeriod;
        offerPriceDecrement = _offerPriceDecrement;
        startTime = time();
    }

    function getPrice() public view returns (uint price) {

        if (time()>=startTime+biddingPeriod)
            return 0;
        else
            return initialPrice - offerPriceDecrement*(time()-startTime);
    }

    function bid() public payable{

        require(time()<startTime+biddingPeriod, "Bidding period has ended");
        require(msg.value>=getPrice(), "Bid value is invalid");

    }

}
