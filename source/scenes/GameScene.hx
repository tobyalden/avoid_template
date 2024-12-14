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
    public static inline var INITIAL_SPAWN_INTERVAL = 0.5;
    public static inline var FINAL_SPAWN_INTERVAL = 0.2;
    public static inline var TIME_TO_MAX_DIFFICULTY = 45;

    public static var totalTime:Float = 0;
    public static var highScore:Float;

    public var curtain(default, null):Curtain;
    public var difficultyIncreaser(default, null):Alarm;
    private var player:Player;
    private var scoreDisplay:Text;
    private var titleDisplay:Text;
    private var replayPrompt:Text;
    private var colorChanger:ColorTween;
    private var canReset:Bool;
    private var spawner:Alarm;
    private var level:Level;

    // TODO: At 60 seconds, big red car appears. Moves like you, chases you, squishes cones (allows you to drive through them). Will probably need to bring up FINAL_SPAWN_INTERVAL a sconch.

    // TODO: Generate names for pieces

    override public function begin() {
        Data.load(Main.SAVE_FILE_NAME);
        totalTime = 0;
        highScore = Data.read("highscore", 0);

        curtain = add(new Curtain());
        curtain.fadeOut(0.25);

        addGraphic(new Image("graphics/background.png"), 100);

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

        colorChanger = new ColorTween(TweenType.PingPong);
        colorChanger.tween(0.25, 0xFF2000, 0xFFFB6E, Ease.sineInOut);
        addTween(colorChanger, true);

        canReset = false;
        spawner = new Alarm(INITIAL_SPAWN_INTERVAL, function() {
            spawnHazard(HXP.choose(false, false, false, true));
            var resetTo = MathUtil.lerp(
                INITIAL_SPAWN_INTERVAL,
                FINAL_SPAWN_INTERVAL,
                difficultyIncreaser.percent
            );
            spawner.reset(resetTo);
        }, TweenType.Looping);
        addTween(spawner);
        difficultyIncreaser = new Alarm(TIME_TO_MAX_DIFFICULTY);
        addTween(difficultyIncreaser, true);
    }

    private function spawnHazard(targetPlayer:Bool) {
        var direction = HXP.choose("top", "bottom", "left", "right");
        if(direction == "top") {
            var hazard = new Hazard(0, 0, new Vector2(0, 1));
            if(targetPlayer) {
                hazard.moveTo(player.x, -10);
            }
            else {
                hazard.moveTo(Random.random * (HXP.width - 10), -10);
            }
            add(hazard);
        }
        else if(direction == "bottom") {
            var hazard = new Hazard(0, 0, new Vector2(0, -1));
            if(targetPlayer) {
                hazard.moveTo(player.x, HXP.height);
            }
            else {
                hazard.moveTo(Random.random * (HXP.width - 10), HXP.height);
            }
            add(hazard);
        }
        else if(direction == "left") {
            var hazard = new Hazard(0, 0, new Vector2(1, 0));
            if(targetPlayer) {
                hazard.moveTo(-10, player.y);
            }
            else {
                hazard.moveTo(-10, Random.random * (HXP.height - 10));
            }
            add(hazard);
        }
        else if(direction == "right") {
            var hazard = new Hazard(0, 0, new Vector2(-1, 0));
            if(targetPlayer) {
                hazard.moveTo(HXP.width, player.y);
            }
            else {
                hazard.moveTo(HXP.width, Random.random * (HXP.height - 10));
            }
            add(hazard);
        }
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
    }

    public function onStart() {
        HXP.tween(scoreDisplay, {"alpha": highScore > 0 ? 0.5 : 1}, 0.5);
        for(display in [titleDisplay]) {
            HXP.tween(display, {"alpha": 0}, 0.5);
        }
        spawner.start();
    }

    public function onDeath() {
        spawner.active = false;
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
            HXP.alarm(2, function() {
                HXP.tween(
                    scoreDisplay,
                    {"x": HXP.width - scoreDisplay.textWidth - 10, "y": HXP.height - scoreDisplay.textHeight - 10},
                    1.9,
                    {ease: Ease.sineInOut}
                );
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
