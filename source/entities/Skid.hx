package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

class Skid extends Entity
{
    public static inline var FADE_TIME = 1;

    public var sprite:Image;
    private var fader:VarTween;

    public function new(x:Float, y:Float, angle:Float) {
        super(x, y);
        sprite = new Image("graphics/skid.png");
        sprite.centerOrigin();
        sprite.angle = angle;
        graphic = sprite;
        layer = 10;
        fader = new VarTween();
        addTween(fader);
        fader.onComplete.bind(function() {
            HXP.scene.remove(this);
        });
        fader.tween(sprite, "alpha", 0, 2);
    }

    override public function update() {
        super.update();
    }
}
