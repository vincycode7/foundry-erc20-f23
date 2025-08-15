// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract ManualToken {
    mapping(address => uint256) private s_balances;

    function name() public pure returns (string memory) {
        return "Manual Token";
    }

    function symbol() public pure returns (string memory) {
        return "MTK";
    }

    function totalSupply() public pure returns (uint256) {
        // 100 tokens with 18 decimals
        // 1 token = 10^18 wei
        // 100 tokens = 100 * 10^18 wei
        // 100 * 10^18 wei = 100 ether
        return 100 ether;
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return s_balances[_owner];
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0), "Cannot transfer to the zero address");
        require(s_balances[msg.sender] >= _value, "Insufficient balance");

        uint256 previousBalance = s_balances[_to] + s_balances[msg.sender];

        s_balances[msg.sender] -= _value;
        s_balances[_to] += _value;

        uint256 newBalance = s_balances[_to] + s_balances[msg.sender];

        require(newBalance == previousBalance, "Balance mismatch after transfer");

        return true;
    }
}
