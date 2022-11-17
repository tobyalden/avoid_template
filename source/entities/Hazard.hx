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

// Add in new phases for new game+

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
    private var phaseAge:Int;

    public function new(x:Float, y:Float, number:Int) {
        super(x, y);
        this.number = number;
        type = "hazard";
        var hitbox = new Hitbox(10, 10);
        hitbox.x = -5;
        hitbox.y = -5;
        mask = hitbox;
        sprite = new Spritemap("graphics/hazard.png", 10, 10);
        sprite.add("idle", [0]);
        sprite.add("tell", [1]);
        sprite.play("idle");
        sprite.centerOrigin();
        graphic = sprite;
        velocity = new Vector2();
        phase = 0;
        start = new Vector2(x, y);
        phaseTweener = new MultiVarTween();
        phaseTweener.onComplete.bind(function() {
            advancePhase();
            trace('advancing from phase tweenter');
        });
        addTween(phaseTweener);
        lungeCooldown = new Alarm(LUNGE_COOLDOWN, TweenType.Persist);
        lungeCooldown.onComplete.bind(function() {
            trace('advancing from lunge');
            advancePhase();
        });
        addTween(lungeCooldown);
        phaseAge = 0;
    }

    private function getVectorTowards(entity:Entity) {
        var towardsEntity = new Vector2(entity.centerX - centerX, entity.centerY - centerY);
        return towardsEntity;
    }

    override public function update() {
        //trace('phase at start: ${phase}');
        if(!getPlayer().hasMoved) {
            return;
        }
        if(phase == 0) {
            advancePhase();
        }
        if(phase == 1) {
            if(phaseAge == 0) {
                HXP.alarm(1, function() {
                    advancePhase();
                }, this);
            }
            var towardsPlayer = getVectorTowards(getPlayer());
            towardsPlayer.normalize(ACCEL * HXP.elapsed);
            velocity.add(towardsPlayer);
            if(velocity.length > MAX_CHASE_SPEED) {
                velocity.normalize(MAX_CHASE_SPEED);
            }
            moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed, ["hazard", "walls"]);
        }
        else if(phase == 2) {
            if(phaseAge == 0) {
                phaseTweener.tween(velocity, {x: 0, y: 0}, 2, Ease.sineInOut);
            }
            moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed, ["hazard", "walls"]);
        }
        else if(phase == 3) {
            if(phaseAge == 0) {
                phaseTweener.tween(this, {x: start.x, y: start.y}, 2, Ease.sineInOut);
            }
        }
        else if(phase == 4) {
            if(phaseAge == 0) {
                // Stagger lunges
                HXP.alarm(number * 1.5, function() {
                    lunge();
                }, this);
            }
            velocity.normalize((1 - lungeCooldown.percent) * MAX_LUNGE_SPEED);
            moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed, ["hazard", "walls"]);
        }
        else if(phase == 5) {
            var allReady = true;
            for(hazard in cast(HXP.scene, GameScene).hazards) {
                if(hazard.phase != 5) {
                    allReady = false;
                }
            }
            if(allReady && number == 1) {
                for(hazard in cast(HXP.scene, GameScene).hazards) {
                    hazard.advancePhase();
                    trace('advancing manually');
                    hazard.lunge();
                }
            }
        }
        else if(phase == 6) {
            velocity.normalize((1 - lungeCooldown.percent) * MAX_LUNGE_SPEED);
            moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed, ["hazard", "walls"]);
        }
        else if(phase == 7) {
            if(phaseAge == 0) {
                var topX = HXP.width / 8 + (HXP.width - HXP.width / 4) * [0, 0.33, 0.66, 1][number];
                phaseTweener.tween(this, {x: topX, y: HXP.height / 8}, 2, Ease.sineInOut);
            }
        }
        else if(phase == 8) {
            if(phaseAge == 0) {
                phaseTweener.tween(this, {y: HXP.height / 8 * 7}, 1, Ease.sineInOut);
            }
        }
        else if(phase == 9) {
            if(phaseAge == 0) {
                var leftY = HXP.height / 8 + (HXP.height - HXP.height / 4) * [0, 0.33, 0.66, 1][number];
                phaseTweener.tween(this, {x: HXP.width / 8, y: leftY}, 1, Ease.sineInOut);
            }
        }
        else if(phase == 10) {
            if(phaseAge == 0) {
                phaseTweener.tween(this, {x: HXP.width / 8 * 7}, 0.66, Ease.sineInOut);
            }
        }
        else if(phase == 11) {
            if(phaseAge == 0) {
                var bottomX = HXP.width / 8 + (HXP.width - HXP.width / 4) * [0, 0.33, 0.66, 1][number];
                phaseTweener.tween(this, {x: bottomX, y: HXP.height / 8 * 7}, 0.75, Ease.sineInOut);
            }
        }
        else if(phase == 12) {
            if(phaseAge == 0) {
                phaseTweener.tween(this, {y: HXP.height / 8}, 0.5, Ease.sineInOut);
            }
        }
        else if(phase == 13) {
            if(phaseAge == 0) {
                var rightY = HXP.height / 8 + (HXP.height - HXP.height / 4) * [0, 0.33, 0.66, 1][number];
                phaseTweener.tween(this, {x: HXP.width / 8 * 7, y: rightY}, 0.5, Ease.sineInOut);
            }
        }
        else if(phase == 14) {
            if(phaseAge == 0) {
                phaseTweener.tween(this, {x: HXP.width / 8}, 0.33, Ease.sineInOut);
            }
        }
        super.update();
        phaseAge += 1;
        //trace('phase at end: ${phase}\n');
    }

    public function advancePhase() {
        trace('BOOP');
        phase += 1;
        phaseAge = 0;
    }

    private function lunge() {
        sprite.play("tell");
        HXP.alarm(1, function() {
            sprite.play("idle");
            var towardsPlayer = getVectorTowards(getPlayer());
            velocity = towardsPlayer;
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

