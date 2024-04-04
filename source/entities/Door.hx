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
    public var destinationDoorName(default, null):String;
    public var entranceLocation(default, null):Vector2;
    public var isOpen(default, null):Bool;

    public function new(
        x:Float, y:Float, width:Int, height:Int,
        name:String, destination:String, destinationDoorName:String,
        startsOpen:Bool, entranceLocation:Vector2
    ) {
        super(x, y);
        this.name = name;
        this.destination = destination;
        this.destinationDoorName = destinationDoorName;
        this.entranceLocation = entranceLocation;
        mask = new Hitbox(width, height);
        graphic = new ColoredRect(width, height, 0x00FFFF);
        isOpen = startsOpen;

        if(
            name == "portcullis"
            && GameScene.hasGlobalFlag(GameScene.GF_IS_NOT_NEW_GAME)
        ) {
            isOpen = true;
        }

        type = isOpen ? "door" : "walls";
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
        if(name == "portcullis") {
            if(
                getScene().gladiators.length == 0
                && !GameScene.hasGlobalFlag(GameScene.GF_IS_NOT_NEW_GAME)
            ) {
                GameScene.addGlobalFlag(GameScene.GF_GLADIATORS_SLAIN);
                open();
            }
        }
        graphic.alpha = type == "door" ? 0.1 : 1;
        super.update();
    }
}
