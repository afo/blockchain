pragma solidity ^0.4.2;

contract DappToken {
    string  public name;
    string  public symbol;
    string  public standard;
    uint256 public decimalPlaces;
    uint256 public totalSupply;
    uint256 public tokenPrice;
    address _owner;
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value
    );

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    mapping(address => string) public name_of_users;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    function DappToken (string _name, string _symbol,string _standard,uint256 _decimalPlaces, uint256 _tokenPrice,uint256 _initialSupply) public {
        name = _name;
        symbol = _symbol;
        standard = _standard;
        decimalPlaces = _decimalPlaces;
        balanceOf[tx.origin] = _initialSupply;
        totalSupply = _initialSupply;
        tokenPrice = _tokenPrice;
        _owner = tx.origin;
    }

    function set_name(string _name) public {
      name_of_users[msg.sender]=_name;
    }

    function get_name() public view returns(string) {
      return name_of_users[msg.sender];
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;

        Transfer(msg.sender, _to, _value);

        return true;
    }

    function buy(address _to,uint256 _value) internal returns (bool success) {
        require(balanceOf[_owner] >= _value);
        balanceOf[_owner] -= _value;
        balanceOf[_to] += _value;

        Transfer(msg.sender, _to, _value);

        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;

        Approval(msg.sender, _spender, _value);

        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;

        allowance[_from][msg.sender] -= _value;

        Transfer(_from, _to, _value);

        return true;
    }

    function getmybalance()public view returns(uint) {
        return balanceOf[msg.sender];
    }

    function get_token_info() view returns(string,string) {
      return (name,symbol);
    }
//Token Sale**************************

    uint256 public tokensSold;

    event Sell(address _buyer, uint256 _amount);

    function multiply(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    function getcontractbalance() public view returns(uint256) {
        return this.balance;
    }

    function buyTokens(uint256 _numberOfTokens) public payable {
        require(msg.value >= multiply(_numberOfTokens, tokenPrice));
        require(balanceOf[msg.sender]+_numberOfTokens<=1000);
        require(this.balanceOf(_owner) >= _numberOfTokens);
        require(buy(msg.sender, _numberOfTokens));
        tokensSold += _numberOfTokens;

        Sell(msg.sender, _numberOfTokens);
    }

    function endSale() public {
        require(msg.sender == _owner);
        require(transfer(_owner, this.balanceOf(this)));

        // Just transfer the balance to the admin
        _owner.transfer(address(this).balance);
    }


// voting contract **************************
struct Proposal {
    string title;
    uint voteCountPos;
    uint voteCountNeg;
    uint voteCountAbs;
    mapping (address => Voter) voters;
    address[] votersAddress;
}

struct Voter {
    uint value;
    bool voted;
}

Proposal[] public proposals;

event CreatedProposalEvent();
event CreatedVoteEvent();

function getNumProposals() public view returns (uint) {
    return proposals.length;
}

function getProposal(uint proposalInt) public view returns (uint, string, uint, uint, uint, address[]) {
    if (proposals.length > 0) {
        Proposal storage p = proposals[proposalInt]; // Get the proposal
        return (proposalInt, p.title, p.voteCountPos, p.voteCountNeg, p.voteCountAbs, p.votersAddress);
    }
}

function addProposal(string title) public returns (bool) {
    Proposal memory proposal;
    CreatedProposalEvent();
    proposal.title = title;
    proposals.push(proposal);
    return true;
}

function vote(uint proposalInt, uint voteValue) public returns (bool) {
    require(balanceOf[msg.sender]>=50);
    balanceOf[msg.sender]-=50;
    balanceOf[_owner]+=50;
    if (proposals[proposalInt].voters[msg.sender].voted == false) { // check duplicate key
        require(voteValue == 1 || voteValue == 2 || voteValue == 3); // check voteValue
        Proposal storage p = proposals[proposalInt]; // Get the proposal
        if (voteValue == 1) {
            p.voteCountPos += 1;
        } else if (voteValue == 2) {
            p.voteCountNeg += 1;
        } else {
            p.voteCountAbs += 1;
        }
        p.voters[msg.sender].value = voteValue;
        p.voters[msg.sender].voted = true;
        p.votersAddress.push(msg.sender);
        CreatedVoteEvent();
        return true;
    } else {
        return false;
    }
}

// lottery ******************************
uint secretnumber;
address[] guessedplayers;
uint[] guesses;
address[] winnerslist;

mapping (address => uint) playerstoguess;

mapping (address => uint) votestatus;
function select_number(uint num) public {
  require(msg.sender==_owner);
    secretnumber = num;
}

function noofguess() public view returns(uint) {
  return guesses.length;
}

function submit_guess(uint num) public {
  require(votestatus[msg.sender]!=1);
  guesses.push(num);
  guessedplayers.push(msg.sender);
  playerstoguess[msg.sender]=num;
  votestatus[msg.sender]=1;
}

function select_winner(address[] _winnerslist) public {
  require(msg.sender==_owner);
  winnerslist=_winnerslist;
}

function showwinners()public view returns(address[]) {
  return winnerslist;
}

function get_all_players() public view returns(address[],uint[],uint) {
  return (guessedplayers,guesses,secretnumber);
}

function showwinnernames(address player) public view returns(address,string) {
  return(player,name_of_users[player]);
}

function showguess(address player) public view returns(uint) {
  return playerstoguess[player];
}


}

contract Factory {
  address public temp;

  function view_con_add() public view returns(address) {
    return temp;
  }

  function make(string __name, string __symbol, string __standard,uint256 __decimalPlaces, uint256 __tokenPrice,uint256 __totalSupply) public {
    DappToken d = new DappToken(__name,__symbol,__standard,__decimalPlaces,__tokenPrice,__totalSupply);
    temp=address(d);
  }
}
