package client.network;

import client.network.SocketProtocol.SocketServerDailyTaskChange;
import haxe.Timer;
import client.event.EventManager;
import js.node.socketio.Client;

class Socket {
	public static final instance:Socket = new Socket();

	public var latency = 0.0;

	private final clientSocket:Client;
	private var lastPingTime = 0.0;

	private function new() {
		clientSocket = new Client("http://localhost:3000");
		// clientSocket = new Client("https://navy.online");

		clientSocket.on(SocketProtocol.SocketServerEventPong, function(data) {
			latency = Date.now().getTime() - lastPingTime;
			// trace('Latency:' + latency);
		});
		clientSocket.on(SocketProtocol.SocketServerEventGameInit, function(data) {
			EventManager.instance.notify(SocketProtocol.SocketServerEventGameInit, data);
		});
		clientSocket.on(SocketProtocol.SocketServerEventAddEntity, function(data) {
			EventManager.instance.notify(SocketProtocol.SocketServerEventAddEntity, data);
		});
		clientSocket.on(SocketProtocol.SocketServerEventRemoveEntity, function(data) {
			EventManager.instance.notify(SocketProtocol.SocketServerEventRemoveEntity, data);
		});
		clientSocket.on(SocketProtocol.SocketServerEventUpdateWorldState, function(data) {
			EventManager.instance.notify(SocketProtocol.SocketServerEventUpdateWorldState, data);
		});
		clientSocket.on(SocketProtocol.SocketServerEventEntityMove, function(data) {
			EventManager.instance.notify(SocketProtocol.SocketServerEventEntityMove, data);
		});
		clientSocket.on(SocketProtocol.SocketServerEventShipShoot, function(data) {
			EventManager.instance.notify(SocketProtocol.SocketServerEventShipShoot, data);
		});
		clientSocket.on(SocketProtocol.SocketServerEventSync, function(data) {
			EventManager.instance.notify(SocketProtocol.SocketServerEventSync, data);
		});
		clientSocket.on(SocketProtocol.SocketServerEventDailyTaskUpdate, function(data:SocketServerDailyTaskChange) {
			Player.instance.playerData.dailyPlayersKilledCurrent = data.dailyPlayersKilledCurrent;
			Player.instance.playerData.dailyPlayersKilledMax = data.dailyPlayersKilledMax;
			Player.instance.playerData.dailyBotsKilledCurrent = data.dailyBotsKilledCurrent;
			Player.instance.playerData.dailyBotsKilledMax = data.dailyBotsKilledMax;
			Player.instance.playerData.dailyBossesKilledCurrent = data.dailyBossesKilledCurrent;
			Player.instance.playerData.dailyBossesKilledMax = data.dailyBossesKilledMax;
			EventManager.instance.notify(SocketProtocol.SocketServerEventDailyTaskUpdate, data);
		});
		clientSocket.on(SocketProtocol.SocketServerEventDailyTaskReward, function(data) {
			EventManager.instance.notify(SocketProtocol.SocketServerEventDailyTaskReward, data);
		});

		final timer = new Timer(1000);
		timer.run = function callback() {
			lastPingTime = Date.now().getTime();
			clientSocket.emit(SocketProtocol.SocketClientEventPing, {});
		}
	}

	public function joinGame(message:SocketProtocol.SocketClientMessageJoinGame) {
		clientSocket.emit(SocketProtocol.SocketClientEventJoinGame, message);
	}

	public function leaveGame(message:SocketProtocol.SocketClientMessageLeaveGame) {
		clientSocket.emit(SocketProtocol.SocketClientEventLeaveGame, message);
	}

	public function move(message:SocketProtocol.SocketClientMessageMove) {
		clientSocket.emit(SocketProtocol.SocketClientEventMove, message);
	}

	public function shoot(message:SocketProtocol.SocketClientMessageShoot) {
		clientSocket.emit(SocketProtocol.SocketClientEventShoot, message);
	}

	public function sync(message:SocketProtocol.SocketClientMessageSync) {
		clientSocket.emit(SocketProtocol.SocketClientEventSync, message);
	}

	public function respawn(message:SocketProtocol.SocketClientMessageRespawn) {
		clientSocket.emit(SocketProtocol.SocketClientEventRespawn, message);
	}
}
