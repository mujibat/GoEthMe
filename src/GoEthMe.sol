// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {RewardsNft} from "./RewardsNft.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

struct GoFund {
    uint id_;
    string title;
    uint256 fundingGoal;
    address owner;
    uint256 durationTime;
    bool isActive;
    uint256 fundingBalance;
    string tokenUri;
    RewardsNft nftAddress;
    address[] contributors;
    uint yayvotes;
    uint nayvotes;
}

/// @title GoEthMe - A decentralized fundraising platform for creative projects.

contract GoEthMe {
    uint public id;
    mapping(uint => GoFund) funder;
    mapping(uint => mapping(address => uint)) public contribute;
    mapping(uint => mapping(address => bool)) public hasContributed;

    error InsufficientInput();
    error NotActive();
    error NotActiveCause();
    error ExceededFundingGoal();
    error NotInDuration();
    error NotOwner();
    error TimeNotReached();
    event CreateGofundme(
        uint id,
        string _title,
        uint256 _fundingGoal,
        uint256 _durationTime
    );
    event ContributeEth(
        uint indexed _ID,
        uint _fundingBalance,
        address contributor,
        uint amount
    );
    event GetContributedFunds(uint indexed _ID, bool isActive);

    /// @notice Create a GoFund campaign.
    /// @param _title The title of the campaign.
    /// @param uri The URI for the associated NFT.
    /// @param _fundingGoal The funding goal in ether.
    /// @param _durationTime The duration of the campaign in seconds.
    /// @return _id The unique ID of the created campaign.

    function createGofundme(
        address creator,
        string memory _title,
        string memory uri,
        uint256 _fundingGoal,
        uint256 _durationTime
    ) external returns (uint _id) {
        id++;
        _id = id;
        GoFund storage fund = funder[_id];

        fund.id_ = _id;
        fund.title = _title;
        fund.fundingGoal = _fundingGoal;
        fund.owner = creator;
        fund.durationTime = _durationTime + block.timestamp;
        fund.nftAddress = new RewardsNft(_title, "RFT");
        fund.tokenUri = uri;
        fund.isActive = true;

        emit CreateGofundme(_id, _title, _fundingGoal, _durationTime);
    }

    /// @notice Contribute Ether to a GoFund campaign.
    /// @param _ID The ID of the campaign to contribute to.

    function contributeEth(uint _ID) external payable {
        if (msg.value <= 0) revert InsufficientInput();
        GoFund storage fund = funder[_ID];
        if (fund.isActive != true) revert NotActive();
        if (fund.fundingBalance + msg.value > fund.fundingGoal)
            revert ExceededFundingGoal();
        if (block.timestamp > fund.durationTime) revert NotInDuration();

        contribute[_ID][msg.sender] += msg.value;
        fund.fundingBalance += msg.value;
        if (!hasContributed[_ID][msg.sender]) {
            fund.contributors.push(msg.sender);
            hasContributed[_ID][msg.sender] = true;
        }
        if (IERC721(address(fund.nftAddress)).balanceOf(msg.sender) == 0) {
            RewardsNft(address(fund.nftAddress))._safeMint(
                fund.owner,
                fund.tokenUri
            );
        }

        emit ContributeEth(
            _ID,
            fund.fundingBalance,
            msg.sender,
            contribute[_ID][msg.sender]
        );
    }

    /// @notice Get contributed funds from a GoFund campaign.
    /// @param _ID The ID of the campaign to retrieve funds from.
    function getContributedFunds(uint _ID) external {
        GoFund storage fund = funder[_ID];

        if (fund.isActive != true) revert NotActiveCause();
        if (msg.sender != fund.owner) revert NotOwner();
        if (fund.durationTime > block.timestamp) revert TimeNotReached();
        uint _bal = fund.fundingBalance;
        fund.fundingBalance = 0;
        fund.isActive = false;
        payable(fund.owner).transfer(_bal);

        emit GetContributedFunds(_ID, false);
    }

    struct Contributors {
        address contributor;
        uint balance;
    }

    /// @notice Retrieve a list of contributors and their contribution balances for a campaign.
    /// @param _ID The ID of the campaign to retrieve contributors from.
    /// @return _contributors An array of contributors and their balances.
    function getContributors(
        uint _ID
    ) external view returns (Contributors[] memory _contributors) {
        GoFund storage fund = funder[_ID];
        uint total = fund.contributors.length;

        _contributors = new Contributors[](total);

        for (uint i = 0; i < total; i++) {
            address contributor = fund.contributors[i];
            uint amount = contribute[_ID][contributor];

            _contributors[i] = Contributors(contributor, amount);
        }
    }

    function getfunder(uint _ID) external view returns (GoFund memory goFund) {
        goFund = funder[_ID];
    }
}
