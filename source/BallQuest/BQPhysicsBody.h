//
//  BQPhysicsBody.h
//  SuperBallQuest
//
//  Created by Blake Harrison on 3/4/14.
//  Copyright (c) 2014 Blake Harrison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "glm.hpp"
#import "ext.hpp"
#import "BQGeometry.h"
#import "btBulletDynamicsCommon.h"
#import "btBulletCollisionCommon.h"
#import "Bullet-C-Api.h"
#import "BQConfigurationConstants.h"

typedef enum {
    box,
    circle,
    aabb,
    mesh
} PhysicsBodyShape;

typedef enum {
    dynamicBody,
    kinematicBody,
    staticBody
} PhysicsBodyType;

@interface BQPhysicsBody : BQGeometry
@property(nonatomic)btDefaultMotionState *physicsBodyMotionState;
@property(nonatomic)btRigidBody *physicsBody;
@property(nonatomic)btCollisionShape *physicsBodyShape;
@property(nonatomic)PhysicsBodyShape physicsBodyShapeDefinition;
@property(nonatomic)PhysicsBodyType physicsBodyType;

@property (nonatomic)GLfloat friction;
@property (nonatomic)GLfloat rollingFriction;
@property (nonatomic)GLfloat restitution;
@property (nonatomic)GLfloat mass;
@property (nonatomic)vec3 linearFactor;

@property(nonatomic)vec3 physicsBodyWidthHeightDepth;
@property(nonatomic)GLfloat physicsBodyMaxX;
@property(nonatomic)GLfloat physicsBodyMaxY;
@property(nonatomic)GLfloat physicsBodyMaxZ;

@property(nonatomic)GLfloat physicsBodyMinX;
@property(nonatomic)GLfloat physicsBodyMinY;
@property(nonatomic)GLfloat physicsBodyMinZ;

@property(nonatomic)vec4 originalOrigin;
@property(nonatomic)vec4 origin;

@property(nonatomic)mat4 physicsScaleMatrix;
@property(nonatomic)mat4 inversePhysicsScaleMatrix;

- (id)initWithShape:(tinyobj::shape_t *)shape
    physicsBodyType:(PhysicsBodyType)physicsBodyType
   physicsBodyShape:(PhysicsBodyShape)physicsBodyShape
           friction:(GLfloat)friction
    rollingFriction:(GLfloat)rollingFriction
        restitution:(GLfloat)restitution
               mass:(GLfloat)mass
    andLinearFactor:(btVector3)linearFactor;

- (id)initWithShape:(tinyobj::shape_t *)shape
    physicsBodyType:(PhysicsBodyType)physicsBodyType
   physicsBodyShape:(PhysicsBodyShape)physicsBodyShape
           friction:(GLfloat)friction
    rollingFriction:(GLfloat)rollingFriction
        restitution:(GLfloat)restitution
               mass:(GLfloat)mass;

-(void)createDynamicPhysicsBody;
-(void)destroyDynamicsPhysicsBody;

@end
