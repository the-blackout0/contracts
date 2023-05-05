// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract NonTradableNFTs is ERC721URIStorage {
    using Counters for Counters.Counter;
    using Strings for uint256;

    Counters.Counter private _tokenIds;
    mapping(address => bool) private _hasMinted;
    string private _baseURI;
    uint256 private constant NUM_NFTS = 5;

    constructor(string memory baseURI) ERC721("NonTradableNFTs", "NTNFT") {
        _baseURI = baseURI;
    }

    function mint() public {
        require(!_hasMinted[msg.sender], "You have already minted an NFT");

        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(msg.sender, newItemId);

        uint256 nftIndex = random(NUM_NFTS) + 1;
        _setTokenURI(newItemId, string(abi.encodePacked(_baseURI, "/", nftIndex.toString())));

        _hasMinted[msg.sender] = true;
    }

    function random(uint256 upperBound) private view returns (uint256) {
        uint256 randomness = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender)));
        return randomness % upperBound;
    }

    function _beforeTokenTransfer(address from, address to, uint256 firstTokenId, uint256 batchSize) internal virtual override {
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);

        // Prevent transfers to make the NFT non-tradable
        require(from == address(0), "NFTs in this collection are non-tradable");
    }
}
