package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.utils.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;

class SwordItem extends PitEntity
{
    private var sprite:Image;

    public function new(x:Float, y:Float) {
	    super(x, y);
        name = "sworditem";
        type = "sworditem";
        layer = -10;
        mask = new Hitbox(10, 10);
        sprite = new Image("graphics/sword.png");
        sprite.centerOrigin();
        sprite.x += 5;
        sprite.y += 5;
        sprite.alpha = 0;
        sprite.angle = 900;
        sprite.scale = 3;
        graphic = sprite;
        collidable = false;
    }

    public function dropIn() {
        var fadeTween = new MultiVarTween();
        fadeTween.tween(sprite, {"alpha": 1, "angle": 25, "scale": 1}, 3, Ease.bounceOut);
        addTween(fadeTween, true);
        collidable = true;
    }

    public override function update() {
        super.update();
    }
}
