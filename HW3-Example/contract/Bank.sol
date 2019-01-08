pragma solidity ^0.4.23;

contract Bank {
	// 此合約的擁有者
    address private owner;

	// 儲存所有會員的餘額
    mapping (address => uint256) private balance;

	// 事件們，用於通知前端 web3.js
    event DepositEvent(address indexed from, uint256 value, uint256 timestamp);
    event WithdrawEvent(address indexed from, uint256 value, uint256 timestamp);
    event TransferEvent(address indexed from, address indexed to, uint256 value, uint256 timestamp);

	event MintEvent(address indexed from, uint value, uint256 timestamp);
    event BuyCoinEvent(address indexed from,  uint256 value, uint256 timestamp);
    event TransferCoinEvent(address indexed from, address indexed to, uint256 value, uint timestamp);
    event TransferOwnerEvent(address indexed oldOwner, address indexed newOwner, uint timestamp);
	

    modifier isOwner() {
        require(owner == msg.sender, "you are not owner");
        _;
    }
    
	// 建構子
    constructor() public payable {
        owner = msg.sender;
    }

	// 存錢
    function deposit() public payable {
        balance[msg.sender] += msg.value;

        emit DepositEvent(msg.sender, msg.value, now);
    }

	// 提錢
    function withdraw(uint256 etherValue) public {
        uint256 weiValue = etherValue * 1 ether;

        require(balance[msg.sender] >= weiValue, "your balances are not enough");

        msg.sender.transfer(weiValue);

        balance[msg.sender] -= weiValue;

        emit WithdrawEvent(msg.sender, etherValue, now);
    }

	// 轉帳
    function transfer(address to, uint256 etherValue) public {
        uint256 weiValue = etherValue * 1 ether;

        require(balance[msg.sender] >= weiValue, "your balances are not enough");

        balance[msg.sender] -= weiValue;
        balance[to] += weiValue;

        emit TransferEvent(msg.sender, to, etherValue, now);
    }

	// 檢查銀行帳戶餘額
    function getBankBalance() public view returns (uint256) {
        return balance[msg.sender];
    }

    //取得Coin餘額
    function getCoinBalance() public view returns (uint256) {
        return balance[msg.sender];
    }

    function kill() public isOwner {
        selfdestruct(owner);
    }

	// 鑄幣
    function mintCoin(uint256 coinValue) public isOwner{
        
        uint256 value = coinValue * 1 ether;
        //增加msg.sender的coinBalance
        balance[msg.sender] += value;
        
        //emit MintEvent
        emit MintEvent(msg.sender, coinValue, now);
    }

	//使用bank中的ether向owner購買coin
	function buyCoin(uint256 coinValue) public{
        uint256 value = coinValue * 1 ether;
        
        //require owner的coinBalance不小於value
        require(balance[owner] >= coinValue, "owner doesn't have enough coin");
        
        //require msg.sender的etherBalance不小於value
        require(balance[msg.sender] >= value, "bank balance is not enough");
        
        //msg.sender的etherBalance減少value
        balance[msg.sender] -= value;
        
        //owner的etherBalance增加value
        balance[owner] += value;
        
        //msg.sender的coinBalance增加value
        balance[msg.sender] += coinValue;
        
        //owner的coinBalance減少value
        balance[owner] -= coinValue;
        
        //emit BuyCoinEvent
        emit BuyCoinEvent(msg.sender, coinValue, now);
    }

	//NCCU Coin轉帳
	function transferCoin(address to, uint256 coinValue) public {
        uint256 value = coinValue * 1 ether;
        
        //require msg.sender的coinBalance不小於value
        require(balance[msg.sender] >= value, "bank balance is not enough");
        
        //msg.sender的coinBalance減少value
        balance[msg.sender] -= value;
        
        //to的coinBalance增加value
        balance[to] += value;
        
        //emit TransferCoinEvent
        emit TransferCoinEvent(msg.sender, to, coinValue, now);
        
    }

	//轉移Owner
	function transferOwner(address newOwner) public isOwner{
        
        //transfer ownership
        owner = newOwner;
        
        //emit TransferOwnerEvent
        emit TransferOwnerEvent(owner, newOwner, now);

    }

}