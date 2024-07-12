// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract MultiSignWallet {
    //owner列表
    address[] public owners;
    //最小批准数
    uint256 public immutable minRequireCount;
    //是否是owner
    mapping(address => bool) public isOwner;
    //交易结构体
    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        //执行状态
        bool executed;
    }
    //交易列表 index是交易号
    Transaction[] public transactions;

    //批准列表 交易号 => （owner => 批准状态）
    mapping(uint256 => mapping(address => bool)) public approvals;

    //event
    event Deposit(address indexed sender, uint256 amount);
    event Approve(address ownerAddress,uint256 txId);
    event Apply(uint256);
    event Revoke(address ownerAddress,uint256 txId);
    event Execute(uint256);



    //存钱
    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    //初始化
    constructor(address[] memory _owner, uint256 _minRequireCount) {
        require(_owner.length > 0, "owner required");
        //判断传入的最小批准数不能大于owner数
        require(_owner.length >= _minRequireCount, "_minRequireCount is valid");

        for (uint256 i = 0; i < _owner.length; i++) {
            //校验地址是否合法
            require(_owner[i] != address(0), "owner is not zero");
            //校验是否有重复的owner
            require(!isOwner[_owner[i]], "owner is not unique");
            isOwner[_owner[i]] = true;
            owners.push(_owner[i]);
        }
        minRequireCount = _minRequireCount;
    }

    //当前用户是owner角色
    modifier onlyOwner() {
        require(isOwner[msg.sender], "Only Owner");
        _;
    }

    //交易存在校验
    modifier txExists(uint256 txId) {
        require(txId < transactions.length, "tx is not exists");
        _;
    }

    //当前审批员未审批
    modifier notArroved(uint256 txId) {
        require(!approvals[txId][msg.sender], "this tx is already approved");
        _;
    }

    //交易未执行
    modifier notExecuted(uint256 txId) {
        require(transactions[txId].executed == false, "tx is executed");
        _;
    }

    //申请交易
    function applyTransaction(address _to,uint256 _value,bytes calldata _data)
    external 
    onlyOwner
    returns (uint256 txId) //返回交易号
    {
        transactions.push(Transaction({to:_to,value:_value,data:_data,executed:false}));
        txId = transactions.length - 1;
        emit Apply(txId);
    }



    //审批操作
    function approve(uint256 txId)
        external 
        onlyOwner 
        txExists(txId) 
        notArroved(txId) 
        notExecuted(txId)
    {
        approvals[txId][msg.sender] = true;
        emit Approve(msg.sender,txId);
    }

    //获取已批准的数量
    function approveCount(uint256 txId) public view returns (uint256) {
        uint256 count = 0;
        for (uint256 i = 0; i < owners.length; i++) {
            if (approvals[txId][owners[i]]) {
                count += 1;
            }
        }
        return count;
    }

    //取消审批
    function revoke(uint256 txId)
    external 
    onlyOwner
    txExists(txId)
    notExecuted(txId)
    {
        //校验下是否已经被批准了，如果没有则无需操作
        require(approvals[txId][msg.sender],"tx is not approved");
        approvals[txId][msg.sender] = false;
        emit Revoke(msg.sender,txId);

    }

    //执行
    function excute(uint256 txId)
    external 
    onlyOwner
    txExists(txId)
    notExecuted(txId)
    {
        require(approveCount(txId) >= minRequireCount,"approve count is less than minRequireCount");
        Transaction storage transaction = transactions[txId];
        transaction.executed = true;
        (bool status,) = transaction.to.call{value:transaction.value}(transaction.data);
        require(status ,"transaction failed");
        emit Execute(txId);

    }


}
