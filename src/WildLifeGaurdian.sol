// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";

contract WildLifeGuardianToken is ERC721, ERC721URIStorage, Ownable {
    uint256 private _tokenIdCounter;
    bytes32 private rootHash;

    error InvalidAddress(address);
    error AlreadyClaimed();
    error NotWhitelisted();

    mapping(address => bool) claimed;

    constructor(
        address _owner
    ) ERC721("WildLife Guardian Token", "WGT") Ownable(_owner) {}

    function safeMint(
        address[] calldata to,
        string memory tokenUri_
    ) public onlyOwner {
        uint256 tokenId = _tokenIdCounter;
        _setTokenURI(tokenId, tokenUri_);
        for (uint i = 0; i < to.length; ++i) {
            if (to[i] == address(0)) {
                revert InvalidAddress(to[i]);
            }
            if (balanceOf(to[i]) == 0) {
                _safeMint(to[i], tokenId);
                _tokenIdCounter++;
            } else {
                continue;
            }
        }
    }

    function claimToken(
        bytes32[] calldata _merkleProof,
        address _account,
        uint256 _amount
    ) external returns (bool) {
        if (claimed[_account]) {
            revert AlreadyClaimed();
        }
        bytes32 leaf = keccak256(abi.encodePacked(_account, _amount));
        if (!MerkleProof.verify(_merkleProof, rootHash, leaf)) {
            revert NotWhitelisted();
        }

        claimed[_account] = true;
        _safeMint(_account, _tokenIdCounter);
        _tokenIdCounter++;

        return true;
    }

    function addRootHash(bytes32 _rootHash) external onlyOwner {
        rootHash = _rootHash;
    }

    function burn(uint256 tokenId) external onlyOwner {
        _burn(tokenId);
    }

    // function overrides
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override(ERC721, IERC721) {
        revert("SoulBoundToken: transfer is disabled");
    }

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
