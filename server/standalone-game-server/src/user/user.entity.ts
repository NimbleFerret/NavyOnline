/* eslint-disable prettier/prettier */
import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import mongoose, { Document } from 'mongoose';
import { Captain } from '../asset/asset.captain.entity';
import { Island } from '../asset/asset.island.entity';
import { Ship } from '../asset/asset.ship.entity';

export enum UserWorldState {
    WORLD = 1,
    SECTOR = 2,
}

export type UserDocument = User & Document;

@Schema()
export class User {
    @Prop({ required: true })
    ethAddress: string;

    @Prop()
    worldX: number;

    @Prop()
    worldY: number;

    @Prop({ default: '' })
    nickname: string;

    @Prop({ default: false })
    paidSubscriptionActive: boolean;

    @Prop()
    paidSubscriptionEndDate: string;

    @Prop({ default: 0 })
    nvyBalance: number;

    @Prop({ default: 0 })
    aksBalance: number;

    @Prop({ default: UserWorldState.WORLD })
    worldState: number;

    @Prop({ default: 0 })
    dailyPlayersKilled: number;

    @Prop({ default: 0 })
    dailyBotsKilled: number;

    @Prop({ default: 0 })
    dailyBossesKilled: number;

    @Prop({ type: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Captain' }] })
    captainsOwned: Captain[];

    @Prop({ type: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Ship' }] })
    shipsOwned: Ship[];

    @Prop({ type: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Island' }] })
    islandsOwned: Island[];
}

export const UserSchema = SchemaFactory.createForClass(User);