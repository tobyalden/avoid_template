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

@:structInit class MapCoordinates {
    public var mapX:Int;
    public var mapY:Int;
}

class GameScene extends Scene
{
    public static inline var GAME_WIDTH = 180;
    public static inline var GAME_HEIGHT = 180;

    public static inline var TIME_TILL_SWORD_DROP = 10;

    public static var totalTime:Float = 0;
    public static var highScore:Float;

    public var curtain(default, null):Curtain;
    private var player:Player;
    private var scoreDisplay:Text;
    private var titleDisplay:Text;
    private var tutorialDisplay:Text;
    private var replayPrompt:Text;
    private var colorChanger:ColorTween;
    private var canReset:Bool;
    private var previousCoordinates:MapCoordinates;
    private var currentLevel:Level;

    override public function begin() {
        Data.load(Main.SAVE_FILE_NAME);
        totalTime = 0;
        highScore = Data.read("highscore", 0);

        curtain = add(new Curtain());
        curtain.fadeOut(0.25);

        addGraphic(new Image("graphics/background.png"));

        currentLevel = loadLevel(0, 0);

        scoreDisplay = new Text("0", 0, 0, 180, 0);
        scoreDisplay.alpha = 0;
        titleDisplay = new Text("THROWN IN THE PIT", 0, 58, 180, 0, {align: TextAlignType.CENTER});
        tutorialDisplay = new Text("arrow keys move", 0, 103, 180, 0, {align: TextAlignType.CENTER, size: 12});
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

        canReset = false;
        previousCoordinates = getCurrentCoordinates();
    }

    override public function update() {
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

        var currentCoordinates = getCurrentCoordinates();
        camera.x = currentCoordinates.mapX * GAME_WIDTH;
        camera.y = currentCoordinates.mapY * GAME_HEIGHT;
        if(
            currentCoordinates.mapX != previousCoordinates.mapX
            || currentCoordinates.mapY != previousCoordinates.mapY
        ) {
            if(Level.exists(currentCoordinates.mapX, currentCoordinates.mapY)) {
                unloadCurrentLevel();
                currentLevel = loadLevel(currentCoordinates.mapX, currentCoordinates.mapY);
            }
        }
        previousCoordinates = currentCoordinates;
    }

    public function getCurrentCoordinates():MapCoordinates {
        return {
            mapX: Std.int(MathUtil.floor(player.centerX / GAME_WIDTH)),
            mapY: Std.int(MathUtil.floor(player.centerY / GAME_HEIGHT))
        }
    }

    public function unloadCurrentLevel() {
        for(entity in currentLevel.entities) {
            if(entity.name == "player") {
                continue;
            }
            remove(entity);
        }
        remove(currentLevel);
    }

    public function loadLevel(levelX:Int, levelY:Int) {
        var level = new Level(levelX, levelY);
        for(entity in level.entities) {
            if(entity.name == "player") {
                if(player == null) {
                    player = cast(entity, Player);
                }
                else {
                    continue;
                }
            }
            add(entity);
        }
        add(level);
        return level;
    }

    public function onStart() {
        HXP.tween(scoreDisplay, {"alpha": highScore > 0 ? 0.5 : 1}, 0.5);
        for(display in [titleDisplay, tutorialDisplay]) {
            HXP.tween(display, {"alpha": 0}, 0.5);
        }
        HXP.alarm(TIME_TILL_SWORD_DROP, function() {
            cast(getInstance("sword"), Sword).dropIn();
        }, TweenType.OneShot, this);
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
