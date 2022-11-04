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

    // TODO: Enemies should all have shared health bar

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
            collidePoint(x, y, player.sword.x, player.sword.y)
            || collidePoint(x, y, player.centerX + (player.sword.x - player.centerX) / 2, player.centerY + (player.sword.y - player.centerY) / 2)
        ) {
            sprite.color = 0x000000;
            HXP.scene.remove(this);
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
}

