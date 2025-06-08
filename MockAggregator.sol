// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MockAggregator {
    int256 private latestPrice = 2000 * 10**8; // Assume $2000 with 8 decimals
    
    function latestRoundData() external view returns (
        uint80 roundID,
        int256 answer,
        uint256 startedAt,
        uint256 timeStamp,
        uint80 answeredInRound
    ) {
        return (1, latestPrice, block.timestamp, block.timestamp, 1);
    }

    function setPrice(int256 _price) external {
        latestPrice = _price;
    }
}
