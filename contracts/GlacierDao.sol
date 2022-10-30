pragma solidity ^0.8.7;

contract GlacierDao {

    struct Repo {
        string url;
        string dealId;
        string pieceCid;
        address spAddress;
        uint numberOfVotes;
        bool stored;
        bool accepted;
        uint yesVotes;
        uint noVotes;
        bool isValue;
    }

    struct Member {
        address addr;
        uint availableVotes;
        uint votingPower;
        bool isValue;
    }

    //Repo[] public acceptedRepos;
    //Member[] public daoMembers;

    mapping(address => Member) public daoMembers;
    mapping(string => Repo) public repos;
    uint public currentEpoch;
    
    /*
    epochStage
    0 - Users fund DAO
    1 - Repo submissions and voting, 
    2 - SP submissions, 
    3 - DAO vote to accept SP submissions,
    4 - Epoch ungoing, SPs can start claiming rewards
    5 - Epoch ends 
    */
 
    uint public epochStage; 

    uint public totalVotes;
    address public admin;

    constructor() {
        admin = msg.sender;
       //Member memory newMember = Member({addr: msg.sender, availableVotes: 0, isValue: true});
       //daoMembers[msg.sender] = newMember;
       //daoMembers.push(newMember);
   }

   // Admin functions
   function adminAdvanceEpoch() public isAdmin{
       currentEpoch+=1;
   }

   function adminAdvanceStage() public isAdmin{
       epochStage+=1;
   }

   modifier isAdmin() {
       require(msg.sender == admin);
       _;
   }


    // Stage 0
    function joinDao() public payable  {
        require(epochStage == 0,"Incorrect stage for joinDao, wait for next Epoch");
        Member memory newMember = Member({addr: msg.sender, availableVotes: msg.value, votingPower: msg.value, isValue: true});
        totalVotes+=msg.value;
        daoMembers[msg.sender] = newMember;
    }

  /*  function leaveDao() public  isDaoMember{
            //address payable receiver = address(msg.sender)
            uint votes = daoMembers[msg.sender].availableVotes;
            payable(msg.sender).transfer(votes);
            totalVotes-=votes;
            delete daoMembers[msg.sender];
    }*/

    // Stage 1
    function voteForRepo(string memory url) public isDaoMember {
        require(epochStage == 1,"Incorrect stage for voteForRepo");
        if(repos[url].isValue){
            repos[url].numberOfVotes+= daoMembers[msg.sender].availableVotes;
            
            // for now, members cast all their votes in 1 repo
            // this can be improved, with quadratic voting
            daoMembers[msg.sender].availableVotes = 0;
            if(repos[url].numberOfVotes > totalVotes/2){
                repos[url].accepted = true;
            }
        } else {
            Repo memory newRepo = Repo(
                {
                    numberOfVotes: daoMembers[msg.sender].availableVotes, 
                    url: url, 
                    isValue: true,
                    dealId: "",
                    pieceCid: "",
                    spAddress:address(0),
                    stored: false,
                    accepted: false,
                    yesVotes:0,
                    noVotes:0
                }
            );
            repos[url] = newRepo;
        }
    }

    // Stage 2
    function minerSubmission (string memory url, string memory dealId, string memory pieceCid) public {
        require(epochStage == 2,"Incorrect stage for minerSubmission");
        Repo memory targetRepo = repos[url];
        if(targetRepo.isValue){
            targetRepo.dealId = dealId;
            targetRepo.pieceCid = pieceCid;
            targetRepo.stored = true;    
            targetRepo.spAddress = msg.sender;
        }
        repos[url] = targetRepo;
    }

    // Stage 3
    function voteForMinerSubmission(string memory url, bool acceptSubmission) public isDaoMember {  
        require(epochStage == 3,"Incorrect stage for voteForMinerSubmission");
        if(repos[url].isValue){
            if(acceptSubmission){
                repos[url].yesVotes+= daoMembers[msg.sender].votingPower;
            } else {
                repos[url].noVotes+= daoMembers[msg.sender].votingPower;
            }
        }
    }

    // Stage 5
    function claimReward(string memory url) public {
        require(epochStage == 5,"Incorrect stage for claimReward");
        Repo memory targetRepo = repos[url];

        require(targetRepo.yesVotes > targetRepo.noVotes, "This deal has not been accepted by the DAO");

        bool isDealValid = isDealStillValid(targetRepo.dealId, targetRepo.pieceCid);
        require(isDealValid, "The deal is no longer valid");

        payable(targetRepo.spAddress).transfer(targetRepo.numberOfVotes);




    }

    function isDealStillValid(string memory dealId, string memory pieceCid) public returns (bool) {
        // this is the part that needs to be linked to filecoin
        return true;
    }
    
    
   

    modifier isDaoMember() {
        if(daoMembers[msg.sender].isValue){
            _;
        }
    }

}
