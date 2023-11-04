// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "lib/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";
import {GofundmeDAO} from "./DAO.sol";

/// @title WildLifeGuardianToken - A unique NFT contract for Wildlife Guardians.

contract WildLifeGuardianToken is ERC721, ERC721URIStorage, Ownable {
    uint256 private _tokenIdCounter;
    bytes32 private rootHash;
    GofundmeDAO DAO;

    error InvalidAddress(address);
    error AlreadyClaimed();
    error NotWhitelisted();

    /// @dev Mapping to keep track of claimed tokens.

    mapping(address => bool) claimed;

    /// @notice Constructor to initialize the contract.
    /// @param _owner The address of the contract owner.
    constructor(
        address _owner
    ) ERC721("WildLife Guardian Token", "WGT") Ownable(_owner) {}

    /// @notice Safely mints new tokens and assigns them to specified addresses.
    /// @param to An array of addresses to receive the newly minted tokens.
    /// @param tokenUri_ The token URI for the new tokens.

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

    /// @notice Claims a token for an address using a Merkle proof.
    /// @param _merkleProof The Merkle proof to verify the claim.
    /// @param _account The address claiming the token.
    /// @param _amount The amount to claim.
    /// @return true if the claim is successful, false otherwise.

    function claimToken(
        bytes32[] calldata _merkleProof,
        address _account,
        uint256 _amount
    ) external returns (bool) {
        require(_account == msg.sender, "Only owner of account can claim");
        require(balanceOf(_account) == 0, "You already own an nft");
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

    /// @notice Adds a new Merkle root hash for token whitelisting.
    /// @param _rootHash The new Merkle root hash.

    function addRootHash(bytes32 _rootHash) external onlyOwner {
        rootHash = _rootHash;
    }

    /// @notice Burns a token by its ID.
    /// @param tokenId The ID of the token to burn.

    function burn(uint256 tokenId) external {
        require(address(DAO) == msg.sender, "Only Dao can burn tokens");
        _burn(tokenId);
    }

    // function overrides

    /// @dev Overrides the transferFrom function to disable transfers.

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override(ERC721, IERC721) {
        revert("SoulBoundToken: transfer is disabled");
    }

    /// @inheritdoc ERC721

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    /// @inheritdoc ERC721

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
