package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.graphics.tile.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import openfl.Assets;

class Level extends Entity
{
    private var walls:Grid;
    private var tiles:Tilemap;
    public var entities(default, null):Array<Entity>;
    public var playerStart(default, null):Vector2;

    public function new(levelName:String) {
        super(0, 0);
        type = "walls";
        loadLevel(levelName);
        updateGraphic();
        mask = walls;
    }

    override public function update() {
        super.update();
    }

    private function loadLevel(levelName:String) {
        var levelData = haxe.Json.parse(Assets.getText('levels/${levelName}.json'));
        for(layerIndex in 0...levelData.layers.length) {
            var layer = levelData.layers[layerIndex];
            if(layer.name == "walls") {
                // Load solid geometry
                walls = new Grid(levelData.width, levelData.height, layer.gridCellWidth, layer.gridCellHeight);
                for(tileY in 0...layer.grid2D.length) {
                    for(tileX in 0...layer.grid2D[0].length) {
                        walls.setTile(tileX, tileY, layer.grid2D[tileY][tileX] == "1");
                    }
                }
            }
            else if(layer.name == "entities") {
                // Load entities
                entities = new Array<Entity>();
                var hazardCount = 1;
                for(entityIndex in 0...layer.entities.length) {
                    var entity = layer.entities[entityIndex];
                    if(entity.name == "player") {
                        playerStart = new Vector2(entity.x, entity.y);
                    }
                    if(entity.name == "sword") {
                        entities.push(new SwordItem(entity.x, entity.y));
                    }
                    if(entity.name == "gladiator") {
                        entities.push(new Gladiator(entity.x, entity.y, hazardCount));
                        hazardCount++;
                    }
                    if(entity.name == "door") {
                        entities.push(new Door(
                                entity.x, entity.y,
                                entity.width, entity.height,
                                entity.values.name,
                                entity.values.destination,
                                entity.values.destinationDoorName,
                                entity.values.startsOpen,
                                new Vector2(
                                    getPointNodes(entity, entity.nodes)[0].x,
                                    getPointNodes(entity, entity.nodes)[0].y
                                )
                        ));
                    }
                    if(entity.name == "shooter") {
                        entities.push(new Shooter(entity.x, entity.y));
                    }
                }
            }
        }
    }

    private function getPointNodes(entity:Dynamic, nodes:Dynamic) {
        var pointNodes = new Array<Vector2>();
        for(i in 0...entity.nodes.length) {
            pointNodes.push(new Vector2(entity.nodes[i].x, entity.nodes[i].y));
        }
        return pointNodes;
    }

    public function updateGraphic() {
        tiles = new Tilemap(
            'graphics/tiles.png',
            walls.width, walls.height, walls.tileWidth, walls.tileHeight
        );
        for(tileX in 0...walls.columns) {
            for(tileY in 0...walls.rows) {
                if(walls.getTile(tileX, tileY)) {
                    tiles.setTile(tileX, tileY, 0);
                }
            }
        }
        graphic = tiles;
    }
}

