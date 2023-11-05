// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./GoEthMe.sol";
import {DaoMembership} from "./WildLifeGaurdian.sol";

interface ISoulNft {
    function balanceOf(address owner) external view returns (uint256);

    function burn(uint256 tokenId) external;

    function showIds(address _member) external view returns (uint);
}

/**
 * @title GofundmeDAO
 * @dev This contract manages a decentralized autonomous organization (DAO) for crowdfunding campaigns. Members of the DAO vote to approve or reject campaigns.
 */

contract GofundmeDAO {
    uint256 public id;
    ISoulNft soulnft;
    GoEthMe goethme;
    address admin;
    uint votingTime;
    uint _time;
    DaoMembership members;

    struct DAOTime {
        uint daovotetime;
    }

    // Errors

    error VotingOver();
    error VotingInProgress();
    // 0 for yay, 1 for nay
    enum Votes {
        YAY,
        NAY
    }

    mapping(uint => DAOTime) public daotime;
    mapping(uint => GoFund) public funder;
    mapping(address => uint) memberVotes;

    mapping(address => mapping(uint => bool)) public hasVoted;

    // Events
    event CreateGofundme(
        uint _id,
        string _title,
        uint256 _fundingGoal,
        uint256 _durationTime
    );
    event MemberRemoved(uint tokenId);
    event Vote(address member, uint _id);
    event ApprovedProposal(uint _id, string _title);
    event ContributedToPool(address member, uint256 amount);
    event SentEth(uint256 amount);

    /**
     * @dev Constructor to initialize the GofundmeDAO contract.
     * @param _goethme Address of the GoEthMe contract.
     * @param _address Address of the DAO admin.
     * @param _wildLifeGuardian Address of the WildLifeGuardian contract.
     */

    constructor(address _goethme, address _address, address _wildLifeGuardian) {
        goethme = GoEthMe(_goethme);
        admin = _address;
        soulnft = ISoulNft(_wildLifeGuardian);
        votingTime = 1 days;
    }

    /**
     * @dev Creates a new crowdfunding campaign.
     * @param _title Title of the campaign.
     * @param _fundingGoal Funding goal for the campaign.
     * @param _durationTime Duration of the campaign.
     * @param imageUrl Image URL for the campaign.
     */

    function createGofundme(
        string memory _title,
        uint256 _fundingGoal,
        uint256 _durationTime,
        string memory imageUrl
    ) public returns (uint _id) {
        // votingTime = 1 days;
        id++;
        _id = id;
        if (_id == 1) {
            _time = block.timestamp + 30 days;
        }
        DAOTime storage time = daotime[_id];
        GoFund storage fund = funder[_id];

        fund.title = _title;
        fund.fundingGoal = _fundingGoal;
        fund.owner = msg.sender;
        fund.durationTime = _durationTime;
        fund.isActive = true;
        fund.tokenUri = imageUrl;
        time.daovotetime = votingTime + block.timestamp;

        emit CreateGofundme(_id, _title, _fundingGoal, _durationTime);
    }

    /**
     * @dev Allows the admin to remove a member from the DAO.
     * @param tokenId The unique identifier of the member to be removed.
     */

    function removeMember(uint tokenId) external {
        require(msg.sender == admin, "Only admin can remove a member");
        require(block.timestamp > _time, "can't remove member yet");
        _time = block.timestamp + 30 days;

        uint removeCriteria = (70 * id) / 100;
        for (uint i = 0; i < members.member.length; i++) {
            address daoMembers = members.member[i];

            if (memberVotes[daoMembers] < removeCriteria) {
                uint id_ = soulnft.showIds(daoMembers);
                soulnft.burn(id_);
                emit MemberRemoved(id_);
            }
        }
    }

    /**
     * @dev Allows a member of the DAO to vote on a campaign.
     * @param _id The ID of the campaign to vote on.
     * @param votes The member's vote (YAY or NAY).
     */

    function vote(uint _id, Votes votes) external {
        require(soulnft.balanceOf(msg.sender) == 1, "Not a DAO member");
        GoFund storage fund = funder[_id];
        require(funder[_id].isActive, "No active GoFund campaign with this ID");
        require(!hasVoted[msg.sender][_id], "Already voted");
        require(
            daotime[_id].daovotetime > block.timestamp,
            "Voting Time Elapsed"
        );

        hasVoted[msg.sender][_id] = true;
        uint8 numVotes = 1;

        if (votes == Votes.YAY) {
            fund.yayvotes += numVotes;
        } else {
            fund.nayvotes += numVotes;
        }
        memberVotes[msg.sender]++;
        emit Vote(msg.sender, _id);
    }

    /**
     * @dev Allows the admin to approve a campaign for execution.
     * @param _id The ID of the campaign to be approvedProposal.
     */

    function approveProposal(uint _id) external {
        require(admin == msg.sender, "Only admin can approve a campaign");
        require(
            daotime[_id].daovotetime < block.timestamp,
            "Voting Time In Progress"
        );

        GoFund storage fund = funder[_id];
        require(funder[_id].isActive, "No active GoFund campaign with this ID");

        funder[_id].isActive = false;

        // Execute the createGofundme function
        if (fund.yayvotes > fund.nayvotes) {
            goethme.createGofundme(
                funder[_id].owner,
                funder[_id].title,
                funder[_id].tokenUri,
                funder[_id].fundingGoal,
                funder[_id].durationTime
            );
        }

        emit ApprovedProposal(_id, funder[_id].title);
    }
}
