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

// TODO: Add sfx for "honk honk!" big car arrival and cones getting knocked over
// TODO: Oggify sfx

class GameScene extends Scene
{
    public static inline var INITIAL_SPAWN_INTERVAL = 0.6;
    public static inline var FINAL_SPAWN_INTERVAL = 0.2;

    public static inline var TIME_TO_MAX_DIFFICULTY = 30;
    public static inline var TIME_TO_MAX_SPEED = 30;
    public static inline var BIG_HAZARD_SPAWN_TIME_OFFSET = 5;

    //public static inline var TIME_TO_MAX_DIFFICULTY = 4;
    //public static inline var TIME_TO_MAX_SPEED = 4;
    //public static inline var BIG_HAZARD_SPAWN_TIME_OFFSET = 3;

    public static var totalTime:Float = 0;
    public static var highScore:Float;

    public var curtain(default, null):Curtain;
    public var difficultyIncreaser(default, null):Alarm;
    public var speedIncreaser(default, null):Alarm;
    private var player:Player;
    private var scoreDisplay:Text;
    private var titleDisplay:Text;
    private var replayPrompt:Text;
    private var screenshotPrompt:Text;
    private var colorChanger:ColorTween;
    private var canReset:Bool;
    private var spawner:Alarm;
    private var bigSpawner:Alarm;
    private var level:Level;

    private var canTakeScreenshot:Bool;

    override public function begin() {
        Data.load(Main.SAVE_FILE_NAME);
        totalTime = 0;
        highScore = Data.read("highscore", 0);

        curtain = add(new Curtain());
        curtain.fadeOut(0.25);

        addGraphic(new Image("graphics/background.png"), 100);

        canTakeScreenshot = false;

        level = add(new Level("level"));
        for(entity in level.entities) {
            if(entity.name == "player") {
                player = cast(entity, Player);
            }
            add(entity);
        }

        scoreDisplay = new Text("0", 0, 0, 540, 0);
        scoreDisplay.alpha = 0;
        titleDisplay = new Text("CAR ARTIST\n\n\n\npress left or right", 0, 0, 540, 0, {align: TextAlignType.CENTER});
        titleDisplay.y = 540 / 2 - titleDisplay.height / 2 - 5;
        for(display in [scoreDisplay, titleDisplay]) {
            addGraphic(display);
        }

        replayPrompt = new Text("NEW RECORD");
        replayPrompt.x = 10;
        replayPrompt.y = HXP.height - replayPrompt.textHeight - 10;
        replayPrompt.alpha = 0;
        addGraphic(replayPrompt, -10);

        screenshotPrompt = new Text("PRESS P TO TAKE SCREENSHOT", 0, 25, 540, 0, {align: TextAlignType.CENTER});
        screenshotPrompt.alpha = 0;
        addGraphic(screenshotPrompt, -10);

        colorChanger = new ColorTween(TweenType.PingPong);
        colorChanger.tween(0.25, 0xFF2000, 0xFFFB6E, Ease.sineInOut);
        addTween(colorChanger, true);

        canReset = false;
        spawner = new Alarm(INITIAL_SPAWN_INTERVAL, function() {
            spawnHazard(HXP.choose(false, false, false, true), false);
            var resetTo = MathUtil.lerp(
                INITIAL_SPAWN_INTERVAL,
                FINAL_SPAWN_INTERVAL,
                difficultyIncreaser.percent
            );
            spawner.reset(resetTo);
        }, TweenType.Looping);
        addTween(spawner);

        bigSpawner = new Alarm(BIG_HAZARD_SPAWN_TIME_OFFSET, function() {
            spawnHazard(true, true);
            Main.sfx["honk"].play(0.1);
        });
        addTween(bigSpawner);

        difficultyIncreaser = new Alarm(
            TIME_TO_MAX_DIFFICULTY, TweenType.Looping
        );
        difficultyIncreaser.onComplete.bind(function() {
            bigSpawner.start();
        });
        addTween(difficultyIncreaser);

        speedIncreaser = new Alarm(TIME_TO_MAX_SPEED);
        addTween(speedIncreaser);
    }

    private function spawnHazard(targetPlayer:Bool, isBig:Bool) {
        var direction = HXP.choose("top", "bottom", "left", "right");
        var offset = isBig ? 200 : 10;
        if(direction == "top") {
            var hazard:Entity = (
                isBig
                ? new BigHazard(0, 0)
                : new Hazard(0, 0, new Vector2(0, 1))
            );
            if(targetPlayer) {
                hazard.moveTo(player.x, -offset);
            }
            else {
                hazard.moveTo(Random.random * (HXP.width - offset), -offset);
            }
            add(hazard);
        }
        else if(direction == "bottom") {
            var hazard:Entity = (
                isBig
                ? new BigHazard(0, 0)
                : new Hazard(0, 0, new Vector2(0, -1))
            );
            if(targetPlayer) {
                hazard.moveTo(player.x, HXP.height + offset);
            }
            else {
                hazard.moveTo(Random.random * (HXP.width - offset), HXP.height);
            }
            add(hazard);
        }
        else if(direction == "left") {
            var hazard = new Hazard(0, 0, new Vector2(1, 0));
            var hazard:Entity = (
                isBig
                ? new BigHazard(0, 0)
                : new Hazard(0, 0, new Vector2(1, 0))
            );
            if(targetPlayer) {
                hazard.moveTo(-offset, player.y);
            }
            else {
                hazard.moveTo(-offset, Random.random * (HXP.height - offset));
            }
            add(hazard);
        }
        else if(direction == "right") {
            var hazard:Entity = (
                isBig
                ? new BigHazard(0, 0)
                : new Hazard(0, 0, new Vector2(-1, 0))
            );
            if(targetPlayer) {
                hazard.moveTo(HXP.width + offset, player.y);
            }
            else {
                hazard.moveTo(HXP.width, Random.random * (HXP.height - offset));
            }
            add(hazard);
        }
    }

    override public function update() {
        if(Input.pressed("screenshot") && canTakeScreenshot) {
            screenshotPrompt.visible = false;
            Main.sfx["camera"].play(0.5);
        }
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
    }

    public function onStart() {
        HXP.tween(scoreDisplay, {"alpha": highScore > 0 ? 0.5 : 1}, 0.5);
        for(display in [titleDisplay]) {
            HXP.tween(display, {"alpha": 0}, 0.5);
        }
        spawner.start();
        difficultyIncreaser.start();
        speedIncreaser.start();
    }

    private function stopTweens() {
        for(tween in [
            spawner, bigSpawner, difficultyIncreaser, speedIncreaser
        ]) {
            tween.active = false;
        }
    }

    public function onDeath() {
        stopTweens();
        HXP.tween(scoreDisplay, {"y": HXP.height / 2 - scoreDisplay.height / 2, "alpha": 1}, 1.5, {ease: Ease.sineInOut, complete: function() {
            scoreDisplay.text = '${timeRound(totalTime, 2)} SECONDS';
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
            HXP.alarm(1, function() {
                HXP.tween(
                    scoreDisplay,
                    {"x": HXP.width - scoreDisplay.textWidth - 46, "y": HXP.height - scoreDisplay.textHeight - 10},
                    1,
                    {ease: Ease.sineInOut}
                );
                HXP.alarm(1, function() {
                    screenshotPrompt.alpha = 1;
                    canTakeScreenshot = true;
                });
            });
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
