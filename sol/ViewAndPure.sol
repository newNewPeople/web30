// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract ViewAndPure {
    uint256 public x = 1;

    // Promise not to modify the state.
    // view 修饰符表明这个函数承诺不会修改合约的状态
    function addToX(uint256 y) public view returns (uint256) {
        return x + y;
    }

    // Promise not to modify or read from the state.
    // pure 修饰符表明这个函数承诺既不会修改也不会读取合约的状态
    function add(uint256 i, uint256 j) public pure returns (uint256) {
        return i + j;
    }
}