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

class Shooter extends PitEntity
{
    public static inline var SHOT_INTERVAL = 0.5;

    private var sprite:Image;
    private var shotTimer:Alarm;

    public function new(x:Float, y:Float) {
        super(x, y);
        layer = -1;
        var hitbox = new Hitbox(10, 10);
        mask = hitbox;
        sprite = Image.createRect(10, 10, 0xFFA500);
        graphic = sprite;
        shotTimer = new Alarm(SHOT_INTERVAL, function() {
            shoot();
        }, TweenType.Looping);
        addTween(shotTimer);
    }

    override public function update() {
        if(!shotTimer.active) {
            shotTimer.start();
        }
        super.update();
    }

    private function shoot() {
        var shotHeading = new Vector2(0, 1);
        var bullet = new Bullet(centerX, centerY, shotHeading);
        bullet.moveBy(-bullet.width / 2, -bullet.height / 2);
        HXP.scene.add(bullet);
    }
}
