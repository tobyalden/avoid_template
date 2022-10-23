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
    public static inline var SPEED = 100;

    public var sprite:Image;
    public var velocity:Vector2;

    public function new(x:Float, y:Float, heading:Vector2) {
        super(x, y);
        type = "hazard";
        mask = new Hitbox(10, 10);
        sprite = new Image("graphics/hazard.png");
        sprite.centerOrigin();
        sprite.x += width / 2;
        sprite.y += height / 2;
        graphic = sprite;
        velocity = heading;
        velocity.normalize(SPEED);
    }

    override public function update() {
        moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed);
        super.update();
    }
}

