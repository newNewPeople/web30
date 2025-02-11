// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Mapping {
    // Mapping from address to uint
    // 定义一个映射，从地址类型映射到无符号 256 位整数类型
    // 这个映射是公开的，意味着可以从合约外部访问
    mapping(address => uint256) public myMap;

    function get(address _addr) public view returns (uint256) {
        // Mapping always returns a value.
        // 映射总是会返回一个值
        // If the value was never set, it will return the default value.
        // 如果该地址对应的值从未被设置过，它将返回默认值（对于 uint256 类型，默认值是 0）
        return myMap[_addr];
    }

    function set(address _addr, uint256 _i) public {
        // Update the value at this address
        // 更新该地址在映射中对应的值为传入的 _i
        myMap[_addr] = _i;
    }

    function remove(address _addr) public {
        // Reset the value to the default value.
        // 将该地址在映射中对应的值重置为默认值（对于 uint256 类型，默认值是 0）
        delete myMap[_addr];
    }
}

contract NestedMapping {
    // Nested mapping (mapping from address to another mapping)
    // 嵌套映射（从地址类型映射到另一个映射，内层映射是从无符号 256 位整数类型映射到布尔类型）
    mapping(address => mapping(uint256 => bool)) public nested;

    // 定义一个视图函数，用于获取嵌套映射中指定地址和无符号 256 位整数对应的值
    function get(address _addr1, uint256 _i) public view returns (bool) {
        // You can get values from a nested mapping
        // 即使嵌套映射未初始化，你也可以从中获取值
        // even when it is not initialized
        // 若未初始化，将返回布尔类型的默认值（即 false）
        return nested[_addr1][_i];
    }

    // 定义一个公共函数，用于设置嵌套映射中指定地址和无符号 256 位整数对应的值
    function set(address _addr1, uint256 _i, bool _boo) public {
        // 将传入的布尔值 _boo 赋给嵌套映射中对应位置
        nested[_addr1][_i] = _boo;
    }

    // 定义一个公共函数，用于移除嵌套映射中指定地址和无符号 256 位整数对应的值
    function remove(address _addr1, uint256 _i) public {
        // 使用 delete 关键字将该位置的值重置为布尔类型的默认值（即 false）
        delete nested[_addr1][_i];
    }
}