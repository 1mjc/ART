// SPDX-License-Identifier: MIT
pragma solidity  ^0.8.13;

contract StudioContributions { 
    uint256 public constant REVIEW_THRESHOLD = 3;

    struct Contribution{
        address contributor;
        bytes32 metadata;
        bool approved;
    }

    mapping(bytes32 => Contribution[]) public contributions;
    mapping(bytes32 => mapping(address => uint256)) public approvedCountByStudio;

    function isReviewer(bytes32 studioId, address user) public view returns (bool) {
        return approvedCountByStudio[studioId][user] >= REVIEW_THRESHOLD;
    }   

}
