//
//  GameScene.swift
//  CocoaSwift
//
//  Created by leig on 09/05/2017.
//  Copyright © 2017 leig. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    let player = SKSpriteNode(imageNamed: "Spaceship")
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.white
        player.position = CGPoint(x: size.width * 0.5, y: size.height * 0.1)
        addChild(player)
        run(SKAction.repeatForever(SKAction.sequence([
            SKAction.run {
                self.addMonster()
            }, SKAction.wait(forDuration: 1.0)
            ])))
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    func addMonster() {
        // create sprite
        let monster = SKSpriteNode(imageNamed: "EnemySpaceship")
        
        let actualX = random(min: monster.size.width / 2, max: size.height - monster.size.width / 2)
        // determine where to spawn the monster along the Y axis
//        let actualY = random(min: monster.size.height / 2, max: size.height - monster.size.height / 2)
        
        monster.position = CGPoint(x: actualX, y: size.height + monster.size.width / 2)
        
//        monster.position = CGPoint(x: size.width + monster.size.width / 2, y: actualY)
        
        addChild(monster)
        
        let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
        
        let actionMove = SKAction.move(to: CGPoint(x: actualX, y: -monster.size.height / 2), duration: TimeInterval(actualDuration))
        
//        let actionMove = SKAction.move(to: CGPoint(x: -monster.size.width / 2, y: actualY), duration: TimeInterval(actualDuration))
        
        let actionMoveDone = SKAction.removeFromParent()
        
        monster.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
}
