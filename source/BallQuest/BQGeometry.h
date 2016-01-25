//
//  BQGeometry.h
//  SuperBallQuest
//
//  Created by Blake Harrison on 3/4/14.
//  Copyright (c) 2014 Blake Harrison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import <OpenGLES/ES2/glext.h>
#import <limits.h>
#import "glm.hpp"
#import "ext.hpp"
#import "tiny_obj_loader.h"
#import "BQGameConstants.h"

using namespace glm;
using namespace std;
using namespace tinyobj;

@interface BQGeometry : NSObject
{
    GLint _uniformsLocal[NUMBER_OF_UNIFORMS];
    GLuint _vertexArrayObjectsLocal[NUMBER_OF_VERTEX_ARRAY_OBJECTS];
    GLuint _vertexBufferObjectsLocal[NUMBER_OF_ATTRIBUTES];
    vector<vec4> _viewSpacePointLightsLocal;
    tinyobj::shape_t _shape;
}

@property (nonatomic)GLint *uniforms;
@property (nonatomic)GLuint *vertexArrayObjects;
@property (nonatomic)GLuint *vertexBufferObjects;
@property (nonatomic)GLuint *textures;
@property (nonatomic)GLuint program;

@property (nonatomic)mat4 modelMatrix;
@property (nonatomic)mat4 viewMatrix;
@property (nonatomic)mat4 projectionMatrix;

@property (nonatomic)mat4 modelViewProjectionMatrix;
@property (nonatomic)mat4 modelViewMatrix;
@property (nonatomic)mat3 normalMatrix;

@property (nonatomic)vec3 accumulatedTranslations;

@property (nonatomic)dvec3 accumulatedRotations;
@property (nonatomic)vec3 clampedAccumulatedRotations;

@property (nonatomic)vec3 accumulatedScaling;
@property (nonatomic)mat4 accumulatedTransformations;

@property (nonatomic)GLfloat maxX;
@property (nonatomic)GLfloat maxY;
@property (nonatomic)GLfloat maxZ;
@property (nonatomic)GLfloat minX;
@property (nonatomic)GLfloat minY;
@property (nonatomic)GLfloat minZ;

@property (nonatomic)vec3 materialAmbient;
@property (nonatomic)vec3 widthHeightDepth;
@property (nonatomic)vec4 originalCenter;
@property (nonatomic)vec4 center;

@property (nonatomic)BOOL isTextured;
@property (nonatomic, strong)NSMutableArray *textureIDs;

@property (nonatomic)GLint textureUnit;
@property (nonatomic)GLuint textureAtlasID;

- (id)initWithShape:(tinyobj::shape_t *)shape;

- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;
- (tinyobj::shape_t)shape;

-(NSString *)filePathForTextureWithName:(NSString *)texName;

-(void)drawGeometry;
- (void)setupGL;
- (void)tearDownGL;

@end
