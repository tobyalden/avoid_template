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

class Key extends PitEntity
{
    private var sprite:Image;

    public function new(x:Float, y:Float) {
        super(x, y);
        type = "key";
        var hitbox = new Hitbox(10, 10);
        sprite = new Image("graphics/key.png");
        graphic = sprite;
    }

    override public function update() {
        super.update();
    }
}
