package scenes;

import entities.*;
import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.graphics.text.*;
import haxepunk.graphics.tile.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import openfl.Assets;

class GameScene extends Scene
{
    public static inline var GAME_SIZE = 180;

    public static inline var GF_GLADIATORS_SLAIN = 0;
    public static inline var GF_IS_NOT_NEW_GAME = 1;

    public static var roomTitles:Map<String, String> = [
        "pit" => "THE PIT",
        "hallway" => "CORRIDOR",
        "gauntlet" => "THE GAUNTLET",
    ];

    public static var totalTime:Float = 0;
    public static var highScore:Float = 0;
    public static var globalFlags:Array<Int> = [];

    public static function addGlobalFlag(addFlag:Int) {
        if(hasGlobalFlag(addFlag)) {
            return;
        }
        globalFlags.push(addFlag);
    }

    public static function hasGlobalFlag(checkFlag:Int) {
        return globalFlags.indexOf(checkFlag) != -1;
    }

    public var curtain(default, null):Curtain;
    public var gladiators(default, null):Array<Gladiator>;
    public var player(default, null):Player;
    private var scoreDisplay:Text;
    private var titleDisplay:Text;
    private var tutorialDisplay:Text;
    private var replayPrompt:Text;
    private var colorChanger:ColorTween;
    private var canReset:Bool;
    private var level:Level;

    private var levelName:String;
    private var entranceDoorName:String;

    public function new(
        levelName:String = "pit",
        entranceDoorName:String = null,
    ) {
        super();
        this.levelName = levelName;
        this.entranceDoorName = entranceDoorName;
    }

    override public function begin() {
        curtain = add(new Curtain());
        curtain.fadeOut(0.25);

        gladiators = [];
        level = add(new Level(levelName));
        var playerStart:Vector2 = new Vector2(GAME_SIZE / 2, GAME_SIZE / 2);
        for(entity in level.entities) {
            if(Type.getClass(entity) == Gladiator) {
                if(hasGlobalFlag(GF_IS_NOT_NEW_GAME)) {
                    continue;
                }
                gladiators.push(cast(entity, Gladiator));
            }
            if(Type.getClass(entity) == Door) {
                var door = cast(entity, Door);
                if(door.name == entranceDoorName) {
                    playerStart = door.entranceLocation.clone();
                }
            }
            add(entity);
        }

        if(playerStart == null) {
            playerStart = new Vector2(level.playerStart.x, level.playerStart.y);
        }
        player = new Player(playerStart.x, playerStart.y);
        add(player);
        if(player.sword != null) {
            add(player.sword);
            player.sword.moveTo(player.centerX, player.centerY);
        }

        scoreDisplay = new Text("0", 0, 0, HXP.width, 0);
        scoreDisplay.alpha = 0;
        var roomTitle = "?";
        if(roomTitles.exists(levelName)) {
            roomTitle = roomTitles[levelName];
        }
        titleDisplay = new Text(roomTitle);
        titleDisplay.centerOrigin();
        titleDisplay.x = HXP.width / 2 - 3; // idk why but you need a 3 pixel offset to get it truly centered
        titleDisplay.y = HXP.height / 2 - 25;
        tutorialDisplay = new Text("arrow keys\nor WASD\nto move", {size: 12});
        tutorialDisplay.centerOrigin();
        tutorialDisplay.x = HXP.width / 2 - 3; // idk why but you need a 3 pixel offset to get it truly centered
        tutorialDisplay.y = HXP.height / 2 + 25;
        for(display in [scoreDisplay, titleDisplay, tutorialDisplay]) {
            addGraphic(display);
        }

        replayPrompt = new Text("NEW RECORD");
        replayPrompt.x = 10;
        replayPrompt.y = HXP.height - replayPrompt.textHeight - 10;
        replayPrompt.alpha = 0;
        addGraphic(replayPrompt, -10);
        colorChanger = new ColorTween(TweenType.PingPong);
        colorChanger.tween(0.25, 0xFF2000, 0xFFFB6E, Ease.sineInOut);
        addTween(colorChanger, true);

        for(text in [titleDisplay, tutorialDisplay, scoreDisplay, replayPrompt]) {
            text.scrollX = 0;
            text.scrollY = 0;
        }

        if(!hasGlobalFlag(GF_IS_NOT_NEW_GAME)) {
            totalTime = 0;
            highScore = Data.read("highscore", 0);
        }
        else {
            tutorialDisplay.alpha = 0;
            player.setHasMoved(true);
            HXP.alarm(0.5, function() {
                fadeOutCenterText(true);
            });
        }

        canReset = false;
    }

    override public function update() {
        debug();

        if(player.isDead) {
            if(Input.pressed("reset") && canReset) {
                reset();
            }
            if(totalTime > highScore) {
                replayPrompt.text = "NEW RECORD";
                replayPrompt.color = colorChanger.color;
            }
            else {
                replayPrompt.text = 'RECORD: ${timeRound(highScore, 2)}';
            }
        }
        else if(player.hasMoved) {
            var oldTotalTime = totalTime;
            totalTime += HXP.elapsed;
            if(totalTime > highScore && oldTotalTime <= highScore && highScore != 0) {
                scoreDisplay.alpha = 1;
                Main.sfx["bell"].play(0.75);
            }
            scoreDisplay.text = '${timeRound(totalTime, 0)}';
            scoreDisplay.x = HXP.width / 2 - scoreDisplay.textWidth / 2;
        }

        super.update();

        camera.x = MathUtil.clamp(player.centerX - GAME_SIZE / 2, level.x, level.width - GAME_SIZE);
        camera.y = MathUtil.clamp(player.centerY - GAME_SIZE / 2, level.y, level.height - GAME_SIZE);
    }

    private function debug() {
        if(Input.pressed("debug_reset")) {
            HXP.scene = new GameScene();
        }
        if(Input.pressed("debug_kill")) {
            var gladiators = [];
            getClass(Gladiator, gladiators);
            for(gladiator in gladiators) {
                cast(gladiator, Gladiator).die();
            }
        }
    }

    public function useDoor(door:Door) {
        addGlobalFlag(GF_IS_NOT_NEW_GAME);
        pause();
        curtain.fadeIn(0.5);
        HXP.alarm(0.5, function() {
            HXP.scene = new GameScene(door.destination, door.destinationDoorName);
        });
    }

    private function pause() {
        for(entity in level.entities) {
            if(Type.getClass(entity) == Door) {
                continue;
            }
            entity.active = false;
        }
    }

    private function unpause() {
        for(entity in level.entities) {
            entity.active = true;
        }
    }

    public function onStart() {
        fadeOutCenterText(false);
        //cast(getInstance("sword"), Sword).dropIn();
        // TODO: Add this back in
    }

    private function fadeOutCenterText(fadeSlowly:Bool) {
        HXP.tween(scoreDisplay, {"alpha": highScore > 0 ? 0.5 : 1}, 0.5);
        for(display in [titleDisplay, tutorialDisplay]) {
            HXP.tween(display, {"alpha": 0}, 0.5);
        }
    }

    public function onDeath() {
        HXP.tween(scoreDisplay, {"y": HXP.height / 2 - scoreDisplay.height / 2, "alpha": 1}, 1.5, {ease: Ease.sineInOut, complete: function() {
            scoreDisplay.text = '${timeRound(totalTime, 2)}\n  SECONDS';
            if(totalTime > highScore) {
                replayPrompt.alpha = 1;
                Main.sfx["beatrecord"].play();
                HXP.alarm(0.25, function() {
                    canReset = true;
                });
            }
            else {
                Main.sfx["didntbeatrecord"].play();
                HXP.tween(
                    replayPrompt,
                    { "alpha": 1 },
                    0.25,
                    {ease: Ease.sineInOut, complete: function() {
                        canReset = true;
                    }}
                );
            }
        }});
        if(totalTime > highScore) {
            Data.write("highscore", totalTime);
            Data.save(Main.SAVE_FILE_NAME);
        }
    }

    public function reset() {
        canReset = false;
        curtain.fadeIn(0.25);
        Main.sfx["reset"].play();
        HXP.alarm(0.25, function() {
            HXP.scene = new GameScene();
        });
    }

    private function timeRound(number:Float, precision:Int = 2) {
        number *= Math.pow(10, precision);
        return Math.floor(number) / Math.pow(10, precision);
    }
}
