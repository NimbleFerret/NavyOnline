package client.entity.ship;

import engine.entity.EngineBaseGameEntity;
import engine.entity.EngineShipEntity;

using tweenxcore.Tools;

// w_t - wood top offset x y
// w_b - wood bottom offset x y
// g_x - gun offset x
// g_y - gun offset y
// w_t_t - wood top tile
// w_b_t - wood bottom tile
// g_t - gun tile

typedef GunParams = {
	w_t_x:Int,
	w_t_y:Int,
	w_b_x:Int,
	w_b_y:Int,
	g_x:Int,
	g_y:Int,
	w_t_t:h2d.Tile,
	w_b_t:h2d.Tile,
	g_t:h2d.Tile
}

class GunRecoilTween {
	private final side:Side;
	private var tweeningObject:Dynamic;
	private var x = 0.0;
	private var y = 0.0;
	private var frameCount = 0;
	private var play = false;
	private var start_x:Float;
	private var end_x:Float;
	private var start_y:Float;
	private var end_y:Float;

	private var totalFrames = 1 * 45;

	public function new(direction:GameEntityDirection, side:Side, tweeningObject:Dynamic) {
		this.side = side;
		this.tweeningObject = tweeningObject;

		updateObjectAndDirection(tweeningObject, direction);
	}

	public function update() {
		if (play) {
			final rate = frameCount / totalFrames;
			if (rate <= 1) {
				x = rate.yoyo(Easing.quintOut).lerp(start_x, end_x);
				y = rate.yoyo(Easing.quintOut).lerp(start_y, end_y);
				tweeningObject.setPosition(x, y);
			} else {
				play = false;
			}
			frameCount++;
		}
	}

	public function updateObjectAndDirection(tweeningObject:Dynamic, direction:GameEntityDirection) {
		this.tweeningObject = tweeningObject;

		start_x = x = tweeningObject.x;
		start_y = y = tweeningObject.y;
		end_x = tweeningObject.x;
		end_y = tweeningObject.y;

		switch (direction) {
			case East:
				if (side == Right) {
					end_y -= 5;
				} else {
					end_y += 5;
				}
			case NorthEast:
				if (side == Right) {
					end_x -= 2.5;
					end_y -= 2.5;
				} else {
					end_x += 2.5;
					end_y += 2.5;
				}
			case North:
				if (side == Right) {
					end_x -= 5;
				} else {
					end_x += 5;
				}
			case NorthWest:
				if (side == Right) {
					end_x -= 2.5;
					end_y += 2.5;
				} else {
					end_x += 2.5;
					end_y -= 2.5;
				}
			case West:
				if (side == Right) {
					end_y += 5;
				} else {
					end_y -= 5;
				}
			case SouthWest:
				if (side == Right) {
					end_x += 2.5;
					end_y += 2.5;
				} else {
					end_x -= 2.5;
					end_y -= 2.5;
				}
			case South:
				if (side == Right) {
					end_x += 5;
				} else {
					end_x -= 5;
				}
			case SouthEast:
				if (side == Right) {
					end_x += 5;
				} else {
					end_x -= 2.5;
					end_y += 2.5;
				}
		}
	}

	public function reset() {
		play = true;
		frameCount = 0;

		// Random
		final dir = Std.random(2);
		final rnd = 5;
		totalFrames = 45;
		totalFrames += dir == 1 ? rnd : -rnd;
	}
}

class ShipGun extends ShipVisualComponent {
	// Mid
	private static final RightGunParamsByDirMid:Map<GameEntityDirection, GunParams> = [
		GameEntityDirection.East => {
			w_t_x: 0,
			w_t_y: 0,
			w_b_x: 0,
			w_b_y: 8,
			g_x: 0,
			g_y: 13,
			w_t_t: null,
			w_b_t: null,
			g_t: null
		},
		GameEntityDirection.NorthEast => {
			w_t_x: 0,
			w_t_y: 0,
			w_b_x: 0,
			w_b_y: 0,
			g_x: 7,
			g_y: 5,
			w_t_t: null,
			w_b_t: null,
			g_t: null
		},
		GameEntityDirection.North => {
			w_t_x: 0,
			w_t_y: 0,
			w_b_x: 0,
			w_b_y: 0,
			g_x: 4,
			g_y: 0,
			w_t_t: null,
			w_b_t: null,
			g_t: null
		},
		GameEntityDirection.NorthWest => {
			w_t_x: 0,
			w_t_y: 0,
			w_b_x: 0,
			w_b_y: 0,
			g_x: -3,
			g_y: 1,
			w_t_t: null,
			w_b_t: null,
			g_t: null
		},
		GameEntityDirection.West => {
			w_t_x: 0,
			w_t_y: 0,
			w_b_x: 0,
			w_b_y: 0,
			g_x: 0,
			g_y: 0,
			w_t_t: null,
			w_b_t: null,
			g_t: null
		},
		GameEntityDirection.SouthWest => {
			w_t_x: 0,
			w_t_y: 0,
			w_b_x: 0,
			w_b_y: 0,
			g_x: 3,
			g_y: 1,
			w_t_t: null,
			w_b_t: null,
			g_t: null
		},
		GameEntityDirection.South => {
			w_t_x: 0,
			w_t_y: 0,
			w_b_x: 0,
			w_b_y: 0,
			g_x: -4,
			g_y: 0,
			w_t_t: null,
			w_b_t: null,
			g_t: null
		},
		GameEntityDirection.SouthEast => {
			w_t_x: 0,
			w_t_y: 0,
			w_b_x: 0,
			w_b_y: 0,
			g_x: -9,
			g_y: 4,
			w_t_t: null,
			w_b_t: null,
			g_t: null
		}
	];

	private static final LeftGunParamsByDirMid:Map<GameEntityDirection, GunParams> = [
		GameEntityDirection.East => {
			w_t_x: 0,
			w_t_y: 0,
			w_b_x: 0,
			w_b_y: 8,
			g_x: 0,
			g_y: -2,
			w_t_t: null,
			w_b_t: null,
			g_t: null
		},
		GameEntityDirection.NorthEast => {
			w_t_x: 0,
			w_t_y: 0,
			w_b_x: 0,
			w_b_y: 0,
			g_x: 3,
			g_y: 1,
			w_t_t: null,
			w_b_t: null,
			g_t: null
		},
		GameEntityDirection.North => {
			w_t_x: 0,
			w_t_y: 0,
			w_b_x: 0,
			w_b_y: 0,
			g_x: -4,
			g_y: 0,
			w_t_t: null,
			w_b_t: null,
			g_t: null
		},
		GameEntityDirection.NorthWest => {
			w_t_x: 0,
			w_t_y: 0,
			w_b_x: 0,
			w_b_y: 0,
			g_x: -7,
			g_y: 4,
			w_t_t: null,
			w_b_t: null,
			g_t: null
		},
		GameEntityDirection.West => {
			w_t_x: 0,
			w_t_y: 0,
			w_b_x: 0,
			w_b_y: 8,
			g_x: 0,
			g_y: 13,
			w_t_t: null,
			w_b_t: null,
			g_t: null
		},
		GameEntityDirection.SouthWest => {
			w_t_x: 0,
			w_t_y: 0,
			w_b_x: 0,
			w_b_y: 0,
			g_x: 7,
			g_y: 5,
			w_t_t: null,
			w_b_t: null,
			g_t: null
		},
		GameEntityDirection.South => {
			w_t_x: 0,
			w_t_y: 0,
			w_b_x: 0,
			w_b_y: 0,
			g_x: 4,
			g_y: 0,
			w_t_t: null,
			w_b_t: null,
			g_t: null
		},
		GameEntityDirection.SouthEast => {
			w_t_x: 0,
			w_t_y: 0,
			w_b_x: 0,
			w_b_y: 0,
			g_x: -3,
			g_y: 1,
			w_t_t: null,
			w_b_t: null,
			g_t: null
		}
	];

	// Sm
	private static final RightGunParamsByDirSm:Map<GameEntityDirection, GunParams> = [
		GameEntityDirection.East => {
			w_t_x: 0,
			w_t_y: 0,
			w_b_x: 0,
			w_b_y: 8,
			g_x: 0,
			g_y: 13,
			w_t_t: null,
			w_b_t: null,
			g_t: null
		},
		GameEntityDirection.NorthEast => {
			w_t_x: 0,
			w_t_y: 0,
			w_b_x: 0,
			w_b_y: 0,
			g_x: 7,
			g_y: 5,
			w_t_t: null,
			w_b_t: null,
			g_t: null
		},
		GameEntityDirection.North => {
			w_t_x: 0,
			w_t_y: 0,
			w_b_x: 0,
			w_b_y: 0,
			g_x: 4,
			g_y: 0,
			w_t_t: null,
			w_b_t: null,
			g_t: null
		},
		GameEntityDirection.NorthWest => {
			w_t_x: 0,
			w_t_y: 0,
			w_b_x: 0,
			w_b_y: 0,
			g_x: -3,
			g_y: 1,
			w_t_t: null,
			w_b_t: null,
			g_t: null
		},
		GameEntityDirection.West => {
			w_t_x: 0,
			w_t_y: 0,
			w_b_x: 0,
			w_b_y: 0,
			g_x: 0,
			g_y: 0,
			w_t_t: null,
			w_b_t: null,
			g_t: null
		},
		GameEntityDirection.SouthWest => {
			w_t_x: 0,
			w_t_y: 0,
			w_b_x: 0,
			w_b_y: 0,
			g_x: 3,
			g_y: 1,
			w_t_t: null,
			w_b_t: null,
			g_t: null
		},
		GameEntityDirection.South => {
			w_t_x: 0,
			w_t_y: 0,
			w_b_x: 0,
			w_b_y: 0,
			g_x: -4,
			g_y: 0,
			w_t_t: null,
			w_b_t: null,
			g_t: null
		},
		GameEntityDirection.SouthEast => {
			w_t_x: 0,
			w_t_y: 0,
			w_b_x: 0,
			w_b_y: 0,
			g_x: -9,
			g_y: 4,
			w_t_t: null,
			w_b_t: null,
			g_t: null
		}
	];

	private static final LeftGunParamsByDirSm:Map<GameEntityDirection, GunParams> = [
		GameEntityDirection.East => {
			w_t_x: 0,
			w_t_y: 0,
			w_b_x: 0,
			w_b_y: 8,
			g_x: 0,
			g_y: -2,
			w_t_t: null,
			w_b_t: null,
			g_t: null
		},
		GameEntityDirection.NorthEast => {
			w_t_x: 0,
			w_t_y: 0,
			w_b_x: 0,
			w_b_y: 0,
			g_x: 3,
			g_y: 1,
			w_t_t: null,
			w_b_t: null,
			g_t: null
		},
		GameEntityDirection.North => {
			w_t_x: 0,
			w_t_y: 0,
			w_b_x: 0,
			w_b_y: 0,
			g_x: -4,
			g_y: 0,
			w_t_t: null,
			w_b_t: null,
			g_t: null
		},
		GameEntityDirection.NorthWest => {
			w_t_x: 0,
			w_t_y: 0,
			w_b_x: 0,
			w_b_y: 0,
			g_x: -7,
			g_y: 4,
			w_t_t: null,
			w_b_t: null,
			g_t: null
		},
		GameEntityDirection.West => {
			w_t_x: 0,
			w_t_y: 0,
			w_b_x: 0,
			w_b_y: 8,
			g_x: 0,
			g_y: 13,
			w_t_t: null,
			w_b_t: null,
			g_t: null
		},
		GameEntityDirection.SouthWest => {
			w_t_x: 0,
			w_t_y: 0,
			w_b_x: 0,
			w_b_y: 0,
			g_x: 7,
			g_y: 5,
			w_t_t: null,
			w_b_t: null,
			g_t: null
		},
		GameEntityDirection.South => {
			w_t_x: 0,
			w_t_y: 0,
			w_b_x: 0,
			w_b_y: 0,
			g_x: 4,
			g_y: 0,
			w_t_t: null,
			w_b_t: null,
			g_t: null
		},
		GameEntityDirection.SouthEast => {
			w_t_x: 0,
			w_t_y: 0,
			w_b_x: 0,
			w_b_y: 0,
			g_x: -3,
			g_y: 1,
			w_t_t: null,
			w_b_t: null,
			g_t: null
		}
	];

	private static var tilesInitialized = false;

	private var bmp_wood_top:h2d.Bitmap;
	private var bmp_wood_bottom:h2d.Bitmap;
	private var bmp_gun:h2d.Bitmap;

	private final shipHullSize:ShipHullSize;
	private final recoilAnim:GunRecoilTween;

	public function new(shipHullSize:ShipHullSize, direction:GameEntityDirection, side:Side) {
		super(direction, side);

		this.shipHullSize = shipHullSize;

		if (!tilesInitialized) {
			RightGunParamsByDirMid.get(East).w_t_t = hxd.Res.mid_ship.wood_top.wood_top_e.toTile();
			RightGunParamsByDirMid.get(East).w_b_t = hxd.Res.mid_ship.wood_bottom.wood_bottom_e.toTile();
			RightGunParamsByDirMid.get(East).g_t = hxd.Res.mid_ship.ok_gun.gun_right_e.toTile();
			RightGunParamsByDirMid.get(NorthEast).w_t_t = hxd.Res.mid_ship.wood_top.wood_top_ne.toTile();
			RightGunParamsByDirMid.get(NorthEast).w_b_t = null;
			RightGunParamsByDirMid.get(NorthEast).g_t = hxd.Res.mid_ship.ok_gun.gun_right_ne.toTile();
			RightGunParamsByDirMid.get(North).w_t_t = hxd.Res.mid_ship.wood_top.wood_top_n.toTile();
			RightGunParamsByDirMid.get(North).w_b_t = null;
			RightGunParamsByDirMid.get(North).g_t = hxd.Res.mid_ship.ok_gun.gun_right_n.toTile();
			RightGunParamsByDirMid.get(NorthWest).w_t_t = hxd.Res.mid_ship.wood_top.wood_top_nw.toTile();
			RightGunParamsByDirMid.get(NorthWest).w_b_t = null;
			RightGunParamsByDirMid.get(NorthWest).g_t = hxd.Res.mid_ship.ok_gun.gun_right_nw.toTile();
			RightGunParamsByDirMid.get(West).w_t_t = hxd.Res.mid_ship.wood_top.wood_top_w.toTile();
			RightGunParamsByDirMid.get(West).w_b_t = null;
			RightGunParamsByDirMid.get(West).g_t = hxd.Res.mid_ship.ok_gun.gun_right_w.toTile();
			RightGunParamsByDirMid.get(SouthWest).w_t_t = hxd.Res.mid_ship.wood_top.wood_top_ne.toTile();
			RightGunParamsByDirMid.get(SouthWest).w_b_t = null;
			RightGunParamsByDirMid.get(SouthWest).g_t = hxd.Res.mid_ship.ok_gun.gun_right_sw.toTile();
			RightGunParamsByDirMid.get(South).w_t_t = hxd.Res.mid_ship.wood_top.wood_top_s.toTile();
			RightGunParamsByDirMid.get(South).w_b_t = null;
			RightGunParamsByDirMid.get(South).g_t = hxd.Res.mid_ship.ok_gun.gun_right_s.toTile();
			RightGunParamsByDirMid.get(SouthEast).w_t_t = hxd.Res.mid_ship.wood_top.wood_top_nw.toTile();
			RightGunParamsByDirMid.get(SouthEast).w_b_t = null;
			RightGunParamsByDirMid.get(SouthEast).g_t = hxd.Res.mid_ship.ok_gun.gun_right_se.toTile();

			LeftGunParamsByDirMid.get(East).w_t_t = hxd.Res.mid_ship.wood_top.wood_top_w.toTile();
			LeftGunParamsByDirMid.get(East).w_b_t = null;
			LeftGunParamsByDirMid.get(East).g_t = hxd.Res.mid_ship.ok_gun.gun_left_e.toTile();
			LeftGunParamsByDirMid.get(NorthEast).w_t_t = hxd.Res.mid_ship.wood_top.wood_top_ne.toTile();
			LeftGunParamsByDirMid.get(NorthEast).w_b_t = null;
			LeftGunParamsByDirMid.get(NorthEast).g_t = hxd.Res.mid_ship.ok_gun.gun_left_ne.toTile();
			LeftGunParamsByDirMid.get(North).w_t_t = hxd.Res.mid_ship.wood_top.wood_top_s.toTile();
			LeftGunParamsByDirMid.get(North).w_b_t = null;
			LeftGunParamsByDirMid.get(North).g_t = hxd.Res.mid_ship.ok_gun.gun_left_n.toTile();
			LeftGunParamsByDirMid.get(NorthWest).w_t_t = hxd.Res.mid_ship.wood_top.wood_top_nw.toTile();
			LeftGunParamsByDirMid.get(NorthWest).w_b_t = null;
			LeftGunParamsByDirMid.get(NorthWest).g_t = hxd.Res.mid_ship.ok_gun.gun_left_nw.toTile();
			LeftGunParamsByDirMid.get(West).w_t_t = hxd.Res.mid_ship.wood_top.wood_top_e.toTile();
			LeftGunParamsByDirMid.get(West).w_b_t = hxd.Res.mid_ship.wood_bottom.wood_bottom_e.toTile();
			LeftGunParamsByDirMid.get(West).g_t = hxd.Res.mid_ship.ok_gun.gun_left_w.toTile();
			LeftGunParamsByDirMid.get(SouthWest).w_t_t = hxd.Res.mid_ship.wood_top.wood_top_ne.toTile();
			LeftGunParamsByDirMid.get(SouthWest).w_b_t = null;
			LeftGunParamsByDirMid.get(SouthWest).g_t = hxd.Res.mid_ship.ok_gun.gun_left_sw.toTile();
			LeftGunParamsByDirMid.get(South).w_t_t = hxd.Res.mid_ship.wood_top.wood_top_n.toTile();
			LeftGunParamsByDirMid.get(South).w_b_t = null;
			LeftGunParamsByDirMid.get(South).g_t = hxd.Res.mid_ship.ok_gun.gun_left_s.toTile();
			LeftGunParamsByDirMid.get(SouthEast).w_t_t = hxd.Res.mid_ship.wood_top.wood_top_nw.toTile();
			LeftGunParamsByDirMid.get(SouthEast).w_b_t = null;
			LeftGunParamsByDirMid.get(SouthEast).g_t = hxd.Res.mid_ship.ok_gun.gun_left_se.toTile();

			RightGunParamsByDirSm.get(East).w_t_t = hxd.Res.mid_ship.wood_top.wood_top_e.toTile();
			RightGunParamsByDirSm.get(East).w_b_t = hxd.Res.mid_ship.wood_bottom.wood_bottom_e.toTile();
			RightGunParamsByDirSm.get(East).g_t = hxd.Res.mid_ship.ok_gun.gun_right_e.toTile();
			RightGunParamsByDirSm.get(NorthEast).w_t_t = hxd.Res.mid_ship.wood_top.wood_top_ne.toTile();
			RightGunParamsByDirSm.get(NorthEast).w_b_t = null;
			RightGunParamsByDirSm.get(NorthEast).g_t = hxd.Res.mid_ship.ok_gun.gun_right_ne.toTile();
			RightGunParamsByDirSm.get(North).w_t_t = hxd.Res.mid_ship.wood_top.wood_top_n.toTile();
			RightGunParamsByDirSm.get(North).w_b_t = null;
			RightGunParamsByDirSm.get(North).g_t = hxd.Res.mid_ship.ok_gun.gun_right_n.toTile();
			RightGunParamsByDirSm.get(NorthWest).w_t_t = hxd.Res.mid_ship.wood_top.wood_top_nw.toTile();
			RightGunParamsByDirSm.get(NorthWest).w_b_t = null;
			RightGunParamsByDirSm.get(NorthWest).g_t = hxd.Res.mid_ship.ok_gun.gun_right_nw.toTile();
			RightGunParamsByDirSm.get(West).w_t_t = hxd.Res.mid_ship.wood_top.wood_top_w.toTile();
			RightGunParamsByDirSm.get(West).w_b_t = null;
			RightGunParamsByDirSm.get(West).g_t = hxd.Res.mid_ship.ok_gun.gun_right_w.toTile();
			RightGunParamsByDirSm.get(SouthWest).w_t_t = hxd.Res.mid_ship.wood_top.wood_top_ne.toTile();
			RightGunParamsByDirSm.get(SouthWest).w_b_t = null;
			RightGunParamsByDirSm.get(SouthWest).g_t = hxd.Res.mid_ship.ok_gun.gun_right_sw.toTile();
			RightGunParamsByDirSm.get(South).w_t_t = hxd.Res.mid_ship.wood_top.wood_top_s.toTile();
			RightGunParamsByDirSm.get(South).w_b_t = null;
			RightGunParamsByDirSm.get(South).g_t = hxd.Res.mid_ship.ok_gun.gun_right_s.toTile();
			RightGunParamsByDirSm.get(SouthEast).w_t_t = hxd.Res.mid_ship.wood_top.wood_top_nw.toTile();
			RightGunParamsByDirSm.get(SouthEast).w_b_t = null;
			RightGunParamsByDirSm.get(SouthEast).g_t = hxd.Res.mid_ship.ok_gun.gun_right_se.toTile();

			LeftGunParamsByDirSm.get(East).w_t_t = hxd.Res.mid_ship.wood_top.wood_top_w_small.toTile();
			LeftGunParamsByDirSm.get(East).w_b_t = null;
			LeftGunParamsByDirSm.get(East).g_t = hxd.Res.mid_ship.ok_gun.gun_left_e.toTile();
			LeftGunParamsByDirSm.get(NorthEast).w_t_t = hxd.Res.mid_ship.wood_top.wood_top_ne.toTile();
			LeftGunParamsByDirSm.get(NorthEast).w_b_t = null;
			LeftGunParamsByDirSm.get(NorthEast).g_t = hxd.Res.mid_ship.ok_gun.gun_left_ne.toTile();
			LeftGunParamsByDirSm.get(North).w_t_t = hxd.Res.mid_ship.wood_top.wood_top_s.toTile();
			LeftGunParamsByDirSm.get(North).w_b_t = null;
			LeftGunParamsByDirSm.get(North).g_t = hxd.Res.mid_ship.ok_gun.gun_left_n.toTile();
			LeftGunParamsByDirSm.get(NorthWest).w_t_t = hxd.Res.mid_ship.wood_top.wood_top_nw.toTile();
			LeftGunParamsByDirSm.get(NorthWest).w_b_t = null;
			LeftGunParamsByDirSm.get(NorthWest).g_t = hxd.Res.mid_ship.ok_gun.gun_left_nw.toTile();
			LeftGunParamsByDirSm.get(West).w_t_t = hxd.Res.mid_ship.wood_top.wood_top_e.toTile();
			LeftGunParamsByDirSm.get(West).w_b_t = hxd.Res.mid_ship.wood_bottom.wood_bottom_e.toTile();
			LeftGunParamsByDirSm.get(West).g_t = hxd.Res.mid_ship.ok_gun.gun_left_w.toTile();
			LeftGunParamsByDirSm.get(SouthWest).w_t_t = hxd.Res.mid_ship.wood_top.wood_top_ne.toTile();
			LeftGunParamsByDirSm.get(SouthWest).w_b_t = null;
			LeftGunParamsByDirSm.get(SouthWest).g_t = hxd.Res.mid_ship.ok_gun.gun_left_sw.toTile();
			LeftGunParamsByDirSm.get(South).w_t_t = hxd.Res.mid_ship.wood_top.wood_top_n.toTile();
			LeftGunParamsByDirSm.get(South).w_b_t = null;
			LeftGunParamsByDirSm.get(South).g_t = hxd.Res.mid_ship.ok_gun.gun_left_s.toTile();
			LeftGunParamsByDirSm.get(SouthEast).w_t_t = hxd.Res.mid_ship.wood_top.wood_top_nw.toTile();
			LeftGunParamsByDirSm.get(SouthEast).w_b_t = null;
			LeftGunParamsByDirSm.get(SouthEast).g_t = hxd.Res.mid_ship.ok_gun.gun_left_se.toTile();

			for (key in RightGunParamsByDirMid.keys()) {
				final rightGunParam = RightGunParamsByDirMid.get(key);
				if (rightGunParam.w_b_t != null) {
					RightGunParamsByDirMid.get(key).w_b_t = RightGunParamsByDirMid.get(key).w_b_t.center();
				}
				RightGunParamsByDirMid.get(key).w_t_t = RightGunParamsByDirMid.get(key).w_t_t.center();
				RightGunParamsByDirMid.get(key).g_t = RightGunParamsByDirMid.get(key).g_t.center();

				final leftGunParam = LeftGunParamsByDirMid.get(key);
				if (leftGunParam.w_b_t != null) {
					LeftGunParamsByDirMid.get(key).w_b_t = LeftGunParamsByDirMid.get(key).w_b_t.center();
				}
				LeftGunParamsByDirMid.get(key).w_t_t = LeftGunParamsByDirMid.get(key).w_t_t.center();
				LeftGunParamsByDirMid.get(key).g_t = LeftGunParamsByDirMid.get(key).g_t.center();
			}

			for (key in RightGunParamsByDirSm.keys()) {
				final rightGunParam = RightGunParamsByDirSm.get(key);
				if (rightGunParam.w_b_t != null) {
					RightGunParamsByDirSm.get(key).w_b_t = RightGunParamsByDirSm.get(key).w_b_t.center();
				}
				RightGunParamsByDirSm.get(key).w_t_t = RightGunParamsByDirSm.get(key).w_t_t.center();
				RightGunParamsByDirSm.get(key).g_t = RightGunParamsByDirSm.get(key).g_t.center();

				final leftGunParam = LeftGunParamsByDirSm.get(key);
				if (leftGunParam.w_b_t != null) {
					LeftGunParamsByDirSm.get(key).w_b_t = LeftGunParamsByDirSm.get(key).w_b_t.center();
				}
				LeftGunParamsByDirSm.get(key).w_t_t = LeftGunParamsByDirSm.get(key).w_t_t.center();
				LeftGunParamsByDirSm.get(key).g_t = LeftGunParamsByDirSm.get(key).g_t.center();
			}
			tilesInitialized = true;
		}

		var paramsByDir:GunParams;
		if (shipHullSize == ShipHullSize.SMALL) {
			paramsByDir = side == Right ? RightGunParamsByDirSm.get(direction) : LeftGunParamsByDirSm.get(direction);
		} else {
			paramsByDir = side == Right ? RightGunParamsByDirMid.get(direction) : LeftGunParamsByDirMid.get(direction);
		}

		if (paramsByDir.w_b_t != null) {
			bmp_wood_bottom = new h2d.Bitmap(paramsByDir.w_b_t);
			bmp_wood_bottom.setPosition(paramsByDir.w_b_x, paramsByDir.w_b_y);

			addChild(bmp_wood_bottom);
		}

		if (paramsByDir.w_t_t != null && paramsByDir.g_t != null) {
			bmp_wood_top = new h2d.Bitmap(paramsByDir.w_t_t);
			bmp_gun = new h2d.Bitmap(paramsByDir.g_t);

			bmp_wood_top.setPosition(paramsByDir.w_t_x, paramsByDir.w_t_y);
			bmp_gun.setPosition(paramsByDir.g_x, paramsByDir.g_y);

			addChild(bmp_gun);
			addChild(bmp_wood_top);

			recoilAnim = new GunRecoilTween(this.direction, side, bmp_gun);
		}
	}

	public function changeTilesDirection() {
		var paramsByDir:GunParams;
		if (shipHullSize == ShipHullSize.SMALL) {
			paramsByDir = side == Right ? RightGunParamsByDirSm.get(direction) : LeftGunParamsByDirSm.get(direction);
		} else {
			paramsByDir = side == Right ? RightGunParamsByDirMid.get(direction) : LeftGunParamsByDirMid.get(direction);
		}

		// TODO Refactor bottom tile and bmp_wood_bottom null check
		if (paramsByDir.w_b_t != null) {
			if (bmp_wood_bottom == null) {
				bmp_wood_bottom = new h2d.Bitmap(paramsByDir.w_b_t);
				removeChild(bmp_gun);
				removeChild(bmp_wood_top);
				addChild(bmp_wood_bottom);
				addChild(bmp_gun);
				addChild(bmp_wood_top);
			} else {
				bmp_wood_bottom.alpha = 1;
				bmp_wood_bottom.tile = paramsByDir.w_b_t;
			}
			bmp_wood_bottom.setPosition(paramsByDir.w_b_x, paramsByDir.w_b_y);
		} else if (bmp_wood_bottom != null) {
			bmp_wood_bottom.alpha = 0;
		}

		bmp_wood_top.tile = paramsByDir.w_t_t;
		bmp_gun.tile = paramsByDir.g_t;
		bmp_wood_top.setPosition(paramsByDir.w_t_x, paramsByDir.w_t_y);
		bmp_gun.setPosition(paramsByDir.g_x, paramsByDir.g_y);
		recoilAnim.updateObjectAndDirection(bmp_gun, direction);
	}

	public function update() {
		recoilAnim.update();
	}

	public function shoot() {
		recoilAnim.reset();
	}
}
