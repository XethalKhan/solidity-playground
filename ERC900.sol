pragma solidity > 0.5.0;

import "./ERC20.sol";

/**
 * @title ERC20Token
 * @dev Implementation of ERC-20 token staking
 */
 contract ERC900{
    
    //ERC20 token to be staked
    ERC20 private stakedToken;
    
    //Number of miliseconds for stakes to be locked
    uint256 defaultLockIn;
    
    event Staked(address indexed _user, uint256 _amount, uint256 _total, bytes _data);
    event Unstaked(address indexed _user, uint256 _amount, uint256 _total, bytes _data);
    
    constructor(
        ERC20 _token, 
        uint256 _defaultLockIn
    ) public {
        stakedToken = _token;
        defaultLockIn = _defaultLockIn;
    }
     
    // Struct for personal stakes (i.e., stakes made by address)
    // unlockedTimestamp - when the stake unlocks (in seconds since Unix epoch), unlockedTimestamp = block.timestamp + defaultLockIn in moment of creation
    // actualAmount - the amount of tokens in the stake
    // stakedFor - the address the stake was staked for
    struct Stake {
        uint256 unlockedTimestamp;
        
        uint256 actualAmount;
    }
    
    
    struct StakeContract {
        uint256 totalStakedFor;
        
        mapping(address => Stake) personalStakes;
    }
    
    mapping (address => StakeContract) public stakeHolders;
    
    
    function stake(
        uint256 _amount, 
        bytes memory _data
    ) 
        public {
        
        _createStake(msg.sender, _amount, defaultLockIn, _data);
    
    }
    
    function stakeFor(
        address _user,
        uint256 _amount, 
        bytes memory _data
    ) 
        public {
        
        _createStake(_user, _amount, defaultLockIn, _data);
        
    }
    
    function unstake(
        uint256 _amount,
        bytes memory _data
    )
        public{
            
            _withdrawStake(_amount, _data);        
    }
    
    function totalStakedFor(
        address _address
    ) 
        public 
        view 
        returns (uint256){
        
        return stakeHolders[_address].totalStakedFor;
        
    }
    
    function totalStaked() 
        public 
        view 
        returns (uint256)
    {
        return stakedToken.balanceOf(address(this));       
    }
    
    function token() 
        public 
        view 
        returns (address) {
            
        return address(stakedToken);
        
    }
    
    function _createStake(
        address _address,
        uint256 _amount,
        uint256 _lockInDuration,
        bytes memory _data
    ) 
        private  {
            
        require(stakedToken.transferFrom(_address, address(this), _amount), "Stake required");
        
        stakeHolders[_address].totalStakedFor = stakeHolders[_address].totalStakedFor + _amount;
        
        stakeHolders[msg.sender].personalStakes[_address] = 
            Stake(
                block.timestamp + _lockInDuration,
                _amount
            );
            
        emit Staked(
            _address,
            _amount,
            stakeHolders[_address].totalStakedFor,
            _data
        );
    }
    
    function _withdrawStake(
        uint256 _amount,
        bytes memory _data
    )
        private {
            
        Stake storage personalStake = stakeHolders[msg.sender].personalStakes[msg.sender];
        
        // Check that the current stake has unlocked
        require(
            personalStake.unlockedTimestamp <= block.timestamp,
            "The current stake hasn't unlocked yet"
        );
        
        // Check that the current stake amount matches the unstake amount
        require(
            personalStake.actualAmount == _amount,
            "The unstake amount does not match the current stake"
        );
        
        // Transfer the staked tokens from this contract back to the sender
        // Notice that we are using transfer instead of transferFrom here, so
        //  no approval is needed beforehand.
        require(
            stakedToken.transfer(msg.sender, _amount),
            "Unable to withdraw stake"
        );
        
        stakeHolders[msg.sender].totalStakedFor = stakeHolders[msg.sender].totalStakedFor - personalStake.actualAmount;
        
        personalStake.actualAmount = 0;
        
        emit Unstaked(
            msg.sender,
            _amount,
            stakeHolders[msg.sender].totalStakedFor,
            _data
        );
            
    }
     
 }