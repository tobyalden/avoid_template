package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

class Bullet extends PitEntity
{
    public static inline var SPEED = 200;

    private var sprite:Image;
    private var velocity:Vector2;

    public function new(x:Float, y:Float, heading:Vector2) {
        super(x, y);
        type = "hazard";
        var hitbox = new Hitbox(5, 5);
        mask = hitbox;
        sprite = Image.createRect(5, 5, 0xFF0000);
        graphic = sprite;
        velocity = heading;
        velocity.normalize(SPEED);
    }

    override public function update() {
        for(i in 0...10) {
            moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed, ["walls"]);
        }
        super.update();
    }

    private function onCollision() {
        HXP.scene.remove(this);
    }

    override public function moveCollideX(e:Entity) {
        onCollision();
        return true;
    }

    override public function moveCollideY(e:Entity) {
        onCollision();
        return true;
    }
}

