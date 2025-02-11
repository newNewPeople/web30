// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Structs {
    // 定义一个结构体 Todo，用于表示待办事项
    struct Todo {
        // 待办事项的文本描述
        string text;
        // 表示该待办事项是否已完成的布尔值
        bool completed;
    }

    // An array of 'Todo' structs
    // 定义一个 Todo 结构体类型的数组，用于存储多个待办事项
    Todo[] public todos;

    // 定义一个公共函数，用于创建新的待办事项
    function create(string calldata _text) public {
        // 3 ways to initialize a struct
        // 三种初始化结构体的方式

        // 方式一：像调用函数一样初始化结构体
        // - calling it like a function
        todos.push(Todo(_text, false));

        // key value mapping
        // 方式二：使用键值对映射来初始化结构体
        // 同样将一个新的 Todo 结构体实例添加到 todos 数组中
       
        // 方式三：先初始化一个空的结构体，然后再更新其属性
        // 在内存中创建一个 Todo 结构体实例
    
    }

    // Solidity automatically created a getter for 'todos' so
    // Solidity 会自动为公共的状态变量 todos 创建一个 getter 函数
    // you don't actually need this function.
    // 所以实际上你不需要这个函数
    // 定义一个视图函数，用于获取指定索引位置的待办事项信息
    function get(
        uint256 _index
    ) public view returns (string memory text, bool completed) {
        Todo storage todo = todos[_index];
        return (todo.text, todo.completed);
    }

    // update text
    // 定义一个公共函数，用于更新指定索引位置待办事项的文本描述
    function updateText(uint256 _index, string calldata _text) public {
        Todo storage todo = todos[_index];
        todo.text = _text;
    }

    // update completed
    // 定义一个公共函数，用于切换指定索引位置待办事项的完成状态
    function toggleCompleted(uint256 _index) public {
        Todo storage todo = todos[_index];
        todo.completed = !todo.completed;
    }
}