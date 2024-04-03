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

class Player extends Entity
{
    public static inline var SPEED = 100;
    public static inline var SWORD_LENGTH = 25;

    public var hasMoved(default, null):Bool;
    public var isDead(default, null):Bool;
    public var sword(default, null):Vector2;
    public var hasSword(default, null):Bool;
    private var sprite:Image;
    private var velocity:Vector2;
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
        hasSword = false;
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
        var towardsSword = new Vector2(centerX - sword.x, centerY - sword.y);
        towardsSword.rotate(HXP.elapsed * 4 * (rotatingClockwise ? -1: 1));
        towardsSword.normalize(SWORD_LENGTH);
        sword.x = centerX - towardsSword.x;
        sword.y = centerY - towardsSword.y;
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

    override public function render(camera:Camera) {
        super.render(camera);
        if(hasSword) {
            // Draw sword
            Draw.lineThickness = 3;
            Draw.line(centerX, centerY, sword.x, sword.y);
        }
    }
}
