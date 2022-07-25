// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.11;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./Blacklistable.sol";

contract Feet is ERC20, Blacklistable {
    constructor() ERC20("feet", "FEET") {}

    function gimmeSomeFeet() external {
        _mint(msg.sender, 10 * 10 * 18);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    )
        internal
        virtual
        override
        notBlacklisted(msg.sender)
        notBlacklisted(from)
        notBlacklisted(to)
    {}
}
