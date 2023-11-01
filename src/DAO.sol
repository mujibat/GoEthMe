import "./GoEthMe.sol";
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IGoEthMe {
    function createGofundme(string memory _title, uint256 _fundingGoal, uint256 _durationTime) external returns(uint _id) ;
}

contract GofundmeDAO {
    uint256 public id;
    address goethme;
    // struct GoFund {
    //     string title;
    //     uint256 fundingGoal;
    //     address owner;
    //     uint256 durationTime;
    //     bool isApproved;
    // }
    
    mapping(uint => GoFund) public funder;
    
    address[] public members;
    mapping(address => bool) public isMember;
    mapping(address => uint) public memberVotes;
    
    uint public minVotesRequired = 4; // Minimum votes required for a function to execute
    
    event CreateGofundme(uint _id, string _title, uint256 _fundingGoal, uint256 _durationTime);
    event MemberAdded(address member);
    event MemberRemoved(address member);
    event Vote(address member, uint _id);
    
    constructor(address[] memory initialMembers) {
        require(initialMembers.length == 7, "Initial members must be 7");
        
        for (uint i = 0; i < initialMembers.length; i++) {
            members.push(initialMembers[i]);
            isMember[initialMembers[i]] = true;
        }
    }
    
    function createGofundme(string memory _title, uint256 _fundingGoal, uint256 _durationTime) public {
        require(!funder[id].isActive, "An active GoFund campaign already exists");
        
        id++;
        uint _id = id;
        
        GoFund storage fund = funder[_id];
        
        fund.title = _title;
        fund.fundingGoal = _fundingGoal;
        fund.owner = msg.sender;
        fund.durationTime = _durationTime;
        fund.isActive = false;
        
        emit CreateGofundme(_id, _title, _fundingGoal, _durationTime);
    }
    
    function addMember(address newMember) external {
        require(isMember[msg.sender], "You are not a member");
        require(!isMember[newMember], "Member already exists");
        require(members.length < 7, "Maximum number of members reached");
        
        members.push(newMember);
        isMember[newMember] = true;
        
        emit MemberAdded(newMember);
    }
    
    function removeMember(address member) external {
        require(isMember[msg.sender], "You are not a member");
        require(isMember[member], "Member does not exist");
        require(members.length > 1, "Cannot remove the last member");
        
        isMember[member] = false;
        memberVotes[member] = 0;
        
        // Remove the member from the list
        for (uint i = 0; i < members.length; i++) {
            if (members[i] == member) {
                members[i] = members[members.length - 1];
                members.pop();
                break;
            }
        }
        
        emit MemberRemoved(member);
    }
    
    function vote(uint _id) external {
        require(isMember[msg.sender], "You are not a member");
        require(funder[_id].isActive, "No active GoFund campaign with this ID");
        require(memberVotes[msg.sender] == 0, "You have already voted");
        
        memberVotes[msg.sender] = _id;
        emit Vote(msg.sender, _id);
    }
    
// Add your code to execute the GoFund function here
function executeFunction(uint _id) external {
    require(isMember[msg.sender], "You are not a member");
    require(funder[_id].isActive, "No active GoFund campaign with this ID");
    require(memberVotes[msg.sender] == _id, "You have not voted for this ID");

    uint voteCount = 0;
    for (uint i = 0; i < members.length; i++) {
        if (memberVotes[members[i]] == _id) {
            voteCount++;
        }
    }

    require(voteCount >= minVotesRequired, "Not enough votes to execute");

    // Reset votes
    for (uint i = 0; i < members.length; i++) {
        if (memberVotes[members[i]] == _id) {
            memberVotes[members[i]] = 0;
        }
    }

    // Execute the createGofundme function
    IGoEthMe(goethme).createGofundme(funder[_id].title, funder[_id].fundingGoal, funder[_id].durationTime);
    // createGofundme(funder[_id].title, funder[_id].fundingGoal, funder[_id].durationTime + block.timestamp);
    funder[_id].isActive = false;
}

}
/**
yay and nay(checking balance)
checking balanceOf to check a real member & voting power
calling the main contract with interface
calling nft contract burn function to remove a member



 */

