package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.tweens.motion.*;
import haxepunk.utils.*;
import scenes.*;

class Ghost extends PitEntity
{
    public static inline var MAX_CHASE_SPEED = 125;
    public static inline var ACCEL = 200;
    public static inline var FADE_IN_TIME = 1.5;

    private var sprite:Image;
    public var velocity:Vector2;
    private var isAwake:Bool;
    private var graveMover:LinearMotion;

    public function new(x:Float, y:Float) {
        super(x, y);
        type = "hazard";
        mask = new Hitbox(20, 20);
        sprite = new Image("graphics/ghost.png");
        sprite.alpha = 0;
        velocity = new Vector2();
        collidable = false;
        graphic = sprite;
        isAwake = false;
        graveMover = new LinearMotion();
        addTween(graveMover);
    }

    override public function update() {
        if(!isAwake && GameScene.hasGlobalFlag(GameScene.GF_PICKED_UP_KEY)) {
            isAwake = true;
            HXP.tween(
                sprite,
                {"alpha": 1},
                FADE_IN_TIME,
                {
                    "tweener": this,
                    "complete": function() {
                        collidable = true;
                    }
                }
            );
        }
        if(isAwake && collidable) {
            var grave = HXP.scene.getInstance("grave");
            if(grave != null) {
                if(!graveMover.active && !GameScene.hasGlobalFlag(GameScene.GF_GHOST_LAID_TO_REST)) {
                    graveMover.setMotion(x, y, grave.x, grave.y, 3, Ease.sineInOut);
                    graveMover.onComplete.bind(function() {
                        HXP.tween(
                            sprite,
                            {"alpha": 0},
                            FADE_IN_TIME,
                            {
                                "tweener": this,
                                "complete": function() {
                                    collidable = true;
                                    GameScene.addGlobalFlag(GameScene.GF_GHOST_LAID_TO_REST);
                                }
                            }
                        );
                    });
                }
                moveTo(graveMover.x, graveMover.y);
            }
            else {
                chasePlayer();
            }
        }
        super.update();
    }

    private function chasePlayer() {
        var towardsPlayer = getVectorTowards(getPlayer());
        towardsPlayer.normalize(ACCEL * HXP.elapsed);
        velocity.add(towardsPlayer);
        if(velocity.length > MAX_CHASE_SPEED) {
            velocity.normalize(MAX_CHASE_SPEED);
        }
        moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed);
    }
}
