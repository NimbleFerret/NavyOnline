package client.gameplay.battle;

import haxe.Timer;
import client.network.SocketProtocol.SocketServerDailyTaskComplete;
import h2d.Bitmap;
import h2d.Object;
import client.gameplay.BaiscHud.BasicHud;
import client.ui.UiComponents;
import client.network.Socket;
import client.entity.ClientShip;

class HorizontalStatsBar {
	final guiObject:h2d.Object;

	final borderRect:h2d.Graphics;
	final fillRect:h2d.Graphics;
	final descriptionText:h2d.Text;
	final valueText:h2d.Text;

	final rectMaxWidth = 320;
	final rectX:Float;
	final rectY:Float;

	public function new(fui:h2d.Flow, x:Float, y:Float, desctiption:String, value:String, additionalOffsetX:Float = 0.0) {
		guiObject = new h2d.Object(fui);

		rectX = x + 100 + additionalOffsetX;
		rectY = y + 15;

		descriptionText = new h2d.Text(hxd.res.DefaultFont.get(), guiObject);
		descriptionText.textColor = 0xFBF0DD;
		descriptionText.dropShadow = {
			dx: 0.5,
			dy: 0.5,
			color: 0x000000,
			alpha: 0.9
		};
		descriptionText.text = desctiption;
		descriptionText.setScale(3);

		borderRect = new h2d.Graphics(guiObject);
		borderRect.lineStyle(3, 0xFFFFFF);
		borderRect.drawRect(rectX, rectY, rectMaxWidth, 40);
		borderRect.endFill();

		fillRect = new h2d.Graphics(guiObject);
		fillRect.beginFill(0x00FF00);
		fillRect.drawRect(rectX + 2, rectY + 2, rectMaxWidth - 4, 40 - 3);
		fillRect.endFill();

		valueText = new h2d.Text(hxd.res.DefaultFont.get(), guiObject);
		valueText.textColor = 0xFBF0DD;
		valueText.dropShadow = {
			dx: 0.5,
			dy: 0.5,
			color: 0x000000,
			alpha: 0.9
		};
		valueText.text = value + " / " + value;
		valueText.setScale(3);
		valueText.setPosition(x + 160 + additionalOffsetX, y + 9);
	}

	public function updateBar(maxValue:Float, currentValue:Float) {
		var extraZeroes = "";

		if (currentValue < maxValue) {
			if (currentValue < 10) {
				extraZeroes = "000";
			} else if (currentValue < 100) {
				extraZeroes = "00";
			} else if (maxValue >= 1000) {
				extraZeroes = "0";
			}
		}

		valueText.text = extraZeroes + Std.string(currentValue) + " / " + Std.string(maxValue);

		final percentage = currentValue / maxValue * 100;
		final newFillRectWidth = rectMaxWidth / 100 * percentage;

		fillRect.clear();

		if (currentValue > 0) {
			fillRect.beginFill(0x00FF00);
			fillRect.drawRect(rectX + 2, rectY + 2, newFillRectWidth - 4, 40 - 3);
			fillRect.endFill();
		}
	}

	public function show(show:Bool) {
		guiObject.alpha = show ? 1 : 0;
	}
}

class RetryDialog {
	public function new(fui:h2d.Flow, x:Float, y:Float) {
		final guiObject = new h2d.Object(fui);

		final fillRect = new h2d.Graphics(guiObject);
		fillRect.beginFill(0x6D563D);
		fillRect.drawRect(x, y, 100, 100);
		fillRect.endFill();
	}
}

class BattleHud extends BasicHud {
	private var movementText:h2d.Text;
	private var systemText:h2d.Text;
	private var latencyText:h2d.Text;
	private var positionText:h2d.Text;

	private var leftCannonsText:h2d.Text;
	private var rightCannonsText:h2d.Text;

	// HP bars
	final armorBar:HorizontalStatsBar;
	final hullBar:HorizontalStatsBar;

	// UI Dialogs
	private var startGameDialogComp:StartGameDialogComp;

	// Compass
	private final compassEast:h2d.Tile;
	private final compassNorthEast:h2d.Tile;
	private final compassNorth:h2d.Tile;
	private final compassNorthWest:h2d.Tile;
	private final compassWest:h2d.Tile;
	private final compassSouthWest:h2d.Tile;
	private final compassSouth:h2d.Tile;
	private final compassSouthEast:h2d.Tile;
	private final compassBmp:h2d.Bitmap;

	private final leaveButton:h2d.Object;

	// Daily tasks
	private final dailyTasksFui:h2d.Flow;
	private final killPlayersText:h2d.Text;
	private final killBotsText:h2d.Text;
	private final killBossesText:h2d.Text;

	// Callbacks
	private final leaveCallback:Void->Void;
	private final diedCallback:Void->Void;

	public function new(leaveCallback:Void->Void, diedCallback:Void->Void) {
		super();

		this.leaveCallback = leaveCallback;
		this.diedCallback = diedCallback;

		// Daily tasks
		dailyTasksFui = new h2d.Flow(this);
		dailyTasksFui.layout = Vertical;
		dailyTasksFui.verticalSpacing = 5;
		dailyTasksFui.padding = 10;

		addText3(dailyTasksFui, 'Daily tasks', 3);
		killPlayersText = addText3(dailyTasksFui, 'Kill players: 0/0', 3);
		killBotsText = addText3(dailyTasksFui, 'Kill pirates: 0/0', 3);
		killBossesText = addText3(dailyTasksFui, 'Kill bosses: 0/0', 3);
		updateDailyTasks();

		dailyTasksFui.y = 10;
		dailyTasksFui.x = Main.ScreenWidth - 130;

		// Compass
		compassEast = hxd.Res.compass.compass_e.toTile();
		compassNorthEast = hxd.Res.compass.compass_ne.toTile();
		compassNorth = hxd.Res.compass.compass_n.toTile();
		compassNorthWest = hxd.Res.compass.compass_nw.toTile();
		compassWest = hxd.Res.compass.compass_w.toTile();
		compassSouthWest = hxd.Res.compass.compass_sw.toTile();
		compassSouth = hxd.Res.compass.compass_s.toTile();
		compassSouthEast = hxd.Res.compass.compass_se.toTile();

		compassBmp = new h2d.Bitmap(compassEast);
		compassBmp.setScale(0.25);
		compassBmp.setPosition(Main.ScreenWidth / 2, Main.ScreenHeight - compassBmp.getBounds().height - 32);
		compassBmp.alpha = 1;

		addChild(compassBmp);

		armorBar = new HorizontalStatsBar(fui, 0, 0, 'Armor', '300', 65);
		hullBar = new HorizontalStatsBar(fui, 0, 0, 'Hull', '300', 65);

		movementText = addText();
		movementText.setScale(3);

		leftCannonsText = addText("Left side cannons READY");
		leftCannonsText.setScale(3);

		rightCannonsText = addText("Right side cannons READY");
		rightCannonsText.setScale(3);

		systemText = addText();
		systemText.setScale(3);

		latencyText = addText();
		latencyText.setScale(3);

		latencyText = addText();
		latencyText.setScale(3);

		leaveButton = addGuiButton(this, 'Leave sector', false, leaveCallback, 2, 2);
		leaveButton.setPosition(0, 390);

		show(true);
	}

	public function show(show:Bool) {
		if (show) {
			if (Player.instance.ethAddress.length >= 42) {
				dailyTasksFui.alpha = 1;
			} else {
				dailyTasksFui.alpha = 0;
			}
		} else {
			dailyTasksFui.alpha = 0;
		}

		armorBar.show(show);
		hullBar.show(show);

		compassBmp.alpha = show ? 1 : 0;
		leaveButton.alpha = show ? 1 : 0;
		systemText.alpha = show ? 1 : 0;
		latencyText.alpha = show ? 1 : 0;
		movementText.alpha = show ? 1 : 0;
		leftCannonsText.alpha = show ? 1 : 0;
		rightCannonsText.alpha = show ? 1 : 0;
	}

	public function update(dt:Float) {
		latencyText.text = "Latency:" + Socket.instance.latency;
	}

	public function showDieDialog(freeShip:Bool) {
		final additionalText = freeShip ? 'Dont worry, free ship has no any penalties, just try again.' : 'Ship damaged, it may require maintenance soon! ';
		alertDialog('You died, the ship sank and the crew went to feed the fish !\n' + additionalText, diedCallback);
	}

	public function updateSystemInfo(fps:Float) {
		systemText.text = "FPS: " + fps;
	}

	public function updatePlayerParams(playerShip:ClientShip) {
		final shipStats = playerShip.getStats();

		armorBar.updateBar(shipStats.armor, shipStats.currentArmor);
		hullBar.updateBar(shipStats.hull, shipStats.currentHull);

		movementText.text = "Speed: " + shipStats.currentSpeed + " / " + shipStats.maxSpeed;

		switch (shipStats.dir) {
			case East:
				compassBmp.tile = compassEast;
			case NorthEast:
				compassBmp.tile = compassNorthEast;
			case North:
				compassBmp.tile = compassNorth;
			case NorthWest:
				compassBmp.tile = compassNorthWest;
			case West:
				compassBmp.tile = compassWest;
			case SouthWest:
				compassBmp.tile = compassSouthWest;
			case South:
				compassBmp.tile = compassSouth;
			case SouthEast:
				compassBmp.tile = compassSouthEast;
		}

		// positionText.text = "Sector: " + BattleGameplay.CurrentSectorX + " / " + BattleGameplay.CurrentSectorY + ", Pos: " + Std.int(shipStats.x) + " / "
		// + Std.int(shipStats.y);

		if (shipStats.allowShootLeft) {
			leftCannonsText.text = "Left side cannons READY!";
		} else {
			leftCannonsText.text = "Left side cannons RELOADING...";
		}

		if (shipStats.allowShootRight) {
			rightCannonsText.text = "Right side cannons READY!";
		} else {
			rightCannonsText.text = "Right side cannons RELOADING...";
		}
	}

	public function updateDailyTasks() {
		if (Player.instance.playerData != null) {
			final playersCurrent = Player.instance.playerData.dailyPlayersKilledCurrent;
			final playersMax = Player.instance.playerData.dailyPlayersKilledMax;
			final botsCurrent = Player.instance.playerData.dailyBotsKilledCurrent;
			final botsMax = Player.instance.playerData.dailyBotsKilledMax;
			final bossesCurrent = Player.instance.playerData.dailyBossesKilledCurrent;
			final bossesMax = Player.instance.playerData.dailyBossesKilledMax;

			killPlayersText.text = 'Players killed: ' + playersCurrent + '/' + playersMax;
			killBotsText.text = 'Pirates killed: ' + botsCurrent + '/' + botsMax;
			killBossesText.text = 'Bosses killed: ' + bossesCurrent + '/' + bossesMax;
		}
	}

	public function dailyTaskComplete(message:SocketServerDailyTaskComplete) {
		final tokensAlert = tokensRewardAlert(message.rewardNVY, message.rewardAKS);
		addChild(tokensAlert);
		Timer.delay(function callback() {
			tokensAlert.alpha = 0;
		}, 3000);
	}
}
