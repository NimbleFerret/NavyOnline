// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../UpgradableEntity.sol";
import "../NVYGameLibrary.sol";

contract Island is UpgradableEntity {
    mapping(uint256 => NVYGameLibrary.IslandStats) public idToIslands;

    bytes32 public constant CAPTAIN_ROLE = keccak256("CAPTAIN_ROLE");

    constructor() public ERC721("ISL", "NVYISL") {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);

        levelToUpgrade[1] = NVYGameLibrary.UpgradeRequirementsByLevel(
            100,
            1150,
            10120
        );
        levelToUpgrade[2] = NVYGameLibrary.UpgradeRequirementsByLevel(
            100,
            1150,
            10120
        );
        levelToUpgrade[3] = NVYGameLibrary.UpgradeRequirementsByLevel(
            100,
            1150,
            10120
        );
    }

    function grantIsland(
        address player,
        NVYGameLibrary.IslandStats memory island,
        string memory tokenURI
    ) external onlyRole(NVY_BACKEND) {
        uint256 tokenId = grantNFT(player, tokenURI);
        idToIslands[tokenId] = island;
    }

    // Upgrades

    function updateIsland(
        uint256 islandId,
        NVYGameLibrary.IslandStats memory island,
        string memory newMetadataURI
    ) external onlyRole(NVY_BACKEND) {
        idToIslands[islandId] = island;
        _setTokenURI(islandId, newMetadataURI);
    }

    function tryUpgrade(uint256 islandId) external {
        require(
            ERC721.ownerOf(islandId) == msg.sender,
            "Only owner can upgrade"
        );

        uint256 nextLevel = idToEntityLevel[islandId] + 1;

        require(
            nextLevel <= NVYGameLibrary.islandMaxLevel,
            "Max level already reached"
        );

        NVYGameLibrary.UpgradeRequirementsByLevel memory req = levelToUpgrade[
            nextLevel
        ];

        uint256 reqNvy = req.nvy * 10**18;
        uint256 reqAks = req.aks * 10**18;

        require(nvyToken.balanceOf(msg.sender) >= reqNvy, "Not enought NVY");
        require(aksToken.balanceOf(msg.sender) >= reqAks, "Not enought AKS");

        nvyToken.burn(reqNvy);
        aksToken.burn(reqAks);

        emit UpgradeEntity(msg.sender, islandId);
    }

    // ---------------------------------------
    // Mining
    // ---------------------------------------

    function startMining(uint256 islandId) external {
        require(ERC721.ownerOf(islandId) == msg.sender, "Only owner can mine");
        NVYGameLibrary.IslandStats memory island = idToIslands[islandId];
        require(!island.mining, "Mining already started");

        island.miningStartedAt = block.timestamp;
        island.mining = true;

        idToIslands[islandId] = island;
    }

    function collectRewards(uint256 islandId) external {
        require(
            ERC721.ownerOf(islandId) == msg.sender,
            "Only owner can collect rewards"
        );
        NVYGameLibrary.IslandStats memory island = idToIslands[islandId];
        require(island.mining, "Mining must be started first");
        require(
            island.miningStartedAt + island.miningDurationSeconds <
                block.timestamp,
            "Mining is not finished yet"
        );

        island.miningStartedAt = 0;
        island.mining = false;

        idToIslands[islandId] = island;

        nvyToken.mintIslandRewardByIsland(msg.sender, island.miningRewardNVY);
    }

    //

    function addMiner(uint256 islandId) external onlyRole(CAPTAIN_ROLE) {
        idToIslands[islandId].currMiners += 1;
    }

    function removeMiner(uint256 islandId) external onlyRole(CAPTAIN_ROLE) {
        idToIslands[islandId].currMiners -= 1;
    }

    // ---------------------------------------
    // Admin functions
    // ---------------------------------------

    function addCaptainAddress(address addr)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        require(
            !hasRole(CAPTAIN_ROLE, addr),
            "Nvy backend address already added."
        );
        _grantRole(CAPTAIN_ROLE, addr);
    }

    function removeCaptainAddress(address addr)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        require(
            !hasRole(CAPTAIN_ROLE, addr),
            "Address is not a recognized NVY backend."
        );
        _revokeRole(CAPTAIN_ROLE, addr);
    }
}
