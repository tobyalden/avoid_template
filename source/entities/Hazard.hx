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
    public static inline var MAX_SPEED = 100;
    public static inline var ACCEL = 100;

    public var sprite:Image;
    public var velocity:Vector2;
    private var phase:Int;
    private var start:Vector2;
    private var phaseTweener:MultiVarTween;

    public function new(x:Float, y:Float) {
        super(x, y);
        type = "hazard";
        mask = new Hitbox(10, 10);
        sprite = new Image("graphics/hazard.png");
        sprite.centerOrigin();
        sprite.x += width / 2;
        sprite.y += height / 2;
        graphic = sprite;
        velocity = new Vector2();
        phase = 1;
        start = new Vector2(x, y);
        phaseTweener = new MultiVarTween();
        phaseTweener.onComplete.bind(function() {
            advancePhase();
        });
        addTween(phaseTweener);
    }

    override public function update() {
        var player = cast(HXP.scene.getInstance("player"), Player);
        if(!player.hasMoved) {
            return;
        }
        if(phase == 1) {
            var towardsPlayer = new Vector2(player.centerX - centerX, player.centerY - centerY);
            towardsPlayer.normalize(ACCEL * HXP.elapsed);
            velocity.add(towardsPlayer);
            if(velocity.length > MAX_SPEED) {
                velocity.normalize(MAX_SPEED);
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
        super.update();
    }

    public function advancePhase() {
        phase += 1;
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

