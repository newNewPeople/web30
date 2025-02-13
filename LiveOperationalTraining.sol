// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/*
存钱罐合约
- 所有人都可以存钱
  + ETH
- 只有合约 owner 才可以取钱
- 只要取钱，合约就销毁掉 selfdestruct
- 扩展：支持主币以外的资产
  + ERC20
  + ERC721
*/

contract PiggyBank {
    address immutable owner;

    // 存取款事件
    event Deposit(address indexed from, uint256 amount);
    event WithDraw(uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw() external payable {
        require(owner == msg.sender, "Only owner can withdraw!");
        // selfdestruct(payable(owner)); // selfdestruct已废弃
        payable(owner).transfer(address(this).balance);
        emit WithDraw(address(this).balance);
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}

/*
WETH 是包装 ETH 主币，作为 ERC20 的合约。 标准的 ERC20 合约包括如下几个

- 3 个查询
  + balanceOf: 查询指定地址的 Token 数量
  + allowance: 查询指定地址对另外一个地址的剩余授权额度
  + totalSupply: 查询当前合约的 Token 总量
- 2 个交易
  + transfer: 从当前调用者地址发送指定数量的 Token 到指定地址。
    - 这是一个写入方法，所以还会抛出一个 Transfer 事件。
  + transferFrom: 当向另外一个合约地址存款时，对方合约必须调用 transferFrom 才可以把 Token 拿到它自己的合约中。
- 2 个事件
  + Transfer
  + Approval
- 1 个授权
  + approve: 授权指定地址可以操作调用者的最大 Token 数量。
*/
contract WETH {
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed from, address indexed to, uint256 amount);
    event Deposit(address indexed from, uint256 amount);

    // 查询当前合约的 Token 总量
    function totalSupply() public view returns (uint256) {
        return address(this).balance;
    }

    function transfer(address _address, uint256 _amount) public {
        transferFrom(msg.sender, _address, _amount);
    }

    function transferFrom(
        address from,
        address to,
        uint256 _amount
    ) public {
        require(
            balanceOf[from] >= _amount,
            "Insufficient balance in the transfer address"
        );
        if (from != msg.sender) {
            require(
                allowance[from][to] >= _amount,
                "Insufficient remaining authorization amount"
            );
            allowance[from][to] -= _amount;
        }
        balanceOf[from] -= _amount;
        balanceOf[to] += _amount;
        emit Transfer(msg.sender, to, _amount);
    }

    function approve(address _address, uint256 _amount) public {
        allowance[msg.sender][_address] = _amount;
        emit Approval(msg.sender, _address, _amount);
    }

    function deposit() private {
        balanceOf[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    receive() external payable {
        deposit();
    }
}

/*
TodoList: 是类似便签一样功能的东西，记录我们需要做的事情，以及完成状态。 1.需要完成的功能

- 创建任务
- 修改任务名称
  + 任务名写错的时候
- 修改完成状态：
  + 手动指定完成或者未完成
  + 自动切换
    - 如果未完成状态下，改为完成
    - 如果完成状态，改为未完成
获取任务 2.思考代码内状态变量怎么安排？ 
思考 1：思考任务 ID 的来源？ 我们在传统业务里，这里的任务都会有一个任务 ID，在区块链里怎么实现？？ 答：传统业务里，ID 可以是数据库自动生成的，也可以用算法来计算出来的，比如使用雪花算法计算出 ID 等。在区块链里我们使用数组的 index 索引作为任务的 ID，也可以使用自增的整型数据来表示。 
思考 2: 我们使用什么数据类型比较好？ 答：因为需要任务 ID，如果使用数组 index 作为任务 ID。则数据的元素内需要记录任务名称，任务完成状态，所以元素使用 struct 比较好。 如果使用自增的整型作为任务 ID，则整型 ID 对应任务，使用 mapping 类型比较符合。 
3.演示代码
*/
contract TodoList {
    struct Todo {
        string value;
        bool isCompleted;
    }

    Todo[] public todoList;

    function create(string memory _value) external {
        todoList.push(Todo(_value, false));
    }

    function editValue(uint256 _index, string memory _nValue) external {
        require(_index < todoList.length);
        todoList[_index].value = _nValue;
    }

    function changeStatus(uint256 _index, bool _status) external {
        require(_index < todoList.length);
        todoList[_index].isCompleted = _status;
    }

    function get() public view returns (Todo[] memory) {
        return todoList;
    }
}

/*
两种角色:
    受益人   beneficiary => address         => address 类型
    资助者   funders     => address:amount  => mapping 类型 或者 struct 类型

状态变量按照众筹的业务：
  状态变量
    筹资目标数量    fundingGoal
    当前募集数量    fundingAmount
    资助者列表      funders
    资助者人数      fundersKey

需要部署时候传入的数据:
    受益人
    筹资目标数量
*/
contract CrowdFunding {
    address public immutable beneficiary;
    uint256 public immutable fundingGoal;
    uint256 public fundingAmount;
    mapping(address => uint256) public funders;
    address[] public fundersKey;
    bool private available = true; // 是否可以捐款

    event Contribute(address indexed from, uint256 amount);
    event Close(uint256 amount);

    constructor(address _beneficiary, uint256 _fundingGoal) {
        beneficiary = _beneficiary;
        fundingGoal = _fundingGoal;
    }

    function contribute() external payable {
        require(available, "CrowdFunding is closed");
        uint currentFundingAmount = fundingAmount + msg.value; // 本次收款后的金额
        uint refundAmount = 0; // 可能要退款的金额

        if (currentFundingAmount > fundingGoal) {
            // 超过目标金额
            refundAmount = currentFundingAmount - fundingGoal;
            funders[msg.sender] += (msg.value - refundAmount);
            fundingAmount += (msg.value - refundAmount);
            assert(fundingAmount == fundingGoal);
        } else {
            fundingAmount += msg.value;
            if (funders[msg.sender] == 0) fundersKey.push(msg.sender); // 第一次捐款，记录地址
            funders[msg.sender] += msg.value;
        }

        if (refundAmount > 0) {
            payable(msg.sender).transfer(refundAmount); // 退款
        }

        emit Contribute(msg.sender, msg.value);
    }

    function close() external {
        require(available, "CrowdFunding is closed");
        require(fundingAmount >= fundingGoal, "Not enough fundraising"); // 金额未达标
        payable(beneficiary).transfer(fundingAmount);
        available = false;
        fundingAmount = 0;
        emit Close(fundingAmount);
    }
}


/*
这一个实战主要是加深大家对 3 个取钱方法的使用。
- 任何人都可以发送金额到合约
- 只有 owner 可以取款
- 3 种取钱方式
*/
contract EtherWallet {
    address payable public immutable owner;
    mapping(address => uint) public funders;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can withdraw");
        _;
    }

    constructor() {
        owner = payable(msg.sender);
    }

    function withdrawByTransfer() public payable onlyOwner {
        owner.transfer(address(this).balance);
    }

    function withdrawBySend() public payable onlyOwner {
        bool result = owner.send(address(this).balance);
        require(result);
    }

    function withdrawByCall() public payable onlyOwner {
        (bool result, ) = owner.call{value: address(this).balance}("");
        require(result);
    }

    receive() external payable {}
}


/*
多签钱包的功能: 合约有多个 owner，一笔交易发出后，需要多个 owner 确认，确认数达到最低要求数之后，才可以真正的执行。
- 部署时候传入地址参数和需要的签名数
  + 多个 owner 地址
  + 发起交易的最低签名数
- 有接受 ETH 主币的方法，
- 除了存款外，其他所有方法都需要 owner 地址才可以触发
- 发送前需要检测是否获得了足够的签名数
- 使用发出的交易数量值作为签名的凭据 ID（类似上么）
- 每次修改状态变量都需要抛出事件
- 允许批准的交易，在没有真正执行前取消。
- 足够数量的 approve 后，才允许真正执行。
*/
contract MyMultiSigWallet {
    struct Tx {
        uint txId;
        address to;
        uint amount;
        address[] approvedList;
    }

    address[] public ownerList;
    uint public minCount;
    uint public nonce; // 交易数量
    mapping(uint => Tx) txMap;
    

    event Log(string logName, address from, uint amount);

    modifier onlyOwner() {
        bool isOwner = false;
        for (uint i = 0; i < ownerList.length; i++) {
            if (ownerList[i] == msg.sender) {
                isOwner = true;
                break;
            }
        }
        require(isOwner, "Only owner");
        _;
    }

    constructor(address[] memory _ownerList, uint _minCount) {
        ownerList = _ownerList;
        minCount = _minCount;
    }

    receive() external payable {
        emit Log("receive", msg.sender, msg.value);
    }

    // 创建交易
    function createTx(address _to, uint _amount) external onlyOwner {
        nonce++;
        Tx memory newTx;
        newTx.txId = nonce;
        newTx.to = _to;
        newTx.amount = _amount;
        txMap[nonce] = newTx;
        emit Log("createTx", _to, _amount);
    }

    // 签名交易
    function approveTx(uint _txId) external onlyOwner {
        address[] storage _approvedList = txMap[_txId].approvedList;
        for (uint i = 0; i < _approvedList.length; i++) {
            if (msg.sender == _approvedList[i]) revert("Already approve");
        }
        txMap[_txId].approvedList.push(msg.sender);
        emit Log("approveTx", msg.sender, 0);
    }

    // 执行交易
    function executeTx(uint _txId) external onlyOwner {
        Tx storage _tx = txMap[_txId];
        require(_tx.approvedList.length >= minCount, "Insufficient quantity of approve");
        payable(_tx.to).transfer(_tx.amount);
        emit Log("executeTx", _tx.to, _tx.amount);
        delete txMap[_txId];
    }

    //  取消交易
    function cancelTx(uint _txId) external onlyOwner {
        emit Log("cancelTx", txMap[_txId].to, _txId);
        delete txMap[_txId];
    }
}

contract MultiSigWallet {
    address[] public owners;
    mapping(address => bool) public isOwner;
    uint public required;

    struct Transaction {
        address to;
        uint value;
        bytes data;
        bool excuted;
    }

    Transaction[] public transactions;
    mapping(uint => mapping(address => bool)) approved;

    event Deposit(address indexed from, uint amount);
    event Submit(uint indexed txId);
    event Approve(address indexed from, uint indexed txId);
    event Revoke(address indexed from, uint indexed txId);
    event Execute(uint indexed txId);

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    modifier onlyOwner() {
        require(isOwner[msg.sender], "Only Owner");
        _;
    }

    modifier txExists(uint _txId) {
        require(_txId < transactions.length, "tx isn't exist");
        _;
    }

    modifier notApproved(uint _txId) {
        require(!approved[_txId][msg.sender], "Had approval");
        _;
    }

    modifier notExcuted(uint _txId) {
        require(!transactions[_txId].excuted, "Had excute");
        _;
    }

    constructor(address[] memory _owners, uint _required) {
        require(_required <= _owners.length); // 最小授权数不能大于数组长度
        required = _required;
        for (uint i = 0; i < _owners.length; i++) {
            require(address(0) != _owners[i]); // 地址不能为0
            require(!isOwner[_owners[i]], "owner is duplicate"); // 不能重复
            owners.push(_owners[i]);
            isOwner[_owners[i]] = true;
        }
    }

    function submit(address _to, uint _value, bytes calldata _data) external onlyOwner {
        transactions.push(Transaction(_to, _value, _data, false));
        emit Submit(transactions.length - 1);
    }

    function approve(uint _txId) external onlyOwner txExists(_txId) notApproved(_txId) notExcuted(_txId) {
        approved[_txId][msg.sender] =  true;
        emit Approve(msg.sender, _txId);
    }

    function revoke(uint _txId) external onlyOwner txExists(_txId) notExcuted(_txId) {
        require(approved[_txId][msg.sender]); // 没有授权，不能取消
        approved[_txId][msg.sender] = false;
        emit Revoke(msg.sender, _txId);
    }

    function execute(uint _txId) external onlyOwner txExists(_txId) notExcuted(_txId) {
        uint txRequired;
        for (uint i = 0; i < owners.length; i++) {
            if (approved[_txId][owners[i]]) txRequired++;
        }
        require(txRequired >= required);
        Transaction storage transaction = transactions[_txId];
        (bool success, ) = transaction.to.call{value: transaction.value}(transaction.data);
        require(success);
        transaction.excuted = true;
        emit Execute(_txId);
    }
}
