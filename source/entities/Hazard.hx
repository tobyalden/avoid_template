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
    public static inline var SPEED = 50;
    public static inline var SHOT_COOLDOWN = 0.1 * 4;
    public static inline var SHOT_SPEED = 100;

    public var sprite:Image;
    public var velocity:Vector2;
    private var shotCooldown:Alarm;

    public function new(x:Float, y:Float) {
        super(x, y);
        type = "hazard";
        mask = new Hitbox(10, 10);
        sprite = new Image("graphics/hazard.png");
        sprite.centerOrigin();
        sprite.x += width / 2;
        sprite.y += height / 2;
        graphic = sprite;
        velocity = new Vector2(HXP.choose(1, -1) * SPEED, HXP.choose(1, -1) * SPEED);
        if(x < GameScene.GAME_WIDTH) {
            velocity.x *= 1.25;
        }
        else {
            velocity.y *= 1.25;
        }
        //velocity = new Vector2((x < GameScene.GAME_WIDTH / 2 ? -1 : 1) * SPEED, -SPEED);
        active = false;
        shotCooldown = new Alarm(SHOT_COOLDOWN);
        addTween(shotCooldown);
    }

    override public function update() {
        shooting();
        moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed, ["walls"]);
        super.update();
    }
    private function shooting() {
        if(!shotCooldown.active) {
            var spreadAmount = Math.PI * 2 * (Math.random() - 0.5);
            for(i in 0...4) {
                var bullet = new Bullet(
                    centerX, centerY,
                    {
                        radius: 2,
                        angle: (sprite.flipX ? -1 : 1) * Math.PI / 2
                            + spreadAmount
                            + Math.PI / 2 * i,
                        speed: SHOT_SPEED,
                        shotByPlayer: false,
                        collidesWithWalls: true
                    }
                );
                scene.add(bullet);
            }
            shotCooldown.start();
        }
    }

    override public function moveCollideX(e:Entity) {
        velocity.x = -velocity.x;
        return true;
    }

    override public function moveCollideY(e:Entity) {
        velocity.y = -velocity.y;
        return true;
    }
}

