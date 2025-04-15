import haxepunk.*;
import haxepunk.debug.Console;
import haxepunk.input.*;
import haxepunk.input.gamepads.*;
import haxepunk.math.*;
import haxepunk.screen.UniformScaleMode;
import haxepunk.utils.*;
import openfl.Lib;
import scenes.*;


class Main extends Engine
{
    // leaving a note for my future self: to fix the screen scaling stuff i had to go into Main.js and comment out the line that says "this.scale = window.devicePixelRatio"

    public static inline var SAVE_FILE_NAME = "default";

    public static var sfx:Map<String, Sfx> = null;

    static function main() {
        new Main(540, 540);
    }

    override public function init() {
#if debug
        Console.enable();
#end
        HXP.screen.scaleMode = new UniformScaleMode(UniformScaleType.Expand);

        sfx = [
            "beatrecord" => new Sfx("audio/beatrecord.ogg"),
            "didntbeatrecord" => new Sfx("audio/didntbeatrecord.ogg"),
            "reset" => new Sfx("audio/reset.ogg"),
            "bell" => new Sfx("audio/bell.ogg"),
            "crash" => new Sfx("audio/crash.ogg"),
            "screech" => new Sfx("audio/screech.ogg"),
            "cone1" => new Sfx("audio/cone1.ogg"),
            "cone2" => new Sfx("audio/cone2.ogg"),
            "cone3" => new Sfx("audio/cone3.ogg"),
            "cone4" => new Sfx("audio/cone4.ogg"),
            "honk" => new Sfx("audio/honk.ogg"),
            "camera" => new Sfx("audio/camera.ogg")
        ];

        HXP.scene = new GameScene();
    }

    override public function update() {
        super.update();
    }
}
