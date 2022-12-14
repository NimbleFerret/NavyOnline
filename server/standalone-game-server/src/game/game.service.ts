// /* eslint-disable prettier/prettier */
// import { Injectable, Logger } from '@nestjs/common';
// import { EventEmitter2, OnEvent } from '@nestjs/event-emitter';
// import {
//     AppEvents,
//     PlayerDisconnectedEvent
// } from '../app.events';
// import { GameInstance } from './game.instance';
// import {
//     SectorContent,
//     SocketClientMessageJoinGame,
//     SocketClientMessageMove,
//     SocketClientMessageRespawn,
//     SocketClientMessageShoot,
//     SocketClientMessageSync,
// } from 'src/ws/ws.protocol';
// import { AddBotDto } from './game.controller';

// @Injectable()
// export class GameService {

//     private readonly maxPlayersPerInstance = 10;
//     private readonly gameInstances = new Map<string, GameInstance>();
//     private readonly sectorInstance = new Map<string, string>();
//     private readonly playerInstaneMap = new Map<string, string>();

//     constructor(private eventEmitter: EventEmitter2) {
//     }

//     // -------------------------------------
//     // World managed api
//     // -------------------------------------

//     joinWorldOrCreate(x: number, y: number, sectorContent: SectorContent) {
//         const gameInstanceId = this.sectorInstance.get(x + '+' + y);
//         if (gameInstanceId) {
//             const gameInstance = this.gameInstances.get(gameInstanceId);
//             if (gameInstance.getPlayersCount() < this.maxPlayersPerInstance) {
//                 return {
//                     result: true,
//                     playersCount: gameInstance.getPlayersCount(),
//                     totalShips: gameInstance.getTotalShipsCount(),
//                     instanceId: gameInstance.instanceId
//                 }
//             } else {
//                 return {
//                     result: false,
//                     reason: 'Sector is full'
//                 }
//             }
//         } else {
//             const gameInstance = new GameInstance(this.eventEmitter, x, y);
//             this.gameInstances.set(gameInstance.instanceId, gameInstance);
//             this.sectorInstance.set(x + '+' + y, gameInstance.instanceId);

//             switch (sectorContent) {
//                 case SectorContent.EMPTY: {
//                     // TODO randomly add some loot
//                     break;
//                 }
//                 case SectorContent.BOSS: {
//                     // TODO generate a boss
//                     break;
//                 }
//                 case SectorContent.PVE: {
//                     // TODO generate some bots
//                     gameInstance.addBot(100, -200);
//                     gameInstance.addBot(400, -200);
//                     break;
//                 }
//                 case SectorContent.PVP: {
//                     // TODO allow player kill
//                     break;
//                 }
//             }

//             return {
//                 result: true,
//                 playersCount: gameInstance.getPlayersCount(),
//                 totalShips: gameInstance.getTotalShipsCount(),
//                 instanceId: gameInstance.instanceId
//             }
//         }
//     }

//     // -------------------------------------
//     // Admin api
//     // -------------------------------------

//     getInstancesInfo() {
//         const result = [];
//         this.gameInstances.forEach((v) => {
//             // TODO add x and y pos
//             result.push({
//                 id: v.instanceId,
//                 players: v.getPlayersCount(),
//                 ships: v.getTotalShipsCount()
//             });
//         });
//         return result;
//     }

//     addBot(dto: AddBotDto) {
//         const gameInstance = this.gameInstances.get(dto.instanceId);
//         if (gameInstance) {
//             gameInstance.addBot(dto.x, dto.y);
//         }
//     }

//     // -------------------------------------
//     // Client events from WebSocket
//     // ------------------------------------- 

//     @OnEvent(AppEvents.PlayerJoinedGameInstance)
//     async handlePlayerJoinedEvent(data: SocketClientMessageJoinGame) {
//         // Create a new instance and add player into it
//         if (!this.playerInstaneMap.has(data.playerId)) {
//             const gameInstance = this.gameInstances.get(data.instanceId);
//             if (gameInstance) {
//                 gameInstance.handlePlayerJoinedEvent(data);
//                 this.playerInstaneMap.set(data.playerId, data.instanceId);
//                 Logger.log(`Player: ${data.playerId} was added to the existing instance: ${data.instanceId}`);
//             } else {
//                 Logger.error(`Unable to add player into any game instance. Players: ${this.playerInstaneMap.size}, Instances: ${this.gameInstances.size}`);
//             }
//         } else {
//             // TODO add logs
//             Logger.error('Player cant join more than once');
//         }
//     }

//     @OnEvent(AppEvents.PlayerDisconnected)
//     async handlePlayerDisconnected(data: PlayerDisconnectedEvent) {
//         const instanceId = this.playerInstaneMap.get(data.playerId);
//         if (instanceId) {
//             this.playerInstaneMap.delete(data.playerId);
//             const gameInstance = this.gameInstances.get(instanceId);
//             gameInstance.handlePlayerDisconnected(data);
//             if (gameInstance.getPlayersCount() == 0) {
//                 Logger.log(`No more player in instance: ${instanceId}, destroying...`);
//                 gameInstance.destroy();
//                 this.gameInstances.delete(instanceId);

//                 let sectorKeyToDelete: string;
//                 this.sectorInstance.forEach((v, k) => {
//                     if (v == instanceId) {
//                         sectorKeyToDelete = k;
//                     }
//                 });
//                 this.sectorInstance.delete(sectorKeyToDelete);

//                 Logger.log(`Instance: ${instanceId} destroyed !`);
//             }
//         } else {
//             // TODO add logs
//         }
//     }

//     @OnEvent(AppEvents.PlayerMove)
//     async handlePlayerMove(data: SocketClientMessageMove) {
//         const instanceId = this.playerInstaneMap.get(data.playerId);
//         if (instanceId) {
//             const gameInstance = this.gameInstances.get(instanceId);
//             gameInstance.handlePlayerMove(data);
//         } else {
//             // TODO add logs
//         }
//     }

//     @OnEvent(AppEvents.PlayerShoot)
//     async handlePlayerShoot(data: SocketClientMessageShoot) {
//         const instanceId = this.playerInstaneMap.get(data.playerId);
//         if (instanceId) {
//             const gameInstance = this.gameInstances.get(instanceId);
//             gameInstance.handlePlayerShoot(data);
//         } else {
//             // TODO add logs
//         }
//     }

//     @OnEvent(AppEvents.PlayerSync)
//     async handlePlayerSync(data: SocketClientMessageSync) {
//         const instanceId = this.playerInstaneMap.get(data.playerId);
//         if (instanceId) {
//             const gameInstance = this.gameInstances.get(instanceId);
//             gameInstance.handlePlayerSync(data);
//         } else {
//             // TODO add logs
//         }
//     }

//     @OnEvent(AppEvents.PlayerRespawn)
//     async handlePlayerRespawn(data: SocketClientMessageRespawn) {
//         const instanceId = this.playerInstaneMap.get(data.playerId);
//         if (instanceId) {
//             const gameInstance = this.gameInstances.get(instanceId);
//             gameInstance.handlePlayerRespawn(data);
//         } else {
//             // TODO add logs
//         }
//     }

// }
