package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.utils.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;

class Sword extends PitEntity
{
    public var sprite:Image;
    public var hitbox:Polygon;

    public function new() {
	    super(0, 0);
        name = "sword";
        type = "sword";
        layer = -10;
        sprite = new Image("graphics/sword.png");
        sprite.originX = 1.5;
        graphic = sprite;
        hitbox = Polygon.createFromArray([
            0, 0, 3, 0, 3, 25, 0, 25
        ]);
        hitbox.origin = new Vector2(1.5, 0);
        mask = hitbox;
    }

    public override function update() {
        super.update();
    }
}

