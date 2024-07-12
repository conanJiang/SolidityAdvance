// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract TodoList {
    struct Task {
        string taskName;
        bool isCompleted;
    }

    mapping(uint256 => Task) taskLists;
    //Task[] taskArray;

    uint256 index;

    //创建任务
    function createTask(string calldata _taskName) external {
        taskLists[index] = Task({taskName: _taskName, isCompleted: false});
        index++;
    }

    //修改任务名
    function modifyTaskName(uint256 id, string calldata _taskName) external {
        Task storage tt = taskLists[id];
        tt.taskName = _taskName;
    }

    //修改任务状态
    function modifyTaskStatus(uint256 id, bool status) external {
        Task storage tt = taskLists[id];
        tt.isCompleted = status;
    }

    //切换任务状态
    function toggleTaskStatus(uint256 id) external {
        Task storage tt = taskLists[id];
        tt.isCompleted = !tt.isCompleted;
    }

    //获取任务
    function getTask(uint256 id)
        public
        view
        returns (string memory _name, bool _isCompleted)
    {
        Task storage tt = taskLists[id];
        _name = tt.taskName;
        _isCompleted = tt.isCompleted;
    }
}
