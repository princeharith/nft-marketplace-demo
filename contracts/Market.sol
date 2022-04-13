// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
/*Security mechanism, protext certain txn's from hitting function w/ multiple requests, for any 
function that talks to a diff contract
*/
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFTMarket is ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;
    Counters.Counter private _itemsSold;

    //address public tokenaddress = 0x3af79615eB0CDC43FFDe9b79d5D7BEcF0667Fd74;

    //owner makes commission for every txn
    address payable owner;
    uint256 listingPrice = 0.025 ether;

    constructor() {
        //owner is the person deploying this contract
        owner = payable(msg.sender);
    }

    //a struct is like an object/map, value that holds other values
    struct MarketItem {
        uint256 itemId;
        address nftContract;
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }
    //fetch MarketItem when given an ID
    mapping(uint256 => MarketItem) private idToMarketItem;

    //"indexed" parameters for logged events will allow you to search for these events using indexed params
    //as filters
    event MarketItemCreated(
        uint256 indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );

    //tell the front end what listing price is
    function getListingPrice() public view returns (uint256) {
        return listingPrice;
    }

    //function for creating a market item, pass in the contract, it's ID, and listing price
    function createMarketItem(
        address nftContract,
        uint256 tokenId,
        uint256 price
    ) public payable nonReentrant {
        require(price > 0, "Price must be at least 1 wei");
        require(
            msg.value == listingPrice,
            "Price must be equal to listing price"
        );

        //increment the itemIds counter
        _itemIds.increment();
        //set the current item ID
        uint256 itemId = _itemIds.current();

        //POPULATE the market item that corresponds to an item ID
        idToMarketItem[itemId] = MarketItem(
            itemId,
            nftContract,
            tokenId,
            payable(msg.sender),
            //empty address
            payable(address(0)),
            price,
            false
        );

        //transfers the nft contract to this contract, contract will take ownership (address(this))
        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

        emit MarketItemCreated(
            itemId,
            nftContract,
            tokenId,
            msg.sender,
            address(0),
            price,
            false
        );
    }

    function createMarketSale(address nftContract, uint256 itemId)
        public
        payable
        nonReentrant
    {
        uint256 price = idToMarketItem[itemId].price;
        uint256 tokenId = idToMarketItem[itemId].tokenId;

        require(msg.value == price, "Please submit the asking price");

        //transfer the money to the seller
        idToMarketItem[itemId].seller.transfer(msg.value);

        //transfer ownership to msg.sender, or buyer
        IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);

        //updating the mapping
        idToMarketItem[itemId].owner = payable(msg.sender);
        idToMarketItem[itemId].sold = true;

        _itemsSold.increment();

        //commission that is made for the owner of the contract
        payable(owner).transfer(listingPrice);
    }

    function fetchMarketItems() public view returns (MarketItem[] memory) {
        //total no. of items created
        uint256 itemCount = _itemIds.current();
        uint256 unsoldItemCount = _itemIds.current() - _itemsSold.current();
        uint256 currentIndex = 0;

        //an array of MarketItems that is of length unsoldItemCount
        MarketItem[] memory items = new MarketItem[](unsoldItemCount);
        //going through items, finding the unsold ones
        for (uint256 i = 0; i < itemCount; i++) {
            //empty address means item is NOT SOLD
            if (idToMarketItem[i + 1].owner == address(0)) {
                //getting the ID of unsold item
                uint256 currentId = idToMarketItem[i + 1].itemId;
                //setting the currentItem equal to the MarketItem (via the ID)
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        //now we have an array of unsold items
        return items;
    }

    function fetchMyNFTs() public view returns (MarketItem[] memory) {
        uint256 totalItemCount = _itemIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].owner == msg.sender) {
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].owner == msg.sender) {
                uint256 currentId = idToMarketItem[i + 1].itemId;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }

        return items;
    }

    function fetchItemsCreated() public view returns (MarketItem[] memory) {
        uint256 totalItemCount = _itemIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].seller == msg.sender) {
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].seller == msg.sender) {
                uint256 currentId = idToMarketItem[i + 1].itemId;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }

        return items;
    }
}

//0x3af79615eb0cdc43ffde9b79d5d7becf0667fd74
//0x3af79615eB0CDC43FFDe9b79d5D7BEcF0667Fd74
