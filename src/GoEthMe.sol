// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {RewardsNft} from "./RewardsNft.sol";
import {IERC721} from "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {ERC2771Context} from "openzeppelin-contracts/contracts/metatx/ERC2771Context.sol";

/// @title GoEthMe - A decentralized fundraising platform for creative projects.

contract GoEthMe is ERC2771Context {
    struct GoFund {
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

    uint public id;
    mapping(uint => GoFund) funder;
    mapping(uint => mapping(address => uint)) public contribute;
    mapping(uint => mapping(address => bool)) public hasContributed;

    error InsufficientInput();
    error NotActive();
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

    constructor(address _trustedForwarder) ERC2771Context(_trustedForwarder) {}

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

        address contributor = _msgSender();

        contribute[_ID][contributor] += msg.value;
        fund.fundingBalance += msg.value;
        if (!hasContributed[_ID][contributor]) {
            fund.contributors.push(contributor);
            hasContributed[_ID][contributor] = true;
        }
        if (IERC721(address(fund.nftAddress)).balanceOf(contributor) == 0) {
            IRewardsNft(address(fund.nftAddress))._safeMint(fund.tokenUri);
        }

        emit ContributeEth(
            _ID,
            fund.fundingBalance,
            creator,
            contribute[_ID][contributor]
        );
    }

    /// @notice Get contributed funds from a GoFund campaign.
    /// @param _ID The ID of the campaign to retrieve funds from.
    function getContributedFunds(uint _ID) external {
        GoFund storage fund = funder[_ID];

        if (fund.isActive != true) revert NotActive();
        if (_msgSender() != fund.owner) revert NotOwner();
        if (fund.durationTime > block.timestamp) revert TimeNotReached();
        uint _bal = fund.fundingBalance;
        fund.fundingBalance = 0;
        fund.isActive = false;
        payable(fund.owner).transfer(_bal);

        emit GetContributedFunds(_ID, false);
    }

    /// @notice End a campaign early, returning funds to contributors.
    /// @param _ID The ID of the campaign to end early.

    function endCampaignEarly(uint _ID) external payable {
        GoFund storage fund = funder[_ID];
        if (msg.sender != fund.owner) revert NotOwner();
        if (!fund.isActive) revert NotActive();
        require(
            block.timestamp < fund.durationTime,
            "Duration time has already passed"
        );
        fund.isActive = false;
        uint _bal = fund.fundingBalance;
        fund.fundingBalance = 0;
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
}
