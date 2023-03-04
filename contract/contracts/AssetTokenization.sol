// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./FarmNft.sol";
import "hardhat/console.sol";
import "@chainlink/contracts/src/v0.8/AutomationCompatible.sol";

contract AssetTokenization is AutomationCompatibleInterface{
    address[] farmers; // 農家のアドレスを保存します。
    mapping(address => FarmNft) farmerToNftContract; // 農家のアドレスとデプロイしたFarmNftをマッピングします。

    struct nftContractDetails {
        address farmerAddress;
        string farmerName;
        string description;
        uint256 totalMint;
        uint256 availableMint;
        uint256 price;
        uint256 expirationDate;
    }

    function availableContract(address farmer) public view returns (bool) {
        return address(farmerToNftContract[farmer]) != address(0);
    }

    function addFarmer(address newFarmer) internal {
        for (uint256 index = 0; index < farmers.length; index++) {
            if (newFarmer == farmers[index]) {
                return;
            }
        }
        farmers.push(newFarmer);
    }

    function generateNftContract(
        string memory _farmerName,
        string memory _description,
        uint256 _totalMint,
        uint256 _price,
        uint256 _expirationDate
    ) public {
        address farmerAddress = msg.sender;

        require(
            availableContract(farmerAddress) == false,
            "Your token is already deployed"
        );

        addFarmer(farmerAddress);

        FarmNft newNft = new FarmNft(
            farmerAddress,
            _farmerName,
            _description,
            _totalMint,
            _price,
            _expirationDate
        );

        farmerToNftContract[farmerAddress] = newNft;
    }

    function getNftContractDetails(address farmerAddress)
        public
        view
        returns (nftContractDetails memory)
    {
        require(availableContract(farmerAddress), "not available");

        nftContractDetails memory details;
        details = nftContractDetails(
            farmerToNftContract[farmerAddress].farmerAddress(),
            farmerToNftContract[farmerAddress].farmerName(),
            farmerToNftContract[farmerAddress].description(),
            farmerToNftContract[farmerAddress].totalMint(),
            farmerToNftContract[farmerAddress].availableMint(),
            farmerToNftContract[farmerAddress].price(),
            farmerToNftContract[farmerAddress].expirationDate()
        );

        return details;
    }

    function buyNft(address farmerAddress) public payable {
        require(availableContract(farmerAddress), "Not yet deployed");

        address buyerAddress = msg.sender;
        farmerToNftContract[farmerAddress].mintNFT{value: msg.value}(
            buyerAddress
        );
    }

    function getBuyers() public view returns (address[] memory) {
        address farmerAddress = msg.sender;

        require(availableContract(farmerAddress), "Not yet deployed");

        return farmerToNftContract[farmerAddress].getTokenOwners();
    }

    function getFarmers() public view returns (address[] memory) {
        return farmers;
    }

    // For upkeep that chainlink automation function.
    // Check whether there are expired contracts.
    // If checkUpkeep() returns true, chainlink automatically runs performUpkeep() that follows below.
    function checkUpkeep(
        bytes calldata /* optional data. don't use in this code */
    )
        external
        view
        override
        returns (
            bool upkeepNeeded,
            bytes memory /* optional data. return initial value in this code */
        )
    {
        for (uint256 index = 0; index < farmers.length; index++) {
            address farmer = farmers[index];
            if (!availableContract(farmer)) {
                continue;
            }
            if (farmerToNftContract[farmer].isExpired()) {
                return (true, "");
            }
        }
        return (false, "");
    }

    // For chainlink.
    // Burn expired NFT and delete NFT Contract.
    function performUpkeep(
        bytes calldata /* optional data. don't use in this code */
    ) external override {
        for (uint256 index = 0; index < farmers.length; index++) {
            address farmer = farmers[index];
            if (!availableContract(farmer)) {
                continue;
            }
            if (farmerToNftContract[farmer].isExpired()) {
                farmerToNftContract[farmer].burnNFT();
                delete farmerToNftContract[farmer];
            }
        }
    }
}