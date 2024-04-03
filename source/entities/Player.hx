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

class Player extends PitEntity
{
    public static inline var SPEED = 100;
    public static inline var SWORD_ROTATION_SPEED = 4;
    public static inline var SWORD_LENGTH = 25;

    public var hasMoved(default, null):Bool;
    public var isDead(default, null):Bool;
    public var sword(default, null):Vector2;
    public var hasSword(default, null):Bool;
    private var sprite:Image;
    private var velocity:Vector2;
    private var swordAngle:Float;
    private var rotatingClockwise:Bool;

    public function new(x:Float, y:Float) {
        super(x, y);
        name = "player";
        var hitbox = new Hitbox(10, 10);
        hitbox.x = -5;
        hitbox.y = -5;
        mask = hitbox;
        sprite = new Image("graphics/player.png");
        sprite.centerOrigin();
        graphic = sprite;
        velocity = new Vector2();
        hasMoved = false;
        isDead = false;
        sword = new Vector2(centerX, centerY - SWORD_LENGTH);
        //hasSword = false;
        hasSword = true;
        swordAngle = 0;
        rotatingClockwise = false;
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

        var heading = new Vector2();
        if(Input.check("left")) {
            heading.x = -1;
        }
        else if(Input.check("right")) {
            heading.x = 1;
        }
        else {
            heading.x = 0;
        }
        if(Input.check("up")) {
            heading.y = -1;
        }
        else if(Input.check("down")) {
            heading.y = 1;
        }
        else {
            heading.y = 0;
        }
        velocity = heading;
        velocity.normalize(SPEED);

        moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed, "walls");
        updateSword();

        if(collide("gladiator", x, y) != null && ! Input.check("cheat")) {
            die();
        }
        if(collide("sword", x, y) != null) {
            HXP.scene.remove(HXP.scene.getInstance("sword"));
            getSword();
        }
        var _door = collide("door", x, y);
        if(_door != null) {
            var door = cast(_door, Door);
            if(door.isOpen) {
                cast(HXP.scene, GameScene).useDoor(door);
            }
        }

        sprite.alpha = Input.check("cheat") ? 0.5 : 1;

        super.update();
    }

    private function getSword() {
        hasSword = true;
    }

    public function updateSword() {
        var swordCalc = new Vector2(0, -SWORD_LENGTH);
        //if(velocity.length == 0) {
            swordAngle += (
                HXP.elapsed * SWORD_ROTATION_SPEED * (rotatingClockwise ? -1: 1)
            );
        //}
        swordCalc.rotate(swordAngle);
        sword = new Vector2(centerX + swordCalc.x, centerY + swordCalc.y);
    }

    public function die() {
        isDead = true;
        visible = false;
        explode(50, 1, 4);
        Main.sfx["die"].play();
        cast(HXP.scene, GameScene).onDeath();
    }

    override public function render(camera:Camera) {
        super.render(camera);
        if(hasSword) {
            // Draw sword
            Draw.lineThickness = 3;
            Draw.line(centerX, centerY, sword.x, sword.y);
        }
    }
}
