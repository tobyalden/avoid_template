package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import scenes.*;

class Hazard extends Entity
{
    public static inline var MAX_SPEED = 100;
    public static inline var ACCEL = 100;

    public var sprite:Image;
    public var velocity:Vector2;

    public function new(x:Float, y:Float) {
        super(x, y);
        type = "hazard";
        mask = new Hitbox(10, 10);
        sprite = new Image("graphics/hazard.png");
        sprite.centerOrigin();
        sprite.x += width / 2;
        sprite.y += height / 2;
        graphic = sprite;
        velocity = new Vector2();
    }

    override public function update() {
        var player = cast(HXP.scene.getInstance("player"), Player);
        if(!player.hasMoved) {
            return;
        }
        var towardsPlayer = new Vector2(player.centerX - centerX, player.centerY - centerY);
        towardsPlayer.normalize(ACCEL * HXP.elapsed);
        velocity.add(towardsPlayer);
        if(velocity.length > MAX_SPEED) {
            velocity.normalize(MAX_SPEED);
        }
        if(
            player.hasSword
            && !player.isDead
            && (collidePoint(x, y, player.sword.x, player.sword.y)
            || collidePoint(x, y, player.centerX + (player.sword.x - player.centerX) / 2, player.centerY + (player.sword.y - player.centerY) / 2))
        ) {
            sprite.color = 0x000000;
            HXP.scene.remove(this);
            explode();
        }
        else {
            sprite.color = 0xFFFFFF;
        }
        moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed, ["walls", "hazard"]);
        super.update();
    }

    override public function moveCollideX(e:Entity) {
        velocity.x = -velocity.x * 0.5;
        return true;
    }

    override public function moveCollideY(e:Entity) {
        velocity.y = -velocity.y * 0.5;
        return true;
    }

    private function explode() {
        var numExplosions = 20;
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
            direction.scale(0.7 * Math.random());
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
        //HXP.scene.camera.shake(1, 4);
    }
}

