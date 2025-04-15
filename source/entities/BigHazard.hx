package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import scenes.*;

class BigHazard extends Entity
{
    public static inline var INITIAL_MAX_SPEED = 150;
    public static inline var ACCEL = 200;
    public static inline var TURN_SPEED = 150 / 1.25;
    public static inline var TOO_CLOSE_DISTANCE = 100;

    private var sprite:Image;
    private var angle:Float;
    private var speed:Float;

    public function new(x:Float, y:Float) {
        super(x, y);
        type = "hazard";
        mask = new Hitbox(20, 20);
        sprite = new Image("graphics/bighazard.png");
        sprite.centerOrigin();
        sprite.x += width / 2;
        sprite.y += height / 2;
        graphic = sprite;
        angle = 90;
        speed = 0;
    }

    override public function update() {
        var oldAngle = angle;
        var player = cast(HXP.scene.getInstance("player"), Player);
        var targetAngle = MathUtil.angle(
            centerX, centerY, player.centerX, player.centerY
        );
        var altTargetAngle = targetAngle - 360;
        var angleToUse = (
            Math.abs(angle - targetAngle) > Math.abs(angle - altTargetAngle)
            ? altTargetAngle
            : targetAngle
        );

        var avoiding = false;

        if(x < -width || x > GameScene.GAME_WIDTH || y < -height || y > GameScene.GAME_HEIGHT) {
            // Don't avoid other cars while offscreen
        }
        else {
            var otherBigHazards = [];
            HXP.scene.getClass(BigHazard, otherBigHazards);
            otherBigHazards.remove(this);
            for(otherBigHazard in otherBigHazards) {
                if(distanceFrom(otherBigHazard) < TOO_CLOSE_DISTANCE) {
                    var awayAngle = MathUtil.angle(
                        centerX, centerY, otherBigHazard.centerX, otherBigHazard.centerY
                    );
                    awayAngle += 90;
                    angle = MathUtil.approach(
                        angle, awayAngle, TURN_SPEED * HXP.elapsed
                    );
                    avoiding = true;
                }
            }
        }

        if(!player.isDead) {
            var turnSpeed:Float = TURN_SPEED;
            if(avoiding) {
                turnSpeed *= 0.5;
            }
            angle = MathUtil.approach(
                angle, angleToUse, turnSpeed * HXP.elapsed
            );
        }

        speed += ACCEL * HXP.elapsed;
        var maxSpeed:Float = INITIAL_MAX_SPEED;

        if(angle != oldAngle) {
            maxSpeed *= 0.9;
        }

        speed = MathUtil.clamp(speed, -maxSpeed, maxSpeed);

        var velocity = new Vector2();
        MathUtil.angleXY(velocity, angle, speed);

        moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed);

        sprite.angle = angle;

        if(angle != oldAngle) {
            HXP.scene.add(new Skid(centerX, centerY, angle, 2, 10));
        }

        var cones = [];
        collideTypesInto(["cone"], x, y, cones);
        for(cone in cones) {
            cast(cone, Cone).knockOver(velocity);
        }

        super.update();
    }
}


