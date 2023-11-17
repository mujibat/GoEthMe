// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract RewardsNft is ERC721, ERC721URIStorage {
    uint256 tokenIdCounter;

    constructor(
        string memory _name,
        string memory _symbol
    ) ERC721(_name, _symbol) {}

    function _safeMint(address contributor, string memory _tokenUri) external {
        _safeMint(contributor, tokenIdCounter);
        _setTokenURI(tokenIdCounter, _tokenUri);
        tokenIdCounter++;
    }

    // functions that needs to be overriden because i used the ERC721URIStorage extension
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
