//
//  BQScene.h
//  SuperBallQuest
//
//  Created by Blake Harrison on 3/4/14.
//  Copyright (c) 2014 Blake Harrison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import <OpenGLES/ES2/glext.h>
#import "glm.hpp"
#import "ext.hpp"
#import "tiny_obj_loader.h"
#import "BQGeometry.h"
#import "BQGameConstants.h"
#import "BQPhysicsBody.h"
#import "btBulletDynamicsCommon.h"
#import "BQHudService.h"
#import "BQInteractionService.h"
#import "BQConfigurationConstants.h"
#define DEFAULT_ROTATION_SCALE .15f

typedef std::map<BQPhysicsBody *, btCollisionObject*> GModelShapeMap;

using namespace std;

@interface BQScene : NSObject
<UIAlertViewDelegate>
{
    vector<tinyobj::shape_t> _shapes;
    
    vector<vec4> _pointLightsLocal;
    vector<vec4> _viewSpacePointLightsLocal;
    
    vector<vec4> _cameraPositions;
    vector<vec4> _cameraLookatVectors;
    vector<vec3> _cameraUpVectors;
    
    vector<vec4> _pointLightDiffuseIntensitiesLocal;
    vector<vec4> _pointLightSpecularIntensitiesLocal;
    vector<vec4> _nullLightsLocal;
    
    BQPhysicsBody *_user_character_ball_a;
    
    GLuint _glesTexturesLocal[NUMBER_OF_TEXTURES];
    
    GModelShapeMap _modelShapeMap;
    
    mat4 _canonicalViewScaleMatrix;
    
    btDefaultCollisionConfiguration *_collisionConfiguration;
    btCollisionDispatcher *_dispatcher;
    btBroadphaseInterface *_overlappingPairCache;
    btSequentialImpulseConstraintSolver *_solver;
    btDiscreteDynamicsWorld *_dynamicsWorld;
    btAlignedObjectArray<btCollisionShape*> _collisionShapes;
    
    GModelShapeMap modelShapeMap;
}

@property (strong, nonatomic)NSMutableArray *nonPhysicsBodyGeometries;
@property (strong, nonatomic)NSMutableArray *dynamicPhysicsBodies;
@property (strong, nonatomic)NSMutableArray *kinematicPhysicsBodies;
@property (strong, nonatomic)NSMutableArray *staticPhysicsBodies;
@property (strong, nonatomic)NSMutableDictionary *sensors;
@property (strong, nonatomic)NSDictionary *nonRenderBodies;

@property (strong, nonatomic)UIAlertView *winOrLoseAlertView;

@property (strong, nonatomic)BQHudService *hudService;
@property (strong, nonatomic)BQInteractionService *interationService;

@property (nonatomic, strong)NSArray *cameraFovyAngles;

@property (nonatomic)vector<vec4> *pointLights;
@property (nonatomic)vector<vec4> *viewSpacePointLights;
@property (nonatomic)NSInteger currentCameraIndex;
@property (nonatomic)NSInteger currentNullLightIndex;

@property (nonatomic)vec4 pointLightSceneAmbientIntensity;
@property (nonatomic)vector<vec4> *pointLightDiffuseIntensities;
@property (nonatomic)vector<vec4> *pointLightSpecularIntensities;
@property (nonatomic)vector<vec4> *nullLights;
@property (nonatomic)GLint numberOfLights;
@property (nonatomic)GLint numberOfActiveLights;

@property (nonatomic)mat4 modelMatrix;
@property (nonatomic)mat4 viewMatrix;
@property (nonatomic)mat4 projectionMatrix;

@property (nonatomic)mat4 modelViewProjectionMatrix;
@property (nonatomic)mat4 modelViewMatrix;
@property (nonatomic)mat3 normalMatrix;

@property (nonatomic)dvec4 originalCenter;
@property (nonatomic)dvec4 center;

@property (nonatomic)vec4 originalThreshHoldTracking;
@property (nonatomic)vec4 lossThreshHoldTracking;

@property (nonatomic)GLfloat maxX;
@property (nonatomic)GLfloat maxY;
@property (nonatomic)GLfloat maxZ;
@property (nonatomic)GLfloat minX;
@property (nonatomic)GLfloat minY;
@property (nonatomic)GLfloat minZ;

@property (nonatomic, strong)NSMutableArray *textureIDs;
@property (nonatomic, strong)NSMutableDictionary *textureIDForNameDictionary;

@property (nonatomic)GLfloat gravity;
@property (nonatomic)GLint stepsPerSecond;
@property (nonatomic)GLint solverIterations;


- (id)initWithOBJandMTLFilePath:(NSString *)fileName
                     hudService:(BQHudService *)hudService
          andInteractiveService:(BQInteractionService *)interactiveService;

- (void)setupGL;
- (void)tearDownGL;
- (void)updateWithTimeInterval:(NSTimeInterval)timeInterval;
- (void)drawScene;

-(void)loadShaders;
-(void)loadTextures;

@end
