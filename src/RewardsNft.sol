// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract RewardsNft is ERC721, ERC721URIStorage {
    uint256 tokenIdCounter;

    constructor(
        string memory name,
        string memory symbol
    ) ERC721(name, symbol) {}

    function _safeMint(string memory _tokenUri) external {
        uint256 tokenId = tokenIdCounter + 1;
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, _tokenUri);
    }

    // functions that needs to be overriden because i used the ERC721URIStorage extension
    function _burn(uint256 tokenId) internal override(ERC721) {
        super._burn(tokenId);
    }

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
