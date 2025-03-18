# Integration Guide

## Confirguration

### Testnet

- USDT contract address: 0xE349139c3425838016e8DE0839A4467d07f683d8
- Order contract address: 0xBB83c12a48f7E84cD3c249039d579013D3a59255
- Deposit amount: 20USDT (20000000, decimal=6)

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

    function payOrder(uint256 _orderNum, address _tokenAddress) external

Parameters:
- _orderNum: order number
- _tokenAddress: USDT contract address

### Pay for order event

    event PayOrder(uint256 _orderNum, address indexed _tokenAddress, address indexed _userAddr, uint256 _deposit);

Parameters:
- _orderNum: order number
- _tokenAddress: payment token address (USDT contract address)
- _userAddr: user address
- _deposit: deposit amount

### Settle order

    function settleOrder(uint256 _orderNum, uint256 _amount, uint256 _endTime) external

Parameters:
- _orderNum: order number
- _amount: power bank borrow fee, multiply by 1000000 (USDT decimal = 6)
- _endTime: return timestamp

### Settle order event

    event SettleOrder(uint256 indexed _orderNum, address indexed _tokenAddress, address indexed _userAddr, uint256 _amount, uint256 _endTime);

Parameters:
- _orderNum: order number
- _tokenAddress: payment token address (USDT contract address)
- _userAddr: user address
- _amount: the fee of borrowing power bank
- _endTime: the return timestamp

### Query order info

    function getOrder(uint256 _orderNum) public view returns(Order memory)

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

    function getUserOrders(address _userAddr) public view returns(uint256[])

Parameters:
- _userAddr: user address

Returns:
- uint256[]: order number list