pragma solidity ^0.4.24;

import './../node_modules/openzeppelin-solidity/contracts/token/ERC721/ERC721.sol';
import './../node_modules/openzeppelin-solidity/contracts/token/ERC721/ERC721BasicToken.sol';

contract Holy is ERC721, ERC721BasicToken {
    
    constructor (address player1, address player2) public { 
        _mintAmount(player1, 20);
        _mintAmount(player2, 20);
    }

    // Card cost
    uint256 public cost = 1 finney;

    // Nonce used to card generation
    uint256 internal nonce = 1;

    // Maximum amount of cards
    uint256 internal maxCards = 1000000;

    // Number of allocated tokens including wrapped boosters
    uint256 internal allocatedTokens_ = 0;

    // Token name
    string internal name_ = "Holy";

    // Token symbol
    string internal symbol_ = "HOLY";

    // Base tokenURI
    string internal tokenURI_ = "https://corsarium.playdarkwinds.com/cards/00000.json";

    // Base uriIndex to modify the URI
    uint256 internal uriIndex_ = 0;

    // Mapping from owner to list of owned token IDs
    mapping(address => uint256[]) internal ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) internal ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] internal allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) internal allTokensIndex;

    // Mapping to card prototype
    mapping(uint256 => uint256) internal tokenToCardIndex;

    // Mapping to wrapped booster packs
    mapping(address => uint256[]) internal wrappedBoosters;

    // @dev don't accept straight eth (normally comes with low gas)
    function () public payable {
        revert();
    }

     
    /**
     * @dev gets the number of allocated tokens
     * @return uint256 of the number of allocated tokens
     */
    function allocatedTokens() public view returns (uint256) {
        return allocatedTokens_;
    }

    /**
     * @dev Gets the token name
     * @return string representing the token name
     */
    function name() external view returns (string _name) {
        return _name = name_;
    }

    /**
     * @dev Gets the token symbol
     * @return string representing the token symbol
     */
    function symbol() external view returns (string _symbol) {
        return _symbol = symbol_;
    }

    /**
     * @dev Gets the base tokenURI
     * @return string, uint256 representing the tokenURI and tokenURI index
     */
    function tokenUri() public view returns (string, uint256) {
        return (tokenURI_, uriIndex_);
    }

    /**
     * @dev Returns an URI for a given token ID
     * @dev Throws if the token ID does not exist. May return an empty string.
     * @param _tokenId uint256 ID of the token to query
     */
    function tokenURI(uint256 _tokenId) public view returns (string) {
        require(_tokenId < allTokens.length);
        bytes memory tokenUriBytes = bytes(tokenURI_);
        tokenUriBytes[uriIndex_]              = byte(48 + (tokenToCardIndex[_tokenId] / 10000) % 10);
        tokenUriBytes[uriIndex_ + uint256(1)] = byte(48 + (tokenToCardIndex[_tokenId] / 1000) % 10);
        tokenUriBytes[uriIndex_ + uint256(2)] = byte(48 + (tokenToCardIndex[_tokenId] / 100) % 10);
        tokenUriBytes[uriIndex_ + uint256(3)] = byte(48 + (tokenToCardIndex[_tokenId] / 10) % 10);
        tokenUriBytes[uriIndex_ + uint256(4)] = byte(48 + (tokenToCardIndex[_tokenId] / 1) % 10);
        return string(tokenUriBytes);
    }

    /**
     * @dev Gets the token ID at a given index of the tokens list of the requested owner
     * @param _owner address owning the tokens list to be accessed
     * @param _index uint256 representing the index to be accessed of the requested tokens list
     * @return uint256 token ID at the given index of the tokens list owned by the requested address
     */
    function tokenOfOwnerByIndex(address _owner, uint256 _index) public view returns (uint256) {
        require(_index < balanceOf(_owner));
        return ownedTokens[_owner][_index];
    } 

    /**
     * @dev Gets the total amount of tokens stored by the contract
     * @return uint256 representing the total amount of tokens
     */
    function totalSupply() public view returns (uint256) {
        return allTokens.length;
    }

    /**
     * @dev Gets the token ID at a given index of all the tokens in this contract
     * @dev Reverts if the index is greater or equal to the total number of tokens
     * @param _index uint256 representing the index to be accessed of the tokens list
     * @return uint256 token ID at the given index of the tokens list
     */
    function tokenByIndex(uint256 _index) public view returns (uint256) {
        require(_index < totalSupply());
        return allTokens[_index];
    }

    /**
     * @dev Function to set the overall tokenURI_ and uriIndex_
     * @param _uri string URI to assign
     * @param _uriIndex URI index to assign
     */
    function setTokenURI(string _uri, uint256 _uriIndex) public {
        tokenURI_ = _uri;
        uriIndex_ = _uriIndex;
    }

    /**
     * @dev Internal function to add a token ID to the list of a given address
     * @param _to address representing the new owner of the given token ID
     * @param _tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function addTokenTo(address _to, uint256 _tokenId) internal {
        super.addTokenTo(_to, _tokenId);
        uint256 length = ownedTokens[_to].length;
        ownedTokens[_to].push(_tokenId);
        ownedTokensIndex[_tokenId] = length;
    }  

    /**
     * @dev Internal function to remove a token ID from the list of a given address
     * @param _from address representing the previous owner of the given token ID
     * @param _tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    /* function removeTokenFrom(address _from, uint256 _tokenId) internal {
        super.removeTokenFrom(_from, _tokenId);

        uint256 tokenIndex = ownedTokensIndex[_tokenId];
        uint256 lastTokenIndex = ownedTokens[_from].length.sub(1);
        uint256 lastToken = ownedTokens[_from][lastTokenIndex];

        ownedTokens[_from][tokenIndex] = lastToken;
        ownedTokens[_from][lastTokenIndex] = 0;
        // Note that this will handle single-element arrays. In that case, both tokenIndex and lastTokenIndex are going to
        // be zero. Then we can make sure that we will remove _tokenId from the ownedTokens list since we are first swapping
        // the lastToken to the first position, and then dropping the element placed in the last position of the list

        ownedTokens[_from].length--;
        ownedTokensIndex[_tokenId] = 0;
        ownedTokensIndex[lastToken] = tokenIndex;
    } */

    /**
     * @dev Internal function to mint a new token
     * @dev Reverts if the given token ID already exists
     * @param _to address the beneficiary that will own the minted token
     * @param _tokenId uint256 ID of the token to be minted by the msg.sender
     * @param _prototypeId uint256 ID of the prototype of the token to be minted by the msg.sender
     */
    function _mint(address _to, uint256 _tokenId, uint256 _prototypeId) internal {
        // Make sure we don't allocate more tokens then max, tokens start at index 0
        require(allTokens.length < maxCards);

        super._mint(_to, _tokenId);

        allTokensIndex[_tokenId] = allTokens.length;

        // Add the custom prototype to the tokenToCardIndex
        tokenToCardIndex[allTokens.length] = _prototypeId;

        // This updates the length / total supply
        allTokens.push(_tokenId);
    }

    /**
      * @dev view to get all tokenIds of a specific user
      * @param _owner address of the owner to get tokens for
      * @return uint256[] tokenIds of owner's tokens
      */
    function tokensOfOwner(address _owner) external view returns (uint256[]) {
        return ownedTokens[_owner];
    } 

    /**
     * @dev function to update the cost of a single token
     * @param _newCost the new cost of a card in wei
     */
    /* function changeCardCost(uint256 _newCost) public {
        cost = _newCost;
    }
 */
    /**
     * @dev function to give a user cards before the contract is locked
     *      only used the whenNotLocked modifier so that you can pause the contract and still add cards
     *      before locking.
     * @param _to address to give a card
     * @param _prototypeIds array of prototype ids to give a user
     */
    function giveUserCards(address _to, uint256[] _prototypeIds) external {
        require(_to != address(0));
        require((allocatedTokens_ + _prototypeIds.length) < maxCards);
        for (uint256 i = 0; i < _prototypeIds.length; i++) {
            _mint(_to, allTokens.length, _prototypeIds[i]);
        }
        allocatedTokens_ += _prototypeIds.length;
    }

   
    /**
      * @dev generates the prototypeIds for the given amount of cards
      * @param _to address to mint the prototype ids for
      * @param _amount uint256 the amount of cards to generate
      */
    function _mintAmount(address _to, uint256 _amount) internal {
        uint256 blockNumber = block.timestamp;
        for (uint256 i = 0; i < _amount; i++) {
            uint256 prototypeId = uint256(keccak256(abi.encodePacked(i + nonce + blockNumber))) % 50;
            if (i % 5 == 1) {
                prototypeId += (nonce % 50);
            }
            _mint(_to, allTokens.length, prototypeId);
        }
        nonce += _amount;
    }

    /**
     * @dev View to get the prototype of a cards for an owner
     * @param _tokenId the tokenId to get the prototype of
     * @return uint256 prototypeId at the tokenId
     */
     function getCard(uint _tokenId) public view returns (uint256) {
        require(_tokenId < allTokens.length);
        // In the case that there aren't sequential cardIds in the future
        uint256 tokenIndex = allTokensIndex[_tokenId];
        return tokenToCardIndex[tokenIndex];
    }
 
    /**
     * @dev View to get the prototypes of cards for an owner
     * @param _owner address of which to get the tokens list
     * @return uint256 token ID at the given index of the tokens list
     */
     function cardsOfOwner(address _owner) external view returns (uint256[]) {
        uint256 totalLength = ownedTokens[_owner].length;
        uint256[] memory cardPrototypes = new uint256[](totalLength);
        for(uint256 i = 0; i < totalLength; i++) {
            uint256 index = ownedTokens[_owner][i];
            cardPrototypes[i] = getCard(index);
        }
        return cardPrototypes;
    } 

    /**
     * @dev view to get the prototypes of all cards
     * @return uint256[] prototypes of all cards
     */
    function cardSupply() external view returns (uint256[]) {
        uint256 totalLength = allTokens.length;
        uint256[] memory cardPrototypes = new uint256[](totalLength);
        for(uint256 i = 0; i < allTokens.length; i++) {
            cardPrototypes[i] = getCard(allTokens[i]);
        }
        return cardPrototypes;
    }
}
