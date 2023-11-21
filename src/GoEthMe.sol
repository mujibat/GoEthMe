// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {RewardsNft} from "./RewardsNft.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

struct GoFund {
    uint id_;
    string title;
    string description;
    uint256 fundingGoal;
    address owner;
    uint startTime;
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

    struct Contributors {
        address contributor;
        uint balance;
        uint time;
    }

    mapping(uint => GoFund) funder;
    mapping(address => mapping(uint => Contributors)) contributors_;
    mapping(uint => mapping(address => uint)) public contribute;
    mapping(uint => mapping(address => bool)) public hasContributed;

    GoFund[] public activeCampaigns;

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
        string memory _description,
        string memory uri,
        uint256 _fundingGoal,
        uint256 _durationTime
    ) external returns (uint _id) {
        id++;
        _id = id;
        GoFund storage fund = funder[_id];

        fund.id_ = _id;
        fund.title = _title;
        fund.description = _description;
        fund.fundingGoal = _fundingGoal;
        fund.owner = creator;
        fund.startTime = block.timestamp;
        fund.durationTime = _durationTime + block.timestamp;
        fund.nftAddress = new RewardsNft(_title, "RFT");
        fund.tokenUri = uri;
        fund.isActive = true;

        // push to the active campaigns
        activeCampaigns.push(
            GoFund(
                fund.id_,
                fund.title,
                fund.description,
                fund.fundingGoal,
                fund.owner,
                fund.startTime,
                fund.durationTime,
                fund.isActive,
                0,
                fund.tokenUri,
                fund.nftAddress,
                fund.contributors,
                fund.yayvotes,
                fund.nayvotes
            )
        );

        emit CreateGofundme(_id, _title, _fundingGoal, _durationTime);
    }

    /// @notice Contribute Ether to a GoFund campaign.
    /// @param _ID The ID of the campaign to contribute to.

    function contributeEth(uint _ID) external payable {
        if (msg.value <= 0.001 ether) revert InsufficientInput();
        GoFund storage fund = funder[_ID];
        if (fund.isActive != true) revert NotActive();
        if (fund.fundingBalance + msg.value > fund.fundingGoal)
            revert ExceededFundingGoal();
        if (block.timestamp > fund.durationTime) revert NotInDuration();

        contributors_[msg.sender][_ID].time = block.timestamp;

        uint ID_ = _ID - 1;

        activeCampaigns[ID_].fundingBalance += msg.value;
        contribute[_ID][msg.sender] += msg.value;
        fund.fundingBalance += msg.value;
        if (!hasContributed[_ID][msg.sender]) {
            fund.contributors.push(msg.sender);
            hasContributed[_ID][msg.sender] = true;
        }
        if (fund.nftAddress.balanceOf(msg.sender) == 0) {
            fund.nftAddress._safeMint(msg.sender, fund.tokenUri);
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
            uint time = contributors_[contributor][_ID].time;

            _contributors[i] = Contributors(contributor, amount, time);
        }
    }

    function getfunder(uint _ID) external view returns (GoFund memory goFund) {
        goFund = funder[_ID];
    }

    function getAllCampaignsCount() external view returns (uint) {
        return id;
    }

    function getCampaigns() external view returns (GoFund[] memory) {
        return activeCampaigns;
    }

    function getStatus(uint _ID) external view returns (bool) {
        return funder[_ID].isActive;
    }
}
