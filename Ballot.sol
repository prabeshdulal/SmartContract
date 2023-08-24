// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Ballot {

    struct Voter {
        uint weight;
        bool voted;
        uint8 vote;
    }

    struct Proposal {
        uint voteCount;
    }

    enum Stage {Init, Reg, Vote, Done}
    Stage public stage = Stage.Init;
    
    address public chairperson;
    mapping(address => Voter) public voters;
    Proposal[] public proposals;
    
    uint public startTime;   

    /// Create a new ballot with $(_numProposals) different proposals.
     constructor(uint8 _numProposals) {
        chairperson = msg.sender;
        voters[chairperson].weight = 2; // weight is 2 for testing purposes

        // Initialize the proposals array in a loop
        for (uint8 i = 0; i < _numProposals; i++) {
            proposals.push(Proposal(0));
        }

        stage = Stage.Reg;
        startTime = block.timestamp;
    }

    /// Give $(toVoter) the right to vote on this ballot.
    /// May only be called by $(chairperson).
    function register(address toVoter) public {
        require(stage == Stage.Reg, "Registration stage is over.");
        require(msg.sender == chairperson, "Only the chairperson can register voters.");
        require(!voters[toVoter].voted, "Voter already voted.");
        
        voters[toVoter].weight = 1;
        voters[toVoter].voted = false;
        
        if (block.timestamp > (startTime + 10 seconds)) {
            stage = Stage.Vote;
            startTime = block.timestamp;
        }
    }

    /// Give a single vote to proposal $(toProposal).
    function vote(uint8 toProposal) public {
        require(stage == Stage.Vote, "Voting is not allowed at this stage.");
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "You already voted.");
        require(toProposal < proposals.length, "Invalid proposal index.");
        
        sender.voted = true;
        sender.vote = toProposal;
        proposals[toProposal].voteCount += sender.weight;
        
        if (block.timestamp > (startTime + 10 seconds)) {
            stage = Stage.Done;
        }
    }

    function winningProposal() public view returns (uint8 _winningProposal) {
        require(stage == Stage.Done, "Voting is not done yet.");
        
        uint256 winningVoteCount = 0;
        for (uint8 prop = 0; prop < proposals.length; prop++) {
            if (proposals[prop].voteCount > winningVoteCount) {
                winningVoteCount = proposals[prop].voteCount;
                _winningProposal = prop;
            }
        }
    }
}
