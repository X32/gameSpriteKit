//
//  GameScene.swift
//  ControlButton
//
//  Created by WTFKL on 17/9/11.
//  Copyright © 2017年 WTF. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene:  SKScene,SKPhysicsContactDelegate  {
    var k_centerPoint : SKShapeNode!;
    var Player : SKSpriteNode!;
    var k_circle : SKShapeNode!;
    var isMoving : Bool!;
    var dt: TimeInterval = 0
    var lastUpdateTime: TimeInterval = 0
    var velocity = CGPoint.init(x: 100, y: 100)
    let zombieMovePointsPerSec: CGFloat = 480.0
    let zombieRotateRadiansPerSec :CGFloat = 5.0 * π
    var ZBRotation:CGFloat = 0
    var var_x:CGFloat = 0
    var var_y:CGFloat = 0
    var po_x:CGFloat = 0
    var po_y:CGFloat = 0
//    var ze = CGPoint.init(x: 0, y: 0)
    
    var lastTouchLocation: CGPoint?
    let zombie: SKSpriteNode = SKSpriteNode(imageNamed: "zombie1")
    let ship: SKSpriteNode = SKSpriteNode(imageNamed: "ship")
    override func didMove(to view: SKView) {
        self.anchorPoint = CGPoint(x: 0, y: 0);
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsWorld.contactDelegate = self
        
        gameController();
        creatZombie()
        creatShip()
    }
    //创建敌人
    func creatShip()  {
        
        
        //ship
        ship.position = CGPoint(x: 100, y: 100)
        ship.setScale(0.3)
        
        addChild(ship)
        //设置移动的动作
        let leftMove = SKAction.move(
            to: CGPoint(x:100,y: 100),
            duration: 3)
        //设置移动的动作
        let rightMove = SKAction.move(
            to: CGPoint(x: 600, y: 600),
            duration: 3)
        let sequence = SKAction.sequence([leftMove, rightMove])
        let runForever=SKAction.repeatForever(sequence)
        ship.physicsBody = SKPhysicsBody(rectangleOf: ship.frame.size)
        ship.physicsBody?.categoryBitMask = 1
        ship.physicsBody?.affectedByGravity = false
        ship.physicsBody?.contactTestBitMask = 2
        ship.run(runForever)
    }
    
    //创建主角
    func creatZombie()  {

        //zombie
        zombie.position = CGPoint(x: 400, y: 200)
        zombie.setScale(0.4)
        
        addChild(zombie)
    
        var textures:[SKTexture] = []
        
        for i in 1...4 {
            textures.append(SKTexture(imageNamed: "zombie\(i)"))
        }
        
        textures.append(textures[2])
        textures.append(textures[1])
        
        let zombieAnimation = SKAction.repeatForever(
            SKAction.animate(with: textures, timePerFrame: 0.1))
        zombie.run(zombieAnimation)
        creatSootBtn()
    }
    //设计按钮
    func creatSootBtn() {
        // 创建一个常规的button
        let button = UIButton(type:.custom)
        button.frame = CGRect(x:620, y:280, width:80, height:80)
        button.setTitleColor(UIColor.red, for: .normal)
        button.layer.cornerRadius = 39;
        button.layer.masksToBounds = true;
        button.setTitle("shoot", for: .normal)
        button.backgroundColor = .gray
        //带button参数传递
        button.addTarget(self, action: #selector(buttonClick1), for: .touchUpInside)
        
        self.view?.addSubview(button)
    }
    
    @objc func buttonClick1() {
        NSLog("good")
        createBullet()
        
    }
    //控制按钮
    func gameController(){
        //设置大圆
        self.backgroundColor = SKColor.black;
        k_circle = SKShapeNode.init(rectOf: CGSize.init(width: 106, height: 106), cornerRadius: 53);
        k_circle.position = CGPoint(x: 100, y: 100);
        k_circle.lineWidth = 2;
        k_circle.name = "k_circle";
        addChild(k_circle)
        //设置中心点
        k_centerPoint = SKShapeNode.init(circleOfRadius: 6);
        k_centerPoint.fillColor = SKColor.white;
        k_centerPoint.position = CGPoint(x: 100, y: 100);
        k_centerPoint.name = "k_centerPoint";
        addChild(k_centerPoint);
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {

        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
        

        if !__CGPointEqualToPoint(velocity, k_circle.position) {

            rotateSprite(sprite: zombie, direction: velocity, rotateRadiansPerSec: zombieRotateRadiansPerSec)

            var pos = zombie.position;
            pos.x = pos.x + var_x * 0.1;
            pos.y = pos.y + var_y * 0.1;
            zombie.position = pos;
        }
        
         collsion()
        

    }

    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        k_centerPoint.position = CGPoint(x: 100, y: 100)//触摸结束，将中心点复位
        velocity = CGPoint(x: 100, y: 100)//触摸结束，将中心点复位
        var_x = 0;
        var_y = 0;
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {

        for t in touches {
            let position = t.location(in: self);
            let moveX = position.x - 100;
            let moveY = position.y - 100;
            let length = moveX * moveX + moveY * moveY;
            let lg = sqrt(length);
            if lg < 50 {
                k_centerPoint.position = position;
            }else{
                let outY = (50 * moveY)/lg;
                let outX = (50 * moveX)/lg;
                print("print(outY)",outY,"------",outX);
                k_centerPoint.position = CGPoint(x: outX + 100, y: outY + 100);
              

            }
            var_x = moveX;
            var_y = moveY;
            po_x = moveX;
            po_y = moveY;
        }
        lastTouchLocation = k_centerPoint.position
        moveZombieToward(location: k_centerPoint.position)
        
    }
    
    //角色朝向
    func moveZombieToward(location: CGPoint) {
        
        let offset = location - k_circle.position
        let direction = offset.normalized()
        velocity = direction * zombieMovePointsPerSec
    }
    
    func rotateSprite(sprite: SKSpriteNode, direction: CGPoint, rotateRadiansPerSec: CGFloat) {
        let shortest = shortestAngleBetween(angle1: sprite.zRotation, angle2: velocity.angle)
        let amountToRotate = min(rotateRadiansPerSec * CGFloat(dt), abs(shortest))
        sprite.zRotation += shortest.sign() * amountToRotate
        ZBRotation = amountToRotate
    }
    
    //创建子弹
    func createBullet() {
        
        let bullet = SKSpriteNode(imageNamed: "starBullet")
        bullet.position = zombie.position
        bullet.name = "bullet"
        bullet.zPosition = 1.0
        bullet.setScale(0.1)
        bullet.physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: 0, y: 0, width: bullet.size.width, height: bullet.size.height))
        bullet.physicsBody?.categoryBitMask = 2
        bullet.physicsBody?.contactTestBitMask = 1
        self.addChild(bullet)
        
        var bt:CGFloat = 1
        if po_y != 0 {
            bt = fabs(po_x)/fabs(po_y)
        }
        
       
        
        var movPoint:CGPoint ;
        if( po_y == 0 &&  po_x == 0)  {
            movPoint = CGPoint(x:self.frame.size.width ,y: zombie.position.y)
        }
        else
        {
            movPoint = CGPoint(x: zombie.position.x + self.frame.size.width * bt * po_x.sign(), y:  self.frame.size.width * po_y.sign());
        }
  
        //发射子弹
        let fireAction = SKAction.move(to: movPoint, duration: 2)
        //子弹离开屏幕消失
        let endAction = SKAction.run {
            bullet.removeFromParent()
        }
        //动作组合
        let fireSequence = SKAction.sequence([fireAction,endAction])
        bullet.run(fireSequence)
    }
    
    //
    func didBegin(_ contact: SKPhysicsContact)  {
        //为方便我们判断碰撞的bodyA和bodyB的cateBitMask哪个小，小的则将它保存在新建的变脸bodyA里，大的则保存到新建d变量bodyB里
        var bodyA:SKPhysicsBody
        var bodyB:SKPhysicsBody
        if contact.bodyA.categoryBitMask > contact.bodyB.categoryBitMask {
            bodyA = contact.bodyA
            bodyB = contact.bodyB
        } else {
            bodyA = contact.bodyB
            bodyB = contact.bodyA
        }
        
        //判断bodyA是否为子弹，bodyB是否为飞碟，如果是则游戏结束，直接调用爆炸方法
        if (bodyA.categoryBitMask == 2 && bodyB.categoryBitMask == 1) {
            //在飞碟的位置爆炸
            bomb(node: ship)
            bodyB.node?.removeFromParent()
            bodyA.node?.removeFromParent()
            
        }
    }
    
    
    //粒子特效碰撞后爆炸
    func bomb(node:SKSpriteNode){
        let emitter = SKEmitterNode(fileNamed: "SmallExplosion.sks")    //实例化粒子系统对象
        let explosionTexture = SKTexture(imageNamed: "spark.png")
        emitter?.particleTexture = explosionTexture
        let scaleFactor = (self.size.height / 640.0) * 2
        emitter?.xScale = scaleFactor
        emitter?.yScale = scaleFactor
        emitter?.position = node.position
        emitter?.zPosition = 5
        self.addChild(emitter!)
        
        let customAction1=SKAction.customAction(withDuration: 2) { node, elapsedTime in
            let nextScene=GameScene(size: self.size)
            self.view?.presentScene(nextScene)
            //            self.creatShip()
        }
        
        let wait=SKAction.wait(forDuration: 3)
        let a=SKAction.sequence([wait,customAction1])
        emitter!.run(a)
    }
    
    //碰撞检测
    func collsion()  {
        if (zombie.intersects(ship)) {
            ship.removeFromParent()
            zombie.removeFromParent()
            bomb(node: zombie)
        }
        
    }
    
}
