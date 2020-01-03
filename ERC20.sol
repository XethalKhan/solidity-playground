pragma solidity > 0.5.0;

/**
 * @title ERC20
 * @dev Token that implements ERC-20
 */
contract ERC20{
    //Name of ERC20 token
    string private _name;
    string private _symbol;
    uint8 private _decimal;
    uint256 private _totalSupply;
    
    mapping(address => uint256) _balance;
    mapping(address => mapping(address => uint256)) _allowed;
    
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    
    /// @author Petar Bojovic
    /// @notice Token creation
    constructor(
        string memory name,
        string memory symbol,
        uint8 decimal,
        uint256 totalSupply
    ) public {
        _name = name;
        _symbol = symbol;
        _decimal = decimal;
        _totalSupply = totalSupply * (10 ** uint256(_decimal));
        _balance[msg.sender] = _totalSupply;
    }
    
    /// @author Petar Bojovic
    /// @notice Token full name
    /// @dev Implementation of ERC-20 token name, not defined in ERC-20 standard
    /// @return string representing token fully qualified name
    function getName()
        public
        view
        returns (string memory)
    {
        return _name;
    }
    
    /// @author Petar Bojovic
    /// @notice Token symbol
    /// @dev Implementation of ERC-20 token symbol, not defined in ERC-20 standard
    /// @return string representing token symbol
    function getSymbol()
        public
        view
        returns (string memory)
    {
        return _symbol;
    }
    
    /// @author Petar Bojovic
    /// @notice Decimal places of token
    /// @dev Implementation of ERC-20 decimal places, not defined in ERC-20 standard
    /// @return uint8 representing number of decimal places ERC-20 token
    function getDecimal() 
        public 
        view 
        returns (uint8)
    {
        return _decimal;
    }
    
    /// @author Petar Bojovic
    /// @notice Total supply of token
    /// @dev Implementation of ERC-20 totalSupply function
    /// @return uint256 representing total supply of ERC-20 token
    function totalSupply() 
        public 
        view 
        returns (uint256)
    {
        return _totalSupply;
    }
    
    /// @author Petar Bojovic
    /// @notice Balance of address
    /// @dev Implementation of ERC-20 balanceOf function
    /// @param _owner address The address which owns the funds
    /// @return uint256 representing balance of _owner address
    function balanceOf(address _owner) 
        public 
        view 
        returns (uint256)
    {
        return _balance[_owner];
    }
    
    /// @author Petar Bojovic
    /// @notice Number of tokens owner allowed to spender to withdraw
    /// @dev Implementation of ERC-20 allowance function
    /// @param _owner address The address which owns the funds.
    /// @param _spender address The address which will spend the funds.
    /// @return uint256 representing amounts of tokens still available to _spender address
    function allowance(
        address _owner,
        address _spender
    )
        public
        view
        returns (uint256)
    {
        return _allowed[_owner][_spender];
    }
    
    /// @author Petar Bojovic
    /// @notice Transfer of tokens
    /// @dev Implementation of ERC-20 transfer function
    /// @param _to address The address which will receive funds.
    /// @param _value uint256 Amount to be transfered.
    /// @return bool Is transfer successfull.
    function transfer(
        address _to, 
        uint256 _value
    ) 
        public 
        returns (bool)
    {
        require(_value <= _balance[msg.sender]);
        require(_to != address(0));
        
        _balance[msg.sender] = _balance[msg.sender] - _value;
        _balance[_to] = _balance[_to] + _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    
    /// @author Petar Bojovic
    /// @notice Approval of tokens
    /// @dev Implementation of ERC-20 approve function
    /// @param _spender address The address to which msg.sender approves funds.
    /// @param _value uint256 Amount to be approved.
    /// @return bool Is approval successfull.
    function approve(
        address _spender, 
        uint256 _value
    )
        public
        returns (bool)
    {
        require(_spender != address(0));
        
        _allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    /// @author Petar Bojovic
    /// @notice Transfer of approved tokens
    /// @dev Implementation of ERC-20 transferFrom function
    /// @param _from address The address from which approves funds are transfered.
    /// @param _to address The address to which approves funds are transfered.
    /// @param _value uint256 Amount of approved funds transfered.
    /// @return bool Is transfer successfull.
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
        public
        returns (bool)
    {
        require(_value <= _balance[_from]);
        require(_value <= _allowed[_from][msg.sender]);
        require(_to != address(0));
        
        _balance[_from] = _balance[_from] - _value;
        _balance[_to] = _balance[_to] + _value;
        _allowed[_from][msg.sender] = _allowed[_from][msg.sender] - _value;
        emit Transfer(_from, _to, _value);
        return true;
    }
}