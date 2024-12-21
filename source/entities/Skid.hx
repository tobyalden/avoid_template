package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

class Skid extends Entity
{
    public var sprite:Image;
    private var fader:VarTween;

    public function new(
        x:Float, y:Float, angle:Float, scale:Float, fadeTime:Float
    ) {
        super(x, y);
        sprite = new Image("graphics/skid.png");
        sprite.centerOrigin();
        sprite.angle = angle;
        sprite.scale = scale;
        graphic = sprite;
        layer = 10;
        fader = new VarTween();
        addTween(fader);
        fader.onComplete.bind(function() {
            HXP.scene.remove(this);
        });
        fader.tween(sprite, "alpha", 0, fadeTime);
    }

    override public function update() {
        super.update();
    }
}
