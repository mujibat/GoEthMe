import "./GoEthMe.sol";
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

 interface ISoulNft {
    function balanceOf(address owner) external view returns (uint256);
    function burn(uint256 tokenId) external;
 }

contract GofundmeDAO {

    uint256 public id;
    ISoulNft soulnft;
    GoEthMe goethme;
    address admin;

    enum Votes {
        YAY,
        NAY
    }
    
    mapping(uint => GoFund) public funder;
    
    address[] public members;
    mapping(address => bool) public isMember;
    mapping(address => uint) public memberVotes;
    
    uint public minVotesRequired = 4; // Minimum votes required for a function to execute
    
    event CreateGofundme(uint _id, string _title, uint256 _fundingGoal, uint256 _durationTime);
    event MemberRemoved(uint tokenId);
    event Vote(address member, uint _id);
    
    constructor(address _goethme, address _address, address _wildLifeGuardian) {
        goethme = GoEthMe(_goethme);
        admin= _address;
        soulnft = ISoulNft(_wildLifeGuardian);
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

    
    function removeMember(uint tokenId) external {
        require(msg.sender == admin, "Only admin can remove a member");
        soulnft.burn(tokenId);
   
        emit MemberRemoved(tokenId);
    }
    
    function vote(uint _id, Votes votes) external {
         GoFund storage fund = funder[_id];
        require(isMember[msg.sender], "You are not a member");
        require(funder[_id].isActive, "No active GoFund campaign with this ID");
        require(memberVotes[msg.sender] == 0, "You have already voted");
        require(soulnft.balanceOf(msg.sender) == 1, "Not a DAO Soul Bound Token Owner");
        
        memberVotes[msg.sender] = _id;
       
        if(votes == Votes.YAY) {
            fund.yayvotes += memberVotes[msg.sender];
        } else {
            fund.nayvotes += memberVotes[msg.sender];
        }
        emit Vote(msg.sender, _id);
    }
    

function executeFunction(uint _id) external {
    GoFund storage fund = funder[_id];
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
    if(fund.yayvotes > fund.nayvotes){

    goethme.createGofundme(funder[_id].title, funder[_id].fundingGoal, funder[_id].durationTime + block.timestamp);

    }
    funder[_id].isActive = false;
}

}


