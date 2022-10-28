// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;



contract Voting {

    struct Proposal {
            string name;   
            uint voteCount;
            address adr;
        }

    struct Voter {
        address adr;
        bool voted;
    }


    uint public X;
    uint public F;
    uint public D;

    address payable public immutable owner;

    mapping(address => Voter) public voters;


    bool private VotingActive = false;
    uint private VotingBalance = 0;


    uint private start = 0;
    uint private end = 0;

    Proposal[] public proposals;
    string[] private PropNames;



    modifier validAddress() {
        require(msg.sender != address(0), "Not valid address");
        _;
    }


    constructor() validAddress {
        owner = payable(msg.sender);
    }

    
    modifier onlyOwner(){
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier ValidTime{
        require(block.timestamp<=end && block.timestamp>=start,"Time run out");  
        _;
    }


    event WithdrawIsDone(bool succes);
    event VotingResults(string[] names, uint reward);



    function createVoting(string[] memory proposalNames, address[] memory addresses, uint _X, uint _F, uint _D)public onlyOwner {

        require(_F<=10000, "Fee should be less than 10000 (fes is _F/10000)" );
        require(VotingActive == false, "Vote is already in progress" );
        require(_D>1, "Duration should be more than 1 second");
        require(proposalNames.length == addresses.length,  "Length of proposalNames and addresses should be the same ");

        X = _X;
        F = _F;
        D = _D;

        start = block.timestamp;
        end = start + D;


        for (uint i = 0; i < proposalNames.length; i++) {
            require(addresses[i] != address(0), "Not valid address of oen of proposals");

            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount: 0,
                adr: addresses[i]
            }));

            PropNames.push(proposalNames[i]);
        }
    }


    function voteFor(uint proposal) payable public ValidTime{

        require(msg.sender != proposals[proposal].adr, "You can't vote for yourself");
        require(proposal<proposals.length, "Proposal with this index doesn't exist");
        require(msg.value == X, "Pncorrect payment, should be value of X");


        VotingBalance += X;
        Voter storage sender = voters[msg.sender];

        require(!sender.voted, "Already voted");


        sender.voted = true;
        proposals[proposal].voteCount += 1;
    }


    function getVoteInfo() public view returns(string memory _status, uint _reward, Proposal[] memory _Proposals, uint _seconds_left, uint _Fee, uint _Payment_amount){
        require(start != 0, "Voting hasn't started yet");


        if(block.timestamp <= end){
            _status = "Voting is in progress";
            _seconds_left = end - block.timestamp;
        }
        else{
            _status = "Voting has ended";
            _seconds_left = 0;
        }

        _Proposals = proposals;
        _Payment_amount = X;
        _reward = (VotingBalance*(10000 -F))/10000;
        _Fee = F;
    }

    function getBalance() external view onlyOwner returns(uint){
        return(address(this).balance);
    }

    function withdrawFees() public onlyOwner{
        require(VotingActive == false, "Voting is in progress");

        uint amount = address(this).balance;

        (bool sent, ) = owner.call{value: amount}("");


        require(sent, "Failed to send Ether");
    }



    function VotingEnd() payable public onlyOwner{

        require(block.timestamp > end, "Voting is in progress");
        require(VotingActive == true, "Voting has already ended");


        address payable winner;

        uint max = proposals[0].voteCount;
        uint index = 1;
        for(uint p=1; p<proposals.length; p++){
            if (proposals[p].voteCount > max) {
                max = proposals[p].voteCount;
                index = p;
            }
        }

        winner = payable(proposals[index].adr);
        
        winner.transfer((VotingBalance*(10000-F))/(10000));
        PropNames.push(proposals[index].name);

        end = 0;
        start = 0;
        VotingBalance = 0;
        VotingActive = false;
        delete proposals;
        delete PropNames;
    }

}
