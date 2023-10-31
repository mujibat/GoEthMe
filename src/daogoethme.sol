// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IGoEthMe {
    function createGofundme(string memory _title, uint256 _fundingGoal, uint256 _durationTime) external returns(uint _id);
}

contract GoEthMeDAO {
    IGoEthMe goethme;

    struct Proposal {
        uint id;
        uint deadline;
        uint yayVotes;
        uint nayVotes;
        bool executed;

        mapping (uint => bool) voters;
    }
    enum Vote {
        YAY,
        NAY
    }

    mapping(uint => Proposal) public proposals;

    uint public numProposals;

    modifier activeProposalOnly(uint proposalIndex) {
        require(proposals[proposalIndex].deadline > block.timestamp, "Deadline Exceeded");
        _;
    }
    modifier inactiveProposalOnly(uint proposalIndex) {
        require(proposals[proposalIndex].deadline <= block.timestamp, "Deadline Not Exceeded");
        require(proposals[proposalIndex].executed == false, "Proposal Already Executed");
        _;
    }

    constructor(address _goethme) {
        goethme = IGoEthMe(_goethme);
    }
    function createProposal(uint _id) external
}