package client.entity;

import engine.entity.EngineBaseGameEntity;
import engine.entity.EngineShellEntity;

class ClientShell extends ClientBaseGameEntity {
	public function new(s2d:h2d.Scene, engineShellEntity:EngineShellEntity, ownerShip:ClientShip) {
		super();
		initiateEngineEntity(engineShellEntity);

		// Correct initial pos due to ship's position interpolation
		final offset = ownerShip.getCanonOffsetBySideAndIndex(engineShellEntity.side, engineShellEntity.pos);
		final posX = offset.x;
		final posY = offset.y;

		setPosition(posX, posY);
		// Graphics init
		var shellTile = hxd.Res.cannonBall.toTile();
		shellTile = shellTile.center();
		bmp = new h2d.Bitmap(shellTile);
		bmp.rotation = engineShellEntity.rotation;
		addChild(bmp);
		s2d.addChild(this);
	}

	public function update(dt:Float) {
		final dx = engineEntity.currentSpeed * dt * Math.cos(bmp.rotation);
		final dy = engineEntity.currentSpeed * dt * Math.sin(bmp.rotation);
		x += dx;
		y += dy;
	}

	public function getDieEffect() {
		final engineShellEntity = cast(engineEntity, EngineShellEntity);
		return engineShellEntity.dieEffect;
	}
}
