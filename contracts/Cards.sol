// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./Packs.sol";

// Second NFT Collection
contract Cards is ERC721URIStorage {
    using Counters for Counters.Counter;
    using Strings for uint256;

    Counters.Counter private _tokenIds;

    Packs private _collectionOneContract;
    string private _collectionBaseURI;

    enum CollectionTwoNftType { X, Y }
    mapping(uint256 => uint256) public chances;

    constructor(address collectionOneAddress, string memory baseURI) ERC721("CollectionTwo", "CTWO") {
        _collectionOneContract = Packs(collectionOneAddress);
        _collectionBaseURI = baseURI;

        // Set the chances for each NFT type from CollectionOne
        // Type1: 50% chance of getting X, 50% chance of getting Y
        chances[uint256(Packs.NftType.Type1)] = 50;

        // Type2: 70% chance of getting X, 30% chance of getting Y
        chances[uint256(Packs.NftType.Type2)] = 70;

        // Type3: 20% chance of getting X, 80% chance of getting Y
        chances[uint256(Packs.NftType.Type3)] = 20;
    }

    function mint(uint256 tokenIdFromCollectionOne) public {
        require(_collectionOneContract.ownerOf(tokenIdFromCollectionOne) == msg.sender, "Caller is not owner of the NFT from CollectionOne");

        // Get the NFT type from CollectionOne
        Packs.NftType nftType = Packs.NftType(tokenIdFromCollectionOne % 3);

        // Determine the NFT type in CollectionTwo based on the chances
        CollectionTwoNftType collectionTwoNftType = _getCollectionTwoNftType(nftType);

        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, string(abi.encodePacked(_collectionBaseURI, "/", uint256(collectionTwoNftType).toString())));

        // Burn the NFT from CollectionOne
        _collectionOneContract._burnFor(tokenIdFromCollectionOne);
    }

    function _getCollectionTwoNftType(Packs.NftType nftType) private view returns (CollectionTwoNftType) {
        uint256 randomNumber = random(100);
        uint256 chance = chances[uint256(nftType)];

        if (randomNumber < chance) {
            return CollectionTwoNftType.X;
        } else {
            return CollectionTwoNftType.Y;
        }
    }

     function random(uint256 upperBound) private view returns (uint256) {
        uint256 randomness = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender)));
        return randomness % upperBound;
    }

    function _burn(uint256 tokenId) internal override(ERC721URIStorage) {
        super._burn(tokenId);
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal override(ERC721URIStorage) {
        super._setTokenURI(tokenId, _tokenURI);
    }
}
