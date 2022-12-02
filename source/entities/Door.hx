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

class Door extends Entity
{
    public var destination(default, null):String;
    public var isOpen(default, null):Bool;

    public function new(x:Float, y:Float, width:Int, height:Int, destination:String
    ) {
        super(x, y);
        name = "door";
        this.destination = destination;
        type = "walls";
        mask = new Hitbox(width, height);
        graphic = new ColoredRect(width, height, 0x00FFFF);
        isOpen = false;
    }

    public function open() {
        isOpen = true;
        type = "door";
    }

    override public function update() {
        graphic.alpha = isOpen ? 0.1 : 1;
        super.update();
    }
}
