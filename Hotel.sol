// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

//this contract keeps the tract of the entire activity happening in
//in  the particular hotel
contract Hotels{

    address payable tenent;
    address payable landlord;

    uint256 public no_of_rooms = 0;
    uint256 public no_of_agreement = 0;
    uint256 public no_of_rent = 0;

    struct Room{
        uint256 roomId;
        uint256 agreementId;
        string roomname;
        string roomAddress;
        uint256 rentPerMonth;
        uint256 SecurityDeposit;
        uint256 timestamp;
        bool vacent;
        address payable landlord;
        address payable currentTenant;
    }
    mapping(uint256 => Room) public roomByNumber;

    struct RoomAgreement{
       uint256 roomId;
        uint256 agreementId;
        string roomname;
        string roomAddress;
        uint256 rentPerMonth;
        uint256 SecurityDeposit;
        uint256 lockInPeriod;
        uint256 timestamp;
        address payable landlord;
        address payable currentTenant;
    }
    mapping(uint256 => RoomAgreement) public RoomAgreementByNUmber;

    struct Rent{
        uint256 rentNo;
        uint256 roomId;
        uint256 agreementId;
        string roomname;
        string roomAddress;
        uint256 rentPerMonth;
        uint256 timestamp;
        address payable landlordAddress;
        address payable tenantAddress;
    }
    mapping(uint256 => Rent) public RentByNumner;

    modifier onlyLandLord(uint256 _index){
        require(msg.sender == roomByNumber[_index].landlord,"Only land lord can access this" );
        _;
    }

    modifier notLandLord(uint256 _index){
        require(msg.sender != roomByNumber[_index].landlord,"Only tenant can access this" );
        _;
    }

    modifier OnlyWhileVacent(uint256 _index){
        require(roomByNumber[_index].vacent == true,"Roon is currently occupied");
        _;
    }

    modifier enoughRent(uint256 _index){
        require(msg.value >= uint256(roomByNumber[_index].rentPerMonth),"Not enough ether in your wallet" );
        _;
    }

    modifier sameTanent(uint256 _index){
        require(msg.sender == RoomAgreementByNUmber[_index].currentTenant,"No previous agreement found with you and ");
        _;
    }

    modifier agreementTimeLeft(uint256 _index){
        uint256 _AgreementNo = roomByNumber[_index].agreementId;
        uint256 time = RoomAgreementByNUmber[_AgreementNo].timestamp + RoomAgreementByNUmber[_AgreementNo].lockInPeriod;
        require(now < time, "Agreement already Ended");
        _;
    }

    modifier agreementTimesUp(uint256 _index){
        uint256 _AgreementNo = roomByNumber[_index].agreementId;
        uint256 time = RoomAgreementByNUmber[_AgreementNo].timestamp + RoomAgreementByNUmber[_AgreementNo].lockInPeriod;
        require(now > time, "Time is left for contract to end");
        _;
    }

    modifier RentTimesUp(uint256 _index){
        uint256 time = roomByNumber[_index].timestamp + 30 days;
        require(now >= time,"Time left to pay Rent");
        _;
    }

    
}
