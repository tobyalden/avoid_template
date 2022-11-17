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

class Hazard extends Entity
{
    public static inline var MAX_CHASE_SPEED = 100;
    public static inline var ACCEL = 100;
    public static inline var MAX_LUNGE_SPEED = 200;
    public static inline var LUNGE_COOLDOWN = 2;

    public var phase(default, null):Int;
    public var sprite:Spritemap;
    public var velocity:Vector2;
    private var start:Vector2;
    private var phaseTweener:MultiVarTween;
    private var lungeCooldown:Alarm;
    private var number:Int;

    public function new(x:Float, y:Float, number:Int) {
        super(x, y);
        this.number = number;
        type = "hazard";
        mask = new Hitbox(10, 10);
        sprite = new Spritemap("graphics/hazard.png", 10, 10);
        sprite.add("idle", [0]);
        sprite.add("tell", [1]);
        sprite.play("idle");
        sprite.centerOrigin();
        sprite.x += width / 2;
        sprite.y += height / 2;
        graphic = sprite;
        velocity = new Vector2();
        phase = 4;
        start = new Vector2(x, y);
        phaseTweener = new MultiVarTween();
        phaseTweener.onComplete.bind(function() {
            advancePhase();
        });
        addTween(phaseTweener);
        lungeCooldown = new Alarm(LUNGE_COOLDOWN);
        addTween(lungeCooldown);
    }

    private function getVectorTowards(entity:Entity) {
        var towardsEntity = new Vector2(entity.centerX - centerX, entity.centerY - centerY);
        return towardsEntity;
    }

    override public function update() {
        if(!getPlayer().hasMoved) {
            return;
        }
        if(phase == 1) {
            // TODO: advance phase
            var towardsPlayer = getVectorTowards(getPlayer());
            towardsPlayer.normalize(ACCEL * HXP.elapsed);
            velocity.add(towardsPlayer);
            if(velocity.length > MAX_CHASE_SPEED) {
                velocity.normalize(MAX_CHASE_SPEED);
            }
            moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed, ["hazard", "walls"]);
        }
        else if(phase == 2) {
            if(!phaseTweener.active) {
                phaseTweener.tween(velocity, {x: 0, y: 0}, 2, Ease.sineInOut);
            }
            moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed, ["hazard", "walls"]);
        }
        else if(phase == 3) {
            if(!phaseTweener.active) {
                phaseTweener.tween(this, {x: start.x, y: start.y}, 2, Ease.sineInOut);
            }
        }
        else if(phase == 4) {
            if(!phaseTweener.active) {
                phaseTweener.tween(this, {x: start.x, y: start.y}, 2, Ease.sineInOut);
            }
        }
        else if(phase == 5) {
            velocity.normalize((1 - lungeCooldown.percent) * MAX_LUNGE_SPEED);
            moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed, ["hazard", "walls"]);
        }
        else if(phase == 6) {
            var allReady = true;
            for(hazard in cast(HXP.scene, GameScene).hazards) {
                if(hazard.phase != 6) {
                    allReady = false;
                }
            }
            if(allReady) {
                for(hazard in cast(HXP.scene, GameScene).hazards) {
                    hazard.lunge();
                    hazard.advancePhase();
                }
            }
        }
        else if(phase == 7) {
            velocity.normalize((1 - lungeCooldown.percent) * MAX_LUNGE_SPEED);
            moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed, ["hazard", "walls"]);
        }
        super.update();
    }

    public function advancePhase() {
        phase += 1;
        if(phase == 5) {
            HXP.alarm(number * 1.5, function() {
                lunge();
            }, this);
        }
    }

    private function lunge() {
        sprite.play("tell");
        HXP.alarm(1, function() {
            sprite.play("idle");
            var towardsPlayer = getVectorTowards(getPlayer());
            velocity = towardsPlayer;
            lungeCooldown.onComplete.bind(function() {
                advancePhase();
            });
            lungeCooldown.start();
        }, this);
    }

    private function getPlayer() {
        return cast(HXP.scene, GameScene).player;
    }

    override public function moveCollideX(e:Entity) {
        velocity.x = -velocity.x * 0.5;
        return true;
    }

    override public function moveCollideY(e:Entity) {
        velocity.y = -velocity.y * 0.5;
        return true;
    }
}

