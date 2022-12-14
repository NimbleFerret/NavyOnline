/* eslint-disable prettier/prettier */
import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export enum ShipSize {
    SMALL = 1,
    MIDDLE = 2,
    LARGE = 3
}

export interface PlayerShipEntity {
    id: string;
    owner: string;
    type: number;
    armor: number;
    hull: number;
    maxSpeed: number;
    accelerationStep: number;
    accelerationDelay: number;
    rotationDelay: number;
    fireDelay: number;
    cannons: number;
    cannonsRange: number;
    cannonsDamage: number;
    level: number;
    traits: number;
    size: number;
    rarity: number;
    windows: number;
    anchor: number;
    currentIntegrity: number;
    maxIntegrity: number;
}

export type ShipDocument = Ship & Document;

@Schema()
export class Ship {

    @Prop({ required: true })
    tokenId: string;

    @Prop()
    owner: string;

    @Prop()
    hull: number;

    @Prop()
    armor: number;

    @Prop()
    maxSpeed: number;

    @Prop()
    accelerationStep: number;

    @Prop()
    accelerationDelay: number;

    @Prop()
    rotationDelay: number;

    @Prop()
    fireDelay: number;

    @Prop()
    cannons: number;

    @Prop()
    cannonsRange: number;

    @Prop()
    cannonsDamage: number;

    @Prop()
    rarity: number;

    @Prop()
    size: number;

    @Prop()
    type: number;

    @Prop()
    traits: number;

    @Prop()
    level: number;

    @Prop()
    windows: number;

    @Prop()
    anchor: number;

    @Prop()
    currentIntegrity: number;

    @Prop()
    maxIntegrity: number;
}

export const ShipSchema = SchemaFactory.createForClass(Ship);