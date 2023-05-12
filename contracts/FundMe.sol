// Get funds from user
// withdraw funds
// set a minimum funding value in USD

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./PriceConverter.sol";

//custom error
error FundMe__NotOwner();

contract FundMe{

    using PriceConverter for uint256; // here we are attaching the library with uint256
                                    // By this we can call the function by just uint256(data).function();
    /**
        If we dont want to use 'Using for' then we can call the functions using 
        library name e.g
        PriceConverter.getPrice();
    **/
    //1ether = 1e18 = 1*10^18 wei
    // In smart contracts there is no decimal points

    // min usd to fund
    uint256 public constant MIN_USD = 50*1e18; // making it compatible with the conversion amount which would have 18 zero 
    
    address[] public funders;
    mapping(address=>uint256) public addressToAmountFunded;
    
    address public immutable i_owner;
    AggregatorV3Interface public priceFeed;
    //  Constructor
    constructor(address priceFeedAddress){
        i_owner = msg.sender;
        priceFeed = AggregatorV3Interface(priceFeedAddress);
    }


    // getting fund
    function fund() public payable{
        // sending ETH to this contract
        require(msg.value.getConversionRate(priceFeed)>=MIN_USD,"You need to spend more ETH"); // checking whether the condition satisfied or not 
        funders.push(msg.sender); // gives the sender address
        addressToAmountFunded[msg.sender] += msg.value;
    }

    // withdraw money
    // we have to make sure that the owner can only retrive the fund
    /**
        we can use modifier to make sure the withdrwal operation done by the owner .

            Modifiers in Solidity are special functions that modify the behavior of other functions.
         They allow developers to add extra conditions or functionality without having to rewrite the entire function.
    **/
    function withdraw() public onlyOwner{// Here 1st onlyowner modifer going to run
        for(uint256 FundIndex=0;FundIndex<funders.length;FundIndex++){
            addressToAmountFunded[funders[FundIndex]] = 0;
        }

        // reseting the array
        funders = new address[](0);
        //Actual withdraw of funds
        // can be done using 3 ways 

        // transfer
        // transfer 'msg.sender' the balance avialable
        // payable(msg.sender).transfer(address(this).balance); // gas limit 2300 and throw error if fail
        // // send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance); // gas limit 2300 and return false if fail
        // require(sendSuccess,"Send Failed");
        // call
        (bool callSuccess,) = payable(msg.sender).call{value:address(this).balance}("");//no limit of gas
        require(callSuccess,"call Failed");// we can use custom error here
    }

    // Declaring the Modifier
    modifier onlyOwner{
        //  condition for owner
        //require(msg.sender == i_owner,"Sender is not Owner");
        // or we can use a gas efficient method i.e using Custom error
        if(msg.sender != i_owner){
            revert FundMe__NotOwner();
        }
        _; // its saying execute the rest of code (in our case the withdraw() )
    }

    // If someone sends the ether without using the fund()
    /**
        In this case we can use the recive() and fallback();
        
         * receive() is a new function introduced in Solidity version 0.6.0 that is automatically called when a contract receives ether without any data. 
            It is a simple fallback function that does not take any arguments and has no return value.
            It can only be declared once per contract and cannot be overloaded.
        
         * fallback() is a fallback function that is automatically called when a contract receives ether along with some data that does not match any of the contract's function signatures.
             It can be used to implement custom logic to handle unexpected interactions with the contract. 
            It is defined using the fallback keyword and can have either external or public visibility.
    **/
    receive() external payable{
        fund();
    }

    fallback() external payable {
        fund();
    }
   
}