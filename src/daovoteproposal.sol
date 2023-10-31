contract CreateCampaignDAO {

     address payable public GoEthMeAddress;
    
    uint public voteEndTime;
    
    // balance of ether in the smart contract
    uint public DAOvoteNumbers;
    
    // allow withdrawals
    mapping(address=>uint) balances;
    
    // proposal decision of voters 
    uint public decision;

    // default set as false 
    // makes sure votes are counted before ending vote
    bool public ended;
    
    struct Voter {
        uint weight; // weight is accumulated by delegation
        bool voted;  // if true, that person already voted
        address delegate; // person delegated to
        uint vote;   // index of the voted proposal
    }

    struct Proposal {
        string name;   // short name (up to 32 bytes)
        uint voteCount; // number of accumulated votes
    }

    // address of the person who set up the vote 
    address public chairperson;

    mapping(address => Voter) public voters;
    Proposal[] public proposals;

    constructor( address payable _GoEthMeAddress, uint _voteTime, string[] memory proposalNames ) {

        GoEthMeAddress = _GoEthMeAddress;
        chairperson = msg.sender;
        
        voteEndTime = block.timestamp + _voteTime;
        voters[chairperson].weight = 1;

        for (uint i = 0; i < proposalNames.length; i++) {

            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount: 0
            }));
        }
    }
      // only the chairperson can decide who can vote
    function giveRightToVote(address voter) public {
        require(
            msg.sender == chairperson,
            "Only chairperson can give right to vote."
        );
        require(
            !voters[voter].voted,
            "The voter already voted."
        );
        require(voters[voter].weight == 0);
        voters[voter].weight = 1;
    }

        // proposals are in format 0,1,2,...
    function vote(uint proposal) public {
        Voter storage sender = voters[msg.sender];
        require(sender.weight != 0, "Has no right to vote");
        require(!sender.voted, "Already voted.");
        sender.voted = true;
        sender.vote = proposal;
        proposals[proposal].voteCount += sender.weight;
    }
       // winningProposal must be executed before EndVote
    function countVote() public returns (uint winningProposal_) {
        require(block.timestamp > voteEndTime, "Vote not yet ended.");
        
        uint winningVoteCount = 0;

        for (uint p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal_ = p;
                
                decision = winningProposal_;
                ended = true;
            }
        }
    }
    // ends the vote
    // if DAO decided not to buy cupcakes members can withdraw deposited ether
    function EndVote() public {
        require(
            block.timestamp > voteEndTime,
            "Vote not yet ended.");
          
        require(
            ended == true,
            "Must count vote first");  
            
        require(
            DAObalance >= 1 ether,
            "Not enough balance in DAO required to buy cupcake. Members may withdraw deposited ether.");
            
        require(
            decision == 0,
            "DAO decided to not buy cupcakes. Members may withdraw deposited ether."); 
            
        if (DAObalance  < 1 ether) revert();
            (bool success, ) = address(GoEthMeAddress).call{value: 1 ether}(abi.encodeWithSignature("purchase(uint256)", 1));
            require(success);
            
        DAObalance = address(this).balance;
  
    }
}