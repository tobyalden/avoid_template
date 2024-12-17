package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.utils.*;
import scenes.*;

class Cone extends Entity
{
    public static inline var INITIAL_SPEED = 200;
    public static inline var FRICTION = 350;

    public var sprite:Spritemap;
    public var velocity:Vector2;

    public function new(x:Float, y:Float) {
        super(x, y);
        type = "cone";
        mask = new Hitbox(10, 10);
        sprite = new Spritemap("graphics/tiles.png", 10, 10);
        sprite.add("idle", [0]);
        sprite.add("fallen", [1]);
        sprite.play("idle");
        sprite.centerOrigin();
        graphic = sprite;
        layer = 8;
        velocity = new Vector2();
    }

    public function knockOver(startingVelocity:Vector2) {
        velocity = startingVelocity;
        velocity.normalize(INITIAL_SPEED);
        sprite.play("fallen");
        collidable = false;
        sprite.angle = Math.random() * 360;
    }

    override public function update() {
        var speed = velocity.length;
        if(speed > 0) {
            speed = MathUtil.approach(speed, 0, FRICTION * HXP.elapsed);
            velocity.normalize(speed);
            moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed);
        }
        super.update();
    }
}

