// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error FundMe__NotOwner();
error FundMe__DidntSendEnough();
error FundMe__Failedtowithdrawfunds();

contract FundMe {
    using PriceConverter for uint256;

    mapping(address => uint256) private s_addressToAmountFunded;
    address[] private s_funders;
    address private immutable i_owner;
    AggregatorV3Interface private s_priceFeed;
    uint256 public constant MINIMUM_USD = 50 * 10 ** 18;

    modifier onlyOwner() {
        if (msg.sender != i_owner) {
            revert FundMe__NotOwner();
        }
        _;
    }

    constructor(address _priceFeedAddress) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(_priceFeedAddress);
    }

    function fund() public payable {
        if (msg.value.getconversionRate(s_priceFeed) < MINIMUM_USD) {
            revert FundMe__DidntSendEnough();
        }
        s_addressToAmountFunded[msg.sender] += msg.value;
        s_funders.push(msg.sender);
    }

    function withdraw() public onlyOwner {
        for (uint256 funderIndex = 0; funderIndex < s_funders.length; funderIndex++) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);

        (bool success,) = payable(msg.sender).call{value: address(this).balance}("");
        // require(success, "Failed to withdraw funds");
        if (!success) {
            revert FundMe__Failedtowithdrawfunds();
        }
    }

    function cheaperWithdraw() public payable onlyOwner {
        address[] memory funders = s_funders;

        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }

        s_funders = new address[](0);

        (bool success,) = payable(msg.sender).call{value: address(this).balance}("");
        if (!success) {
            revert FundMe__Failedtowithdrawfunds();
        }
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getFunder(uint256 _funderIndex) public view returns (address) {
        return s_funders[_funderIndex];
    }

    function getAddressToAmountFunded(address _address) public view returns (uint256) {
        return s_addressToAmountFunded[_address];
    }

    function getPriceFeedAddress() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }
}
