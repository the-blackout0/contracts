// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

// First NFT Collection
contract Packs is ERC721URIStorage {
    using Counters for Counters.Counter;
    using Strings for uint256;

    Counters.Counter private _tokenIds;

    IERC20 public paymentToken;
    mapping(uint256 => uint256) public typePrices;
    string private _collectionBaseURI;

    address private _collectionTwoAddress;

    enum NftType { Type1, Type2, Type3 }

    constructor(address _paymentToken, string memory baseURI) ERC721("CollectionOne", "CONE") {
        paymentToken = IERC20(_paymentToken);
        _collectionBaseURI = baseURI;

        // Set the token prices for each NFT type
        typePrices[uint256(NftType.Type1)] = 0.05 ether;
        typePrices[uint256(NftType.Type2)] = 0.1 ether;
        typePrices[uint256(NftType.Type3)] = 0.2 ether;
    }

    function setCollectionTwoAddress(address collectionTwoAddress) external {
        require(_collectionTwoAddress == address(0), "CollectionTwo address has already been set");
        _collectionTwoAddress = collectionTwoAddress;
    }

    function mint(NftType nftType) public {
        uint256 price = typePrices[uint256(nftType)];
        require(price > 0, "Invalid NFT type");

        // Transfer ERC20 tokens from user to this contract as payment
        require(paymentToken.transferFrom(msg.sender, address(this), price), "Token transfer failed");

        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, string(abi.encodePacked(_collectionBaseURI, "/", uint256(nftType).toString())));
    }

    function burn(uint256 tokenId) public {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Caller is not owner nor approved");
        _burn(tokenId);
    }

    function _burnFor(uint256 tokenId) external {
        require(msg.sender == _collectionTwoAddress, "Only CollectionTwo contract can call this function");
        _burn(tokenId);
    }
}
