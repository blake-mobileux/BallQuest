//
//  BQPhysicsBody.m
//  SuperBallQuest
//
//  Created by Blake Harrison on 3/4/14.
//  Copyright (c) 2014 Blake Harrison. All rights reserved.
//

#import "BQPhysicsBody.h"

@implementation BQPhysicsBody

- (id)initWithShape:(tinyobj::shape_t *)shape
    physicsBodyType:(PhysicsBodyType)physicsBodyType
   physicsBodyShape:(PhysicsBodyShape)physicsBodyShape
           friction:(GLfloat)friction
    rollingFriction:(GLfloat)rollingFriction
        restitution:(GLfloat)restitution
               mass:(GLfloat)mass
    andLinearFactor:(btVector3)linearFactor
{
    self = [super initWithShape:shape];
    
    if(self){
        [self updatePhysicsBodyDimensions];
        [self setPhysicsScaleMatrices];
        
        _physicsBodyType = physicsBodyType;
        _physicsBodyShapeDefinition = physicsBodyShape;
        _friction = friction;
        _rollingFriction = rollingFriction;
        _restitution = restitution;
        _mass = mass;
        _linearFactor = vec3(linearFactor.x(), linearFactor.y(), linearFactor.z());
        
        [self createDynamicPhysicsBody];
        
        self.originalOrigin = self.origin;
    }
    
    return self;
}

-(void)createDynamicPhysicsBody{
    if(self.physicsBodyShapeDefinition == box){
        [self setupPhysicsShapeAsBox];
    }
    else if(self.physicsBodyShapeDefinition == circle){
        [self setupPhysicsShapeAsCircle];
    }
    
    btTransform initialTransform;
    initialTransform.setIdentity();
    
    btVector3 localInertia(0.0f, 0.0f, 0.0f);
    if(self.mass > 0.0f){
        _physicsBodyShape->calculateLocalInertia(self.mass, localInertia);
    }
    
    initialTransform.setOrigin(btVector3(self.origin.x,
                                         self.origin.y,
                                         self.origin.z));
    
    self.physicsBodyMotionState = new btDefaultMotionState(initialTransform);
    
    btRigidBody::btRigidBodyConstructionInfo physicsBodyInfo(self.mass, self.physicsBodyMotionState, _physicsBodyShape, localInertia);
    physicsBodyInfo.m_friction = self.friction;
    physicsBodyInfo.m_restitution = self.restitution;
    
    _physicsBody = new btRigidBody::btRigidBody(physicsBodyInfo);
    _physicsBody->setActivationState(DISABLE_DEACTIVATION);
}

-(void)destroyDynamicsPhysicsBody{
    if(self.physicsBodyMotionState != NULL){
        delete self.physicsBody;
        self.physicsBody = NULL;
    }
    
    if(self.physicsBody != NULL){
        delete self.physicsBody;
        self.physicsBody = NULL;
    }
}

- (id)initWithShape:(tinyobj::shape_t *)shape
    physicsBodyType:(PhysicsBodyType)physicsBodyType
   physicsBodyShape:(PhysicsBodyShape)physicsBodyShape
           friction:(GLfloat)friction
    rollingFriction:(GLfloat)rollingFriction
        restitution:(GLfloat)restitution
               mass:(GLfloat)mass{
    btVector3 linearFactor(1.0f, 1.0f, 1.0f);
    return [self initWithShape:shape physicsBodyType:physicsBodyType physicsBodyShape:physicsBodyShape friction:friction rollingFriction:rollingFriction restitution:restitution mass:mass andLinearFactor:linearFactor];
}

-(void)setupPhysicsShapeAsBox{
    _physicsBodyShape = new btBoxShape(btVector3((GLfloat)self.physicsBodyWidthHeightDepth.x/2.0f,
                                                 (GLfloat)self.physicsBodyWidthHeightDepth.y/2.0f,
                                                 (GLfloat)self.physicsBodyWidthHeightDepth.z/2.0f));
}

-(void)setupPhysicsShapeAsCircle{
    GLfloat radius = (GLfloat)(MAX(MAX(self.physicsBodyWidthHeightDepth.x, self.physicsBodyWidthHeightDepth.y), self.physicsBodyWidthHeightDepth.z))/2.0f;
    _physicsBodyShape = new btSphereShape(btScalar(radius));
}

-(void)setupPhysicsShapeAsStaticMesh{
    GLfloat radius = (GLfloat)(MAX(MAX(self.physicsBodyWidthHeightDepth.x, self.physicsBodyWidthHeightDepth.y), self.physicsBodyWidthHeightDepth.z))/2.0f;
    _physicsBodyShape = new btSphereShape(btScalar(radius));
}

-(void)updatePhysicsBodyDimensions{
    self.physicsBodyMaxX = self.maxX * GEOMETRY_TO_PHYSICS_WORLD_CONVERSION_FACTOR;
    self.physicsBodyMaxY = self.maxY * GEOMETRY_TO_PHYSICS_WORLD_CONVERSION_FACTOR;
    self.physicsBodyMaxZ = self.maxZ * GEOMETRY_TO_PHYSICS_WORLD_CONVERSION_FACTOR;
    self.physicsBodyMinX = self.minX * GEOMETRY_TO_PHYSICS_WORLD_CONVERSION_FACTOR;
    self.physicsBodyMinY = self.minY * GEOMETRY_TO_PHYSICS_WORLD_CONVERSION_FACTOR;
    self.physicsBodyMinZ = self.minZ * GEOMETRY_TO_PHYSICS_WORLD_CONVERSION_FACTOR;
    
    self.physicsBodyWidthHeightDepth = vec3(abs(self.physicsBodyMaxX - self.physicsBodyMinX), abs(self.physicsBodyMaxY - self.physicsBodyMinY), abs(self.physicsBodyMaxZ - self.physicsBodyMinZ));
    self.origin = vec4((self.physicsBodyMaxX + self.physicsBodyMinX) /2, (self.physicsBodyMaxY + self.physicsBodyMinY) /2, (self.physicsBodyMaxZ + self.physicsBodyMinZ) /2, 1.0f);
}

-(void)setPhysicsScaleMatrices{
    self.physicsScaleMatrix = scale(mat4(1.0f),vec3(GEOMETRY_TO_PHYSICS_WORLD_CONVERSION_FACTOR, GEOMETRY_TO_PHYSICS_WORLD_CONVERSION_FACTOR, GEOMETRY_TO_PHYSICS_WORLD_CONVERSION_FACTOR));
    self.inversePhysicsScaleMatrix = scale(mat4(1.0f), vec3((GLfloat)1.0f/GEOMETRY_TO_PHYSICS_WORLD_CONVERSION_FACTOR,(GLfloat) 1.0f/GEOMETRY_TO_PHYSICS_WORLD_CONVERSION_FACTOR,(GLfloat) 1.0f/GEOMETRY_TO_PHYSICS_WORLD_CONVERSION_FACTOR));
}

@end
