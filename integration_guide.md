# Integration Guide

## Confirguration

### Testnet

- USDT contract address: 0xE349139c3425838016e8DE0839A4467d07f683d8
- Order contract address: 0x6fD95f5Ff9742819561E5b68FdFA15F69bE7e1a7
- Deposit amount: 50USDT (50000000, decimal=6)

## USDT contract

call USDT contract

### get allowance

    function allowance(address owner, address spender) public view virtual returns (uint256)

Parameters:
- owner: user address
- spender: order contract address

Returns:
- allowance

If the returned allowance is less than the deposit, the user needs to perform the approve operation.

### approve

    function approve(address spender, uint256 value) public virtual returns (bool)

Parameters:
- spender: order contract address
- value: approve deposit amount

## Order contract

call order contract

### Pay for order

    function payOrder(string memory _orderNum, address _tokenAddress) external

Parameters:
- _orderNum: order number
- _tokenAddress: USDT contract address

### Pay for order event

    event PayOrder(string indexed _orderNum, address indexed _tokenAddress, address indexed _userAddr, uint256 _deposit);

Parameters:
- _orderNum: order number
- _tokenAddress: payment token address (USDT contract address)
- _userAddr: user address
- _deposit: deposit amount

### Settle order

    function settleOrder(string memory _orderNum, uint256 _amount, uint256 _endTime) external

Parameters:
- _orderNum: order number
- _amount: power bank borrow fee, multiply by 1000000 (USDT decimal = 6)
- _endTime: return timestamp

### Settle order event

    event SettleOrder(string indexed _orderNum, address indexed _tokenAddress, address indexed _userAddr, uint256 _amount, uint256 _endTime);

Parameters:
- _orderNum: order number
- _tokenAddress: payment token address (USDT contract address)
- _userAddr: user address
- _amount: the fee of borrowing power bank
- _endTime: the return timestamp

### Query order info

    function getOrder(string memory _orderNum) public view returns(Order memory)

Parameters:
- _orderNum: order number

Returns:
- Order Object:
  - address userAddr: user address
  - uint256 startTime: borrow timestamp
  - uint256 endTime: return timestamp
  - address tokenAddress: payment token address
  - uint256 deposit: deposit amount
  - uint256 fee: the fee of borrowing power bank
  - OrderStatus status: order status

### Query user in-process order list

    function getUserOrders(address _userAddr) public view returns(string[] memory)

Parameters:
- _userAddr: user address

Returns:
- string[]: order number list