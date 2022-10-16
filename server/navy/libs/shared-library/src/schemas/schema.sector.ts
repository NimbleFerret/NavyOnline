import { SectorContent } from '@app/shared-library/gprc/grpc.world.service';
import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';
import { IslandSchema, Island } from './schema.island';

export type SectorDocument = Sector & Document;

@Schema()
export class Sector {

    @Prop({ required: true, index: true })
    positionId: string;

    @Prop()
    x: number;

    @Prop()
    y: number;

    @Prop({
        type: String,
        required: true,
        enum: [
            SectorContent.SECTOR_CONTENT_EMPTY,
            SectorContent.SECTOR_CONTENT_BASE,
            SectorContent.SECTOR_CONTENT_ISLAND,
            SectorContent.SECTOR_CONTENT_BOSS,
            SectorContent.SECTOR_CONTENT_PVE,
            SectorContent.SECTOR_CONTENT_PVP,
        ],
        default: SectorContent.SECTOR_CONTENT_EMPTY
    })
    content: SectorContent;

    @Prop({ default: false })
    locked: boolean;

    @Prop({ type: IslandSchema })
    island: Island;
}

export const SectorSchema = SchemaFactory.createForClass(Sector);