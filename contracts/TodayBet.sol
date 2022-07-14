// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

contract TodayBet {
    address payable public owner;
    struct Player {
        address payable _address;
        uint _amount;
    }
    mapping (uint => mapping(uint => Player[])) public rooms;
    mapping (uint => mapping(uint => bool)) public isOpen;
    mapping (uint => uint) public pots;

    constructor() {
        owner = payable(msg.sender);
    }

    function openRoom(uint roomId, uint caseId) public payable {
        Player memory p = Player(payable(msg.sender), msg.value);
        rooms[roomId][caseId].push(p);
        isOpen[roomId][caseId] = true;
        pots[roomId] += msg.value;
    }

    function endRoom(uint roomId, uint caseId) public payable {
        require(isOpen[roomId][caseId], "Already Finished!") ;
        uint potAmount = pots[roomId];
        uint feeAmount = potAmount * 5 / 100;
        potAmount -= feeAmount;

        uint caseAmount = balanceOfCase(roomId, caseId);
        uint payAmount;
        for (uint i=0; i<rooms[roomId][caseId].length; i++) {
            uint votedAmount = rooms[roomId][caseId][i]._amount;
            payAmount = potAmount * votedAmount / caseAmount;
            rooms[roomId][caseId][i]._address.transfer(payAmount);
        }
        isOpen[roomId][caseId] = false;

        owner.transfer(address(this).balance);
    }

    function balanceOfCase(uint roomId, uint caseId) public view returns (uint) {
        uint inPot;
        for (uint i=0; i<rooms[roomId][caseId].length; i++) {
            inPot += rooms[roomId][caseId][i]._amount;
        }
        return inPot;
    }
}
