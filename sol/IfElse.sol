// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract IfElse {
    // 定义一个纯函数 foo，接收一个 uint256 类型的参数 x，并返回一个 uint256 类型的值
    function foo(uint256 x) public pure returns (uint256) {
        if (x < 10) {
            return 0;
        } else if (x < 20) {
            return 1;
        } else {
            return 2;
        }
    }

    // 定义一个纯函数 ternary，接收一个 uint256 类型的参数 _x，并返回一个 uint256 类型的值
    function ternary(uint256 _x) public pure returns (uint256) {
        // 下面是普通的 if-else 写法注释
        // if (_x < 10) {
        //     return 1;
        // }
        // return 2;

        // shorthand way to write if / else statement
        // the "?" operator is called the ternary operator
        // 这是编写 if / else 语句的简写方式
        // "?" 运算符被称为三元运算符
        return _x < 10 ? 1 : 2;
    }
}