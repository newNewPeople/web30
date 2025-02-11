// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Primitives {
    bool public boo = true;

    /*
    uint stands for unsigned integer, meaning non negative integers
    different sizes are available
        uint8   ranges from 0 to 2 ** 8 - 1
        uint16  ranges from 0 to 2 ** 16 - 1
        ...
        uint256 ranges from 0 to 2 ** 256 - 1
    */
    /*
    uint 表示无符号整数（非负整数）
    支持多种位宽类型：
        uint8  范围 0 到 2 ** 8 - 1
        uint16 范围 0 到 2 ** 16 - 1
        ...
        uint256 范围 0 到 2 ** 256 - 1
    */
    uint8 public u8 = 1;
    uint256 public u256 = 456;
    // uint is an alias for uint256
    // uint 是 uint256 的别名
    uint256 public u = 123;

    /*
    Negative numbers are allowed for int types.
    Like uint, different ranges are available from int8 to int256
    
    int256 ranges from -2 ** 255 to 2 ** 255 - 1
    int128 ranges from -2 ** 127 to 2 ** 127 - 1
    */
    /*
    int 类型允许负数
    类似 uint，提供从 int8 到 int256 的不同位宽：
    
    int256 范围 -2 ** 255 到 2 ** 255 - 1
    int128 范围 -2 ** 127 到 2 ** 127 - 1
    */
    int8 public i8 = -1;
    int256 public i256 = 456;
    // int is same as int256
    // int 等同于 int256
    int256 public i = -123;

    // minimum and maximum of int
    // int 类型的最小最大值
    int256 public minInt = type(int256).min;
    int256 public maxInt = type(int256).max;

    address public addr = 0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c;

    /*
    In Solidity, the data type byte represent a sequence of bytes. 
    Solidity presents two type of bytes types :

     - fixed-sized byte arrays
     - dynamically-sized byte arrays.
     
     The term bytes in Solidity represents a dynamic array of bytes. 
     It’s a shorthand for byte[] .
    */
    /*
    Solidity 中 byte 类型表示字节序列
    提供两种字节类型：
    
     - 固定大小字节数组（如 bytes1, bytes2...）
     - 动态大小字节数组
     
    bytes 类型是动态字节数组的简写形式
    等价于 byte[]
    */
    bytes1 a = 0xb5; //  [10110101]
    bytes1 b = 0x56; //  [01010110]

    // Default values
    // Unassigned variables have a default value
    // 默认初始值
    // 未赋值的变量会有默认初始值
    bool public defaultBoo; // false
    uint256 public defaultUint; // 0
    int256 public defaultInt; // 0
    address public defaultAddr; // 0x0000000000000000000000000000000000000000
}