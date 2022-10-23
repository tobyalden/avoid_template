package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import scenes.*;

// TODO: Maybe car movement but fixed forward momentum?

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
        mask = new Hitbox(10, 10);
        sprite = new Image("graphics/player.png");
        sprite.centerOrigin();
        sprite.x += width / 2;
        sprite.y += height / 2;
        graphic = sprite;
        //velocity = new Vector2();
        angle = 90;
        speed = 0;
        hasMoved = false;
        isDead = false;
    }

    override public function update() {
        if(isDead) {
            return;
        }

        for(input in ["left", "right", "up", "down"]) {
            if(Input.check(input)) {
                if(!hasMoved) {
                    cast(HXP.scene, GameScene).onStart();
                }
                hasMoved = true;
            }
        }

        if(!hasMoved) {
            return;
        }

        if(Input.check("left")) {
            angle += TURN_SPEED * HXP.elapsed;
        }
        if(Input.check("right")) {
            angle -= TURN_SPEED * HXP.elapsed;
        }

        //if(Input.check("up")) {
            speed += ACCEL * HXP.elapsed;
        //}
        //else if(Input.check("down")) {
            //speed -= ACCEL * HXP.elapsed;
        //}
        //else {
            //speed = MathUtil.approach(speed, 0, ACCEL * HXP.elapsed);
        //}

        var maxSpeed = MathUtil.lerp(
            INITIAL_MAX_SPEED,
            FINAL_MAX_SPEED,
            cast(HXP.scene, GameScene).difficultyIncreaser.percent
        );
        speed = MathUtil.clamp(speed, -maxSpeed, maxSpeed);

        var velocity = new Vector2();
        MathUtil.angleXY(velocity, angle, speed);

        moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed);

        sprite.angle = angle;

        if(collide("hazard", x, y) != null) {
            die();
        }

        super.update();
    }

    public function die() {
        isDead = true;
        visible = false;
        explode();
        Main.sfx["die"].play();
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
