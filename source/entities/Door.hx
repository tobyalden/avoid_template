package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.graphics.Spritemap;
import haxepunk.graphics.text.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.GameScene;

class Door extends PitEntity
{
    public var destination(default, null):String;
    public var isOpen(default, null):Bool;

    public function new(
        x:Float, y:Float, width:Int, height:Int, destination:String,
        name:String
    ) {
        super(x, y);
        this.destination = destination;
        this.name = name;
        type = "walls";
        mask = new Hitbox(width, height);
        graphic = new ColoredRect(width, height, 0x00FFFF);
        isOpen = false;
    }

    public function open() {
        if(isOpen) {
            return;
        }
        isOpen = true;
        HXP.alarm(1, function() {
            type = "door";
        }, this);
    }

    override public function update() {
        if(name == "gladiator") {
            if(getScene().gladiators.length == 0) {
                open();
            }
        }
        graphic.alpha = type == "door" ? 0.1 : 1;
        super.update();
    }
}
