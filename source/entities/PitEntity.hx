package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import scenes.*;

class PitEntity extends Entity
{
    public static var solids:Array<String> = ["walls"];

    public function new(x:Float, y:Float) {
	    super(x, y);
    }

    public override function update() {
        super.update();
    }

    private function isOnGround() {
        return collideAny(PitEntity.solids, x, y + 1) != null;
    }

    private function isOnCeiling() {
        return collideAny(PitEntity.solids, x, y - 1) != null;
    }

    private function isOnWall() {
        return isOnRightWall() || isOnLeftWall();
    }

    private function isOnRightWall() {
        return collideAny(PitEntity.solids, x + 1, y) != null;
    }

    private function isOnLeftWall() {
        return collideAny(PitEntity.solids, x - 1, y) != null;
    }

    private function collideAny(types:Array<String>, virtualX:Float, virtualY:Float) {
        for(collideType in types) {
            var collided = collide(collideType, virtualX, virtualY);
            if(collided != null) {
                return collided;
            }
        }
        return null;
    }

    private function getScene():GameScene {
        return cast(HXP.scene, GameScene);
    }

    private function getPlayer():Player {
        return cast(HXP.scene, GameScene).player;
    }

    private function collidingWithSword():Bool {
        var player = getPlayer();
        if(!player.hasSword || player.isDead) {
            return false;
        }
        var swordLength = new Vector2(player.sword.x - x, player.sword.y - y);
        swordLength.normalize();
        var checkPoint = new Vector2(player.centerX, player.centerY);
        for(i in 0...Player.SWORD_LENGTH) {
            if(collidePoint(x, y, checkPoint.x, checkPoint.y)) {
                return true;
            }
            checkPoint.add(swordLength);
        }
        return false;
    }

    private function explode(
        numExplosions:Int,
        screenShakeDuration:Float,
        screenShakeMagnitude:Int
    ) {
        var directions = new Array<Vector2>();
        for(i in 0...numExplosions) {
            var angle = (2/numExplosions) * i;
            directions.push(new Vector2(Math.cos(angle), Math.sin(angle)));
            directions.push(new Vector2(-Math.cos(angle), Math.sin(angle)));
            directions.push(new Vector2(Math.cos(angle), -Math.sin(angle)));
            directions.push(new Vector2(-Math.cos(angle), -Math.sin(angle)));
        }
        var count = 0;
        for(direction in directions) {
            direction.scale(0.8 * Math.random());
            direction.normalize(
                Math.max(0.1 + 0.2 * Math.random(), direction.length)
            );
            var explosion = new Particle(
                centerX, centerY, directions[count], 1, 1
            );
            explosion.layer = -99;
            HXP.scene.add(explosion);
            count++;
        }

#if desktop
        Sys.sleep(0.02);
#end
        if(screenShakeDuration > 0) {
            HXP.scene.camera.shake(screenShakeDuration, screenShakeMagnitude);
        }
    }

}
