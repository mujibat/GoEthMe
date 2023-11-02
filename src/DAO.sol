import "./GoEthMe.sol";
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface ISoulNft {
    function balanceOf(address owner) external view returns (uint256);

    function burn(uint256 tokenId) external;
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
    address relayer;
    uint public votingTime;
    uint public urgentVotingTime;
    uint public fee = 0 ether;

    // Errors

    error VotingOver();
    error VotingInProgress();

    enum Votes {
        YAY,
        NAY
    }

    enum status {
        URGENT,
        NORMAL
    }

    struct VotePeriod {
        uint256 normal;
        uint256 urgent;
    }

    mapping(uint => GoFund) public funder;
    mapping(uint => status) public _status;
    mapping(uint => VotePeriod) public votePeriod_;
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
    event Approved(uint _id, string _title);
    event ContributedToPool(address member, uint256 amount);
    event SentEth(uint256 amount);

    /**
     * @dev Constructor to initialize the GofundmeDAO contract.
     * @param _goethme Address of the GoEthMe contract.
     * @param _address Address of the DAO admin.
     * @param _wildLifeGuardian Address of the WildLifeGuardian contract.
     * @param _relayer Address of the relayer.
     * @param _votingTime Duration of voting periods.
     * @param _fee Fee required for urgent campaign creation.
     */

    constructor(
        address _goethme,
        address _address,
        address _wildLifeGuardian,
        address _relayer,
        uint _votingTime,
        uint _fee
    ) {
        goethme = GoEthMe(_goethme);
        admin = _address;
        soulnft = ISoulNft(_wildLifeGuardian);
        relayer = _relayer;
        votingTime = _votingTime;
        fee = _fee;
    }

    /**
     * @dev Creates a new crowdfunding campaign.
     * @param _title Title of the campaign.
     * @param _fundingGoal Funding goal for the campaign.
     * @param _durationTime Duration of the campaign.
     * @param imageUrl Image URL for the campaign.
     * @param status_ Status of the campaign (URGENT or NORMAL).
     */

    function createGofundme(
        string memory _title,
        uint256 _fundingGoal,
        uint256 _durationTime,
        string memory imageUrl,
        status status_
    ) public payable {
        id++;
        uint _id = id;

        GoFund storage fund = funder[_id];

        fund.title = _title;
        fund.fundingGoal = _fundingGoal;
        fund.owner = msg.sender;
        fund.durationTime = _durationTime;
        fund.isActive = true;
        fund.tokenUri = imageUrl;

        if (_status == status.URGENT) {
            _status[_id] = status.URGENT;
            votePeriod_[_id].urgent = block.timestamp + urgentVotingTime;
            require(msg.value == fee, "Insufficient amount");
        } else {
            _status[_id] = status.NORMAL;
            votePeriod_[_id].normal = block.timestamp + votingTime;
        }

        emit CreateGofundme(_id, _title, _fundingGoal, _durationTime);
    }

    /**
     * @dev Allows the admin to remove a member from the DAO.
     * @param tokenId The unique identifier of the member to be removed.
     */

    function removeMember(uint tokenId) external {
        require(msg.sender == admin, "Only admin can remove a member");

        soulnft.burn(tokenId);

        emit MemberRemoved(tokenId);
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

        if (_status[_id] == status.URGENT) {
            // Check if voting period is over
            if (block.timestamp > votePeriod_[_id].urgent) {
                revert VotingOver();
            }
        }

        if (_status[_id] == status.NORMAL) {
            // Check if voting period is over
            if (block.timestamp > votePeriod_[_id].normal) {
                revert VotingOver();
            }
        }

        hasVoted[msg.sender][_id] = true;

        if (votes == Votes.YAY) {
            fund.yayvotes += 1;
        } else {
            fund.nayvotes += 1;
        }
        emit Vote(msg.sender, _id);
    }

    /**
     * @dev Allows the admin to approve a campaign for execution.
     * @param _id The ID of the campaign to be approved.
     */

    function approveCampaign(uint _id) external {
        require(admin == msg.sender, "Only admin can approve a campaign");

        GoFund storage fund = funder[_id];
        require(funder[_id].isActive, "No active GoFund campaign with this ID");

        funder[_id].isActive = false;

        // check that voting period is over
        if (_status[_id] == status.URGENT) {
            if (block.timestamp < votePeriod_[_id].urgent) {
                revert VotingInProgress();
            }
        }

        if (_status[_id] == status.NORMAL) {
            if (block.timestamp < votePeriod_[_id].normal) {
                revert VotingInProgress();
            }
        }

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

        emit Approved(_id, funder[_id].title);
    }

    /**
     * @dev Allows a member of the DAO to contribute ETH to the DAO's pool.
     * @notice Members must be in possession of a SoulNFT token and provide a non-zero ETH value to contribute.
     */
    function contributeToPool() external payable {
        require(msg.value > 0, "Insufficient input");
        require(soulnft.balanceOf(msg.sender) == 1, "Not a DAO member");

        emit ContributedToPool(msg.sender, msg.value);
    }

    /**
     * @dev Allows the admin to send ETH from the contract's balance to the designated relayer.
     * @param _amount The amount of ETH to be sent to the relayer.
     * @notice Only the admin can initiate this action, and it ensures the relayer's balance is sufficiently low.
     * @notice The transfer is executed as a call to the relayer's address.
     */

    function sendEth(uint256 _amount) external {
        require(msg.sender == admin, "Only admin can send ETH");
        require(relayer.balance <= 0.1 ether, "Relayer balance is not low");
        (bool s, ) = payable(relayer).call{value: _amount}("");
        require(s, "Transfer failed");

        emit SentEth(_amount);
    }

    /**
     * @dev Fallback function to receive and store incoming ETH.
     */

    receive() external payable {}

    /**
     * @dev Fallback function to receive and store incoming ETH.
     */

    fallback() external payable {}
}
