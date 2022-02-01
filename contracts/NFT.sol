// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
//includes a function called setTokenURI
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFT is ERC721URIStorage {
    //easy to use standard for incrementing
    using Counters for Counters.Counter;
    //to keep track/increment token IDs
    Counters.Counter private _tokenIds;

    //the address of the marketplace where the NFT will be interacting with
    address contractAddress;

    constructor(address marketplaceAddress) ERC721("Metaverse Tokens", "METT") {
        contractAddress = marketplaceAddress;
    }

    //function to mint new NFTs
    function createToken(string memory tokenURI) public returns (uint256) {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();

        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);

        //allow marketplace to transact this token b/w users
        setApprovalForAll(contractAddress, true);

        return newItemId;
    }
}
