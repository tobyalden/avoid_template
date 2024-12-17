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
        if(!player.isDead) {
            angle = MathUtil.approach(
                angle, angleToUse, TURN_SPEED * HXP.elapsed
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
            HXP.scene.add(new Skid(centerX, centerY, angle, 2));
        }

        var cones = [];
        collideTypesInto(["cone"], x, y, cones);
        for(cone in cones) {
            cast(cone, Cone).knockOver(velocity);
        }

        super.update();
    }
}


