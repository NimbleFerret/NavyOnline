/* eslint-disable prettier/prettier */
import { v4 as uuidv4 } from 'uuid';
import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Captain, CaptainDocument } from './asset.captain.entity';
import { Island, IslandDocument } from './asset.island.entity';
import { PlayerShipEntity, Ship, ShipDocument, ShipSize, ShipType } from './asset.ship.entity';
import { ShipStatsRange, ShipStatsStep } from '../cronos/cronos.service';
import { Rarity } from '../random/random.entity';
import { RandomService } from '../random/random.service';
import { NftShipGenerator } from '../nft/nft.ship.generator';

@Injectable()
export class AssetService {

    private nftShipGenerator = new NftShipGenerator()

    constructor(
        private randomService: RandomService,
        @InjectModel(Captain.name) private captainModel: Model<CaptainDocument>,
        @InjectModel(Ship.name) private shipModel: Model<ShipDocument>,
        @InjectModel(Island.name) private islandModel: Model<IslandDocument>,
    ) {
    }

    // Captain

    // Ship

    async syncShipIfNeeded(playerShipNFT: PlayerShipEntity) {
        let ship = await this.shipModel.findOne({
            tokenId: playerShipNFT.id
        });
        // Save ship if not exists
        if (!ship) {
            ship = await this.saveNewShip(playerShipNFT.id, ShipType.COMMON, playerShipNFT);
        } else {
            // Update ship stats
            ship.hull = playerShipNFT.hull;
            ship.armor = playerShipNFT.armor;
            ship.maxSpeed = playerShipNFT.maxSpeed;
            ship.accelerationStep = playerShipNFT.accelerationStep;
            ship.accelerationDelay = playerShipNFT.accelerationDelay;
            ship.rotationDelay = playerShipNFT.rotationDelay;
            ship.cannons = playerShipNFT.cannons;
            ship.cannonsRange = playerShipNFT.cannonsRange;
            ship.cannonsDamage = playerShipNFT.cannonsDamage;
            ship.traits = playerShipNFT.traits;
            ship.level = playerShipNFT.level;
            ship = await ship.save();
        }
        return ship;
    }

    async generateFreeShip() {
        return await this.saveNewShip(uuidv4(), ShipType.FREE, {
            armor: 300,
            hull: 300,
            maxSpeed: 150,
            accelerationStep: 50,
            accelerationDelay: 200,
            rotationDelay: 200,
            cannons: 2,
            cannonsRange: 500,
            cannonsDamage: 20,
            level: 0,
            traits: 0,
            size: ShipSize.SMALL,
            rarity: Rarity.COMMON,
            windows: 0,
            anchor: 0
        } as PlayerShipEntity);
    }

    async generateShipMetadata(
        shipCurrentIndex: number,
        shipMaxIndex: number,
        smallShipStatsRange: ShipStatsRange,
        middleShipStatsRange: ShipStatsRange,
        shipStatsStep: ShipStatsStep,
        preferredSize?: ShipSize) {
        const shipAttributes = await this.generateShipAttributes(smallShipStatsRange, middleShipStatsRange, shipStatsStep, preferredSize);

        await this.saveNewShip(shipCurrentIndex.toString(), ShipType.COMMON, shipAttributes);

        return await this.nftShipGenerator.generateFounderShip(shipCurrentIndex, shipMaxIndex, shipAttributes);
    }

    private async saveNewShip(tokenId: string, shipType: ShipType, shipStats: PlayerShipEntity) {
        const newShip = new this.shipModel();

        newShip.tokenId = tokenId;
        newShip.hull = shipStats.hull;
        newShip.armor = shipStats.armor;
        newShip.maxSpeed = shipStats.maxSpeed;
        newShip.accelerationStep = shipStats.accelerationStep;
        newShip.accelerationDelay = shipStats.accelerationDelay;
        newShip.rotationDelay = shipStats.rotationDelay;
        newShip.cannons = shipStats.cannons;
        newShip.cannonsRange = shipStats.cannonsRange;
        newShip.cannonsDamage = shipStats.cannonsDamage;
        newShip.rarity = shipStats.rarity;
        newShip.size = shipStats.size;
        newShip.type = shipType;
        newShip.level = shipStats.level;
        newShip.windows = shipStats.windows;
        newShip.anchor = shipStats.anchor;

        return await newShip.save();
    }

    private async generateShipAttributes(smallShipStatsRange: ShipStatsRange, middleShipStatsRange: ShipStatsRange, shipStatsStep: ShipStatsStep, preferredSize?: ShipSize) {
        const size = this.randomService.generateShipSize(preferredSize);
        const shipStatsRange = size == ShipSize.MIDDLE ? middleShipStatsRange : smallShipStatsRange;
        const cannons = this.randomService.generateShipGuns(3, 4, 10);
        return {
            hull: this.calculateShipAttribute(shipStatsRange.minHull, shipStatsRange.maxHull, shipStatsStep.armorAndHullStep),
            armor: this.calculateShipAttribute(shipStatsRange.minArmor, shipStatsRange.maxArmor, shipStatsStep.armorAndHullStep),
            maxSpeed: this.calculateShipAttribute(shipStatsRange.minMaxSpeed, shipStatsRange.maxMaxSpeed, shipStatsStep.speedAndAccelerationStep),
            accelerationStep: this.calculateShipAttribute(shipStatsRange.minAccelerationStep, shipStatsRange.maxAccelerationStep, shipStatsStep.speedAndAccelerationStep),
            accelerationDelay: this.calculateShipAttribute(shipStatsRange.minAccelerationDelay, shipStatsRange.maxAccelerationDelay, shipStatsStep.inputdelayStep),
            rotationDelay: this.calculateShipAttribute(shipStatsRange.minRotationDelay, shipStatsRange.maxRotationDelay, shipStatsStep.inputdelayStep),
            cannons,
            cannonsRange: this.calculateShipAttribute(shipStatsRange.minCannonsRange, shipStatsRange.maxCannonsRange, shipStatsStep.cannonsRangeStep),
            cannonsDamage: this.calculateShipAttribute(shipStatsRange.minCannonsDamage, shipStatsRange.maxCannonsDamage, shipStatsStep.cannonsDamageStep),
            level: 0,
            traits: 0,
            rarity: Rarity.LEGENDARY,
            size
        } as PlayerShipEntity;
    }

    private calculateShipAttribute(minAttribute: number, maxAttribute: number, stepAttribute: number) {
        const diff = maxAttribute - minAttribute;
        const step = diff / stepAttribute;
        const rnd = RandomService.GetRandomIntInRange(0, step);
        return minAttribute + (stepAttribute * rnd);
    }

    // Island

    public async findIslandByXAndY(x: number, y: number) {
        return this.islandModel.findOne({
            x, y
        });
    }

    public async createIsland(tokenId: string, owner: string, x: number, y: number, terrain: string, isBase = false) {
        const island = new this.islandModel();
        island.tokenId = tokenId;
        island.owner = owner;
        island.x = x;
        island.y = y;
        island.isBase = isBase;
        island.terrain = terrain;
        return island.save();
    }

}