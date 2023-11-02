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
    mapping(address => mapping(uint => bool)) public hasVoted;


    uint public minVotesRequired = 4; // Minimum votes required for a function to execute

    event CreateGofundme(
        uint _id,
        string _title,
        uint256 _fundingGoal,
        uint256 _durationTime
    );
    event MemberRemoved(uint tokenId);
    event Vote(address member, uint _id);
    event Approved(uint _id, string _title);

    constructor(address _goethme, address _address, address _wildLifeGuardian) {
        goethme = GoEthMe(_goethme);
        admin = _address;
        soulnft = ISoulNft(_wildLifeGuardian);
    }

    function createGofundme(
        string memory _title,
        uint256 _fundingGoal,
        uint256 _durationTime,
        string memory imageUrl
    ) public {
        id++;
        uint _id = id;

        GoFund storage fund = funder[_id];

        fund.title = _title;
        fund.fundingGoal = _fundingGoal;
        fund.owner = msg.sender;
        fund.durationTime = _durationTime;
        fund.isActive = true;
        fund.tokenUri = imageUrl;

        emit CreateGofundme(_id, _title, _fundingGoal, _durationTime);
    }

    function removeMember(uint tokenId) external {
        require(msg.sender == admin, "Only admin can remove a member");
        soulnft.burn(tokenId);

        emit MemberRemoved(tokenId);
    }

    function vote(uint _id, Votes votes) external {
        require(soulnft.balanceOf(msg.sender) == 1, "Not a DAO member");
        GoFund storage fund = funder[_id];
        require(funder[_id].isActive, "No active GoFund campaign with this ID");
        require(!hasVoted[msg.sender][_id], "Already voted");

        hasVoted[msg.sender][_id] = true;

        if (votes == Votes.YAY) {
            fund.yayvotes += 1;
        } else {
            fund.nayvotes += 1;
        }
        emit Vote(msg.sender, _id);
    }

    function approveCampaign(uint _id) external {
        require(admin == msg.sender, "Only admin can approve a campaign")
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

        emit Approved(_id, funder[_id].title,);
    }

    function contributeToPool() external payable {
        require(msg.value > 0, "Insufficient input");
        require(soulnft.balanceOf(msg.sender) == 1, "Not a DAO member");
    }

    function sendEth(address payable _to, uint256 _amount) external {
        require(msg.sender == admin, "Only admin can send ETH");
        (bool s, ) = _to.call{value: _amount}("");
        require(s, "Transfer failed");
    }

    receive() external payable {}

    fallback() external payable {}
}
