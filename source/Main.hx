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
    public static inline var SAVE_FILE_NAME = "default";

    public static var sfx:Map<String, Sfx> = null;

    static function main() {
        new Main();
    }

    override public function init() {
#if debug
        Console.enable();
#end
        HXP.screen.scaleMode = new UniformScaleMode(UniformScaleType.Expand);
        HXP.fullscreen = false;

        Key.define("left", [Key.A, Key.LEFT]);
        Key.define("right", [Key.D, Key.RIGHT]);
        Key.define("reset", [Key.A, Key.D, Key.LEFT, Key.RIGHT, Key.SPACE, Key.ENTER]);

        if(Gamepad.gamepad(0) != null) {
            defineGamepadInputs(Gamepad.gamepad(0));
        }
        Gamepad.onConnect.bind(function(newGamepad:Gamepad) {
            defineGamepadInputs(newGamepad);
        });

        sfx = [
            "beatrecord" => new Sfx("audio/beatrecord.ogg"),
            "didntbeatrecord" => new Sfx("audio/didntbeatrecord.ogg"),
            "reset" => new Sfx("audio/reset.ogg"),
            "bell" => new Sfx("audio/bell.ogg"),
            "die" => new Sfx("audio/die.ogg")
        ];

        HXP.scene = new GameScene();
    }

    private function defineGamepadInputs(gamepad) {
        gamepad.defineButton("reset", [XboxGamepad.A_BUTTON]);
        gamepad.defineButton("up", [XboxGamepad.DPAD_UP]);
        gamepad.defineButton("down", [XboxGamepad.DPAD_DOWN]);
        gamepad.defineButton("left", [XboxGamepad.DPAD_LEFT]);
        gamepad.defineButton("right", [XboxGamepad.DPAD_RIGHT]);
        gamepad.defineAxis("up", XboxGamepad.LEFT_ANALOGUE_Y, -0.5, -1);
        gamepad.defineAxis("down", XboxGamepad.LEFT_ANALOGUE_Y, 0.5, 1);
        gamepad.defineAxis("left", XboxGamepad.LEFT_ANALOGUE_X, -0.5, -1);
        gamepad.defineAxis("right", XboxGamepad.LEFT_ANALOGUE_X, 0.5, 1);
    }

    override public function update() {
#if desktop
        if(Key.pressed(Key.ESCAPE)) {
            Sys.exit(0);
        }
#end
        super.update();
    }
}
