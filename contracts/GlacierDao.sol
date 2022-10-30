pragma solidity ^0.8.7;

contract DataDAO {

    struct Epoch {
        uint length;


    }

    struct Repo {
        string url;
        string stored;
        string dealId;
        string pieceCid;
        uint numberOfVotes;
        bool accepted;
        bool isValue;
    }

    struct Member {
        address addr;
        uint availableVotes;
        bool isValue;
    }

    //Repo[] public acceptedRepos;
    //Member[] public daoMembers;

    mapping(address => Member) public daoMembers;
    mapping(string => Repo) public repos;

    uint totalVotes;

    constructor() {
       Member memory newMember = Member({addr: msg.sender, availableVotes: 0, isValue: true});
       daoMembers[msg.sender] = newMember;
       daoMembers.push(newMember);
   }

   //function claim(string dealId, string pieceCID) public {}
    
    function isDealStillValid(string dealId) public return bool {
        // filecoin magic 
        // return filecoin.dealIsGood(dealId)
        return false;
        
    }


    function voteForRepo(string memory url) public {
        if(repos[url].isValue){
            repos[url].numberOfVotes+= daoMembers[msg.sender].availableVotes;
            if(repos[url].numberOfVotes > totalVotes/2){
                repos[url].accepted = true;
            }
        }
    }

    
    function joinDao() public payable  {
        Member memory newMember = Member({addr: msg.sender, availableVotes: msg.value, isValue: true});
        totalVotes+=msg.value;
        daoMembers[msg.sender] = newMember;
    }

    function leaveDao() public  isDaoMember{
            //address payable receiver = address(msg.sender)
            uint votes = daoMembers[msg.sender].availableVotes;
            payable(msg.sender).transfer(votes);
            totalVotes-=votes;
            delete daoMembers[msg.sender];
    }

    modifier isDaoMember() {
        if(daoMembers[msg.sender].isValue){
            _;
        }
    }

}
