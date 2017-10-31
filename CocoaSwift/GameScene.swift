//
//  GameScene.swift
//  CocoaSwift
//
//  Created by leig on 09/05/2017.
//  Copyright © 2017 leig. All rights reserved.
//

import SpriteKit
import GameplayKit
import CocoaSwiftKit

// 物理碰撞结构体
struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Monster   : UInt32 = 0b1       // 1
    static let Missile   : UInt32 = 0b10      // 2
}

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
    func sqrt(a: CGFloat) -> CGFloat {
        return CGFloat(sqrtf(Float(a)))
    }
#endif

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x * x + y * y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}

// 自定义游戏场景
class GameScene: SKScene, SKPhysicsContactDelegate {
    // 创建主角
    let player = SKSpriteNode(imageNamed: "Spaceship")
    // 获取工具类
    let tools = Tools()
    // 移动方法
    override func didMove(to view: SKView) {
        // 物理碰撞
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        // 设置背景为白色
        backgroundColor = SKColor.white
        // 定位主角
        player.position = CGPoint(x: size.width * 0.5, y: size.height * 0.1)
        
        // 添加主角
        addChild(player)
        
        // 设置敌人移动的动画
        run(SKAction.repeatForever(SKAction.sequence([
            SKAction.run {
                self.addMonster()
            }, SKAction.wait(forDuration: 1.0)
            ])))
        
       
    }
    // 添加敌人
    func addMonster() {
        // create sprite
        let monster = SKSpriteNode(imageNamed: "EnemySpaceship")
        
        monster.physicsBody = SKPhysicsBody(rectangleOf: monster.size) // 1
        monster.physicsBody?.isDynamic = true // 2
        monster.physicsBody?.categoryBitMask = PhysicsCategory.Monster // 3
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.Missile // 4
        monster.physicsBody?.collisionBitMask = PhysicsCategory.None // 5
        
        // 设置位置
        let actualX = tools.random(min: monster.size.width / 2, max: size.height - monster.size.width / 2)
        // determine where to spawn the monster along the Y axis
//        let actualY = random(min: monster.size.height / 2, max: size.height - monster.size.height / 2)
        
        monster.position = CGPoint(x: actualX, y: size.height + monster.size.width / 2)
        
//        monster.position = CGPoint(x: size.width + monster.size.width / 2, y: actualY)
        // 将敌人加入视图
        addChild(monster)

        let actualDuration = tools.random(min: CGFloat(2.0), max: CGFloat(4.0))
        
        let actionMove = SKAction.move(to: CGPoint(x: actualX, y: -monster.size.height / 2), duration: TimeInterval(actualDuration))
        
//        let actionMove = SKAction.move(to: CGPoint(x: -monster.size.width / 2, y: actualY), duration: TimeInterval(actualDuration))
        // 移除动作
        let actionMoveDone = SKAction.removeFromParent()
        
        monster.run(SKAction.sequence([actionMove, actionMoveDone]))
        
    }
    
    // 点击发射导弹
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else {
            return
        }
    
        let touchLocation = touch.location(in: self)
    
        // 2 - Set up initial location of missile
        let missile = SKSpriteNode(imageNamed: "missile")
        missile.position = player.position
        
        missile.physicsBody = SKPhysicsBody(circleOfRadius: missile.size.height / 2)
//        missile.physicsBody?.isDynamic = true
        missile.physicsBody?.categoryBitMask = PhysicsCategory.Missile
        missile.physicsBody?.collisionBitMask = PhysicsCategory.None
        missile.physicsBody?.contactTestBitMask = PhysicsCategory.Monster
//        missile.physicsBody?.usesPreciseCollisionDetection = true
        
        // 3 - Determine offset of location to missile
        let offset = touchLocation - missile.position
        
        // 4 - Bail out if you are shooting down or backwards
        if (offset.y < 0) { return }
        
        // 5 - OK to add now - you've double checked position
        addChild(missile)

        // 6 - Get the direction of where to shoot
        let direction = offset.normalized()
        
        // 7 - Make it shoot far enough to be guaranteed off screen
        let shootAmount = direction * 1000
        
        // 8 - Add the shoot amount to the current position
        let realDest = shootAmount + missile.position
        
        // 9 - Create the actions
        let actionMove = SKAction.move(to: realDest, duration: 2.0)
        let actionMoveDone = SKAction.removeFromParent()
        missile.run(SKAction.sequence([actionMove, actionMoveDone]))

    }
    
    func missileDidCollideWithMonster(missile:SKSpriteNode, monster:SKSpriteNode) {
        print("Hit")
        missile.removeFromParent()
        monster.removeFromParent()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        // 1
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // 2
        if ((firstBody.categoryBitMask & PhysicsCategory.Monster != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Missile != 0)) {
            missileDidCollideWithMonster(missile: firstBody.node as! SKSpriteNode, monster: secondBody.node as! SKSpriteNode)
        }
    }
}
