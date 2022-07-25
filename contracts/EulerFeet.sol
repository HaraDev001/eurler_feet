// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract EulerFeet is Ownable, ERC1155 {
    uint256 public constant MAX_LEFT_SHOES = 5;
    uint256 public constant MAX_RIGHT_SHOES_PER_LEFT_SHOE = 100;

    uint256 public constant LEFT_SHOE_MINT_PRICE = 1 ether;
    uint256 public constant RIGHT_SHOE_MINT_PRICE = 0.1 ether;
    uint256 public constant ROYALTY_PER_RIGHT_SHOE_SALE =
        (RIGHT_SHOE_MINT_PRICE * 1) / 10;

    uint256 public leftShoeCount;
    mapping(uint256 => address) public leftShoeOwners;
    mapping(uint256 => uint256) public rightShoeCountForLeftShoe;

    uint256 public reserve;

    constructor()
        ERC1155(
            "https://eulerfeet.blob.core.windows.net/nft/metadata/{id}.json"
        )
    {}

    function mintLeftShoe() external payable returns (uint256 leftShoeTokenId) {
        require(msg.value == LEFT_SHOE_MINT_PRICE, "invalid payment");
        require(leftShoeCount < MAX_LEFT_SHOES, "no more left shoes");

        leftShoeCount += 1;
        leftShoeOwners[leftShoeCount] = msg.sender;
        _mint(msg.sender, leftShoeCount, 1, "");
        return leftShoeCount;
    }

    function mintRightShoe(uint256 leftShoeId)
        external
        payable
        returns (uint256 rightShoeTokenId)
    {
        require(msg.value == RIGHT_SHOE_MINT_PRICE, "invalid payment");
        require(
            leftShoeOwners[leftShoeId] != address(0),
            "left shoe not minted"
        );
        require(
            rightShoeCountForLeftShoe[leftShoeId] <
                MAX_RIGHT_SHOES_PER_LEFT_SHOE,
            "no more right shoes"
        );

        rightShoeTokenId = leftShoeId * 100;
        rightShoeCountForLeftShoe[leftShoeId] += 1;
        reserve += msg.value - ROYALTY_PER_RIGHT_SHOE_SALE;

        Address.sendValue(
            payable(leftShoeOwners[leftShoeId]),
            ROYALTY_PER_RIGHT_SHOE_SALE
        );
        _mint(msg.sender, rightShoeTokenId, 1, "");
    }

    function burnRightShoe(uint256 rightShoeId) external {
        require(balanceOf(msg.sender, rightShoeId) > 0, "insufficient balance");
        require(rightShoeId >= 100, "invalid token id");

        uint256 leftShoeId = rightShoeId / 100;
        require(leftShoeOwners[leftShoeId] != address(0), "unknown token id");

        rightShoeCountForLeftShoe[leftShoeId] -= 1;

        uint256 burnRefund = RIGHT_SHOE_MINT_PRICE -
            ROYALTY_PER_RIGHT_SHOE_SALE;
        reserve -= burnRefund;

        Address.sendValue(payable(msg.sender), burnRefund);
        _burn(msg.sender, rightShoeId, 1);
    }

    function withdrawFunds() external onlyOwner {
        uint256 withdrawableFunds = address(this).balance - reserve;
        Address.sendValue(payable(msg.sender), withdrawableFunds);
    }

    function _beforeTokenTransfer(
        address,
        address,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory
    ) internal virtual override {
        for (uint256 i = 0; i < ids.length; i++) {
            uint256 tokenId = ids[i];
            uint256 amount = amounts[i];
            if (leftShoeOwners[tokenId] != address(0) && amount > 0) {
                leftShoeOwners[tokenId] = to;
            }
        }
    }
}
