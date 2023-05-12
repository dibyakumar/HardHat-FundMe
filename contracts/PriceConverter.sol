// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

//Libraries are similar to contracts, but you can't declare any state variable and you can't send ether.
library PriceConverter{
     function getPrice(AggregatorV3Interface priceFeed)  internal  view returns(uint256){
        // ABI 
        // Address 0x694AA1769357215DE4FAC081bf1f309aDC325306
        (,int256 price,,,) = priceFeed.latestRoundData();
        // going to give the price of ether in usd but without decimal
        //209500000000  like this
        // 1ether = 1e18 = 1*10^18 wei
        // msg.value will give the amount in 'wei', so to convert it we will multiply price with 1e10
        return uint256(price*1e10);
    }
    
    function getConversionRate(uint256 ethAmount,AggregatorV3Interface priceFeed) internal view returns(uint256){
        uint256 ethPrice = getPrice(priceFeed);
        uint256 ethAmountInUSD = (ethAmount * ethPrice) / 1e18;
        return ethAmountInUSD;
    }
}