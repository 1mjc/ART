// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract ArtPoints {
    uint256 public daoMemberCount;

    mapping(address => uint256) public reputation;
    mapping(address => bool) public isMember;

    struct Proposal {
        address recipient;
        uint256 amount;
        uint256 yesVotes;
        uint256 noVotes;
        bool executed;
        mapping(address => bool) hasVoted; // nested mapping (forces storage-based creation)
    }

    Proposal[] public proposals;

    // Create a proposal (members only)
    function proposing(address recipient, uint256 amount) public {
        require(isMember[msg.sender] == true, "Must be a member to make proposals.");

        // Because Proposal has a nested mapping, we must push an empty struct first,
        // then fill fields through a storage reference.
        proposals.push();
        Proposal storage p = proposals[proposals.length - 1];

        p.recipient = recipient;
        p.amount = amount;
        p.yesVotes = 0;
        p.noVotes = 0;
        p.executed = false;
    }

    // Vote on a proposal (members only, one vote per member)
    // choice: true = YES, false = NO
    function voting(uint256 proposalId, bool choice) public {
        require(proposalId < proposals.length, "This proposal doesn't exist.");
        require(isMember[msg.sender] == true, "Must be a member to vote.");
        require(proposals[proposalId].executed == false, "Proposal already executed.");
        require(!proposals[proposalId].hasVoted[msg.sender], "Cannot vote more than once.");

        proposals[proposalId].hasVoted[msg.sender] = true;

        if (choice == true) {
            proposals[proposalId].yesVotes += 1;
        } else {
            proposals[proposalId].noVotes += 1;
        }
    }

    // Execute a proposal (permissionless)
    function executeProposal(uint256 proposalId) public {
        require(proposalId < proposals.length, "This proposal doesn't exist.");
        require(proposals[proposalId].executed == false, "Proposal already executed.");
        require(
            proposals[proposalId].yesVotes > proposals[proposalId].noVotes,
            "This proposal is not in favor by the majority."
        );

        reputation[proposals[proposalId].recipient] += proposals[proposalId].amount;
        proposals[proposalId].executed = true;
    }
}
