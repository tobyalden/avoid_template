package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import scenes.*;

class Player extends Entity
{
    public static inline var INITIAL_MAX_SPEED = 120;
    public static inline var FINAL_MAX_SPEED = 170;
    public static inline var ACCEL = 200;
    public static inline var TURN_SPEED = 300;

    public var hasMoved(default, null):Bool;
    public var isDead(default, null):Bool;
    private var sprite:Image;
    private var angle:Float;
    private var speed:Float;

    public function new(x:Float, y:Float) {
        super(x, y);
        name = "player";
        mask = new Circle(5);
        sprite = new Image("graphics/player.png");
        sprite.centerOrigin();
        sprite.x += width / 2;
        sprite.y += height / 2;
        graphic = sprite;
        angle = 90;
        speed = 0;
        hasMoved = false;
        isDead = false;
    }

    override public function update() {
        if(isDead) {
            return;
        }

        if(Input.pressed("reset")) {
            if(!hasMoved) {
                cast(HXP.scene, GameScene).onStart();
                Main.sfx["screech"].loop(0);
            }
            hasMoved = true;
        }

        if(!hasMoved) {
            return;
        }

        var oldAngle = angle;
        if(Input.check("left")) {
            angle += TURN_SPEED * HXP.elapsed;
        }
        if(Input.check("right")) {
            angle -= TURN_SPEED * HXP.elapsed;
        }

        speed += ACCEL * HXP.elapsed;

        var maxSpeed = MathUtil.lerp(
            INITIAL_MAX_SPEED,
            FINAL_MAX_SPEED,
            cast(HXP.scene, GameScene).speedIncreaser.percent
        );

        if(angle != oldAngle) {
            maxSpeed *= 0.9;
        }

        speed = MathUtil.clamp(speed, -maxSpeed, maxSpeed);

        var velocity = new Vector2();
        MathUtil.angleXY(velocity, angle, speed);

        moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed);

        sprite.angle = angle;

        if(collide("hazard", x, y) != null) {
            die();
        }

        if(angle != oldAngle) {
            Main.sfx["screech"].volume = MathUtil.approach(
                Main.sfx["screech"].volume,
                0.25,
                HXP.elapsed * 1.5
            );
            HXP.scene.add(new Skid(centerX, centerY, angle, 1));
            //var dustVelocity = velocity.clone();
            //dustVelocity.scale(0.0009);
            //dustVelocity.inverse();
            //dustVelocity.rotate(Math.PI / 2 * (Math.random() - 0.5));
            //HXP.scene.add(new Particle(
                //centerX, centerY, dustVelocity, 0.25, 1
            //));
        }
        else {
            Main.sfx["screech"].volume = MathUtil.approach(
                Main.sfx["screech"].volume,
                0,
                HXP.elapsed * 2
            );
        }

        super.update();
    }

    public function die() {
        isDead = true;
        visible = false;
        explode();
        Main.sfx["crash"].play();
        Main.sfx["screech"].stop();
        cast(HXP.scene, GameScene).onDeath();
    }

    private function explode() {
        var numExplosions = 50;
        var directions = new Array<Vector2>();
        for(i in 0...numExplosions) {
            var angle = (2/numExplosions) * i;
            directions.push(new Vector2(Math.cos(angle), Math.sin(angle)));
            directions.push(new Vector2(-Math.cos(angle), Math.sin(angle)));
            directions.push(new Vector2(Math.cos(angle), -Math.sin(angle)));
            directions.push(new Vector2(-Math.cos(angle), -Math.sin(angle)));
        }
        var count = 0;
        for(direction in directions) {
            direction.scale(0.8 * Math.random());
            direction.normalize(
                Math.max(0.1 + 0.2 * Math.random(), direction.length)
            );
            var explosion = new Particle(
                centerX, centerY, directions[count], 1, 1
            );
            explosion.layer = -99;
            HXP.scene.add(explosion);
            count++;
        }

#if desktop
        Sys.sleep(0.02);
#end
        HXP.scene.camera.shake(1, 4);
    }
}
