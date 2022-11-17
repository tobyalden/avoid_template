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
    public static var totalTime:Float = 0;
    public static var highScore:Float;

    public var curtain(default, null):Curtain;
    public var hazards(default, null):Array<Hazard>;
    public var player(default, null):Player;
    private var scoreDisplay:Text;
    private var titleDisplay:Text;
    private var tutorialDisplay:Text;
    private var replayPrompt:Text;
    private var colorChanger:ColorTween;
    private var canReset:Bool;

    override public function begin() {
        Data.load(Main.SAVE_FILE_NAME);
        totalTime = 0;
        highScore = Data.read("highscore", 0);

        curtain = add(new Curtain());
        curtain.fadeOut(0.25);

        addGraphic(new Image("graphics/background.png"));

        player = add(new Player(HXP.width / 2, HXP.height / 2));

        hazards = [
            new Hazard(HXP.width / 4, HXP.height / 4, 1),
            new Hazard(HXP.width / 4 * 3, HXP.height / 4 * 3, 2),
            new Hazard(HXP.width / 4, HXP.height / 4 * 3, 3),
            new Hazard(HXP.width / 4 * 3, HXP.height / 4, 4)
        ];
        for(hazard in hazards) {
            add(hazard);
        }

        add(new Level("level"));

        scoreDisplay = new Text("0", 0, 0, HXP.width, 0);
        scoreDisplay.alpha = 0;
        titleDisplay = new Text("OWIWO");
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

        canReset = false;
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
            scoreDisplay.text = 'Ph${hazards[0].phase} - ${timeRound(totalTime, 0)}';
            scoreDisplay.x = HXP.width / 2 - scoreDisplay.textWidth / 2;
        }

        super.update();
    }

    public function onStart() {
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
