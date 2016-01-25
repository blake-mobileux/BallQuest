//
//  BQScene.m
//  SuperBallQuest
//
//  Created by Blake Harrison on 3/4/14.
//  Copyright (c) 2014 Blake Harrison. All rights reserved.
//

#import "BQScene.h"

@implementation BQScene
- (id)initWithOBJandMTLFilePath:(NSString *)fileName
                     hudService:(BQHudService *)hudService
          andInteractiveService:(BQInteractionService *)interactiveService
{
    self = [self init];
    
    if(self){
        _hudService = hudService;
        _interationService = interactiveService;
        
        _nonPhysicsBodyGeometries = [[NSMutableArray alloc] init];
        _dynamicPhysicsBodies = [[NSMutableArray alloc] init];
        _kinematicPhysicsBodies = [[NSMutableArray alloc] init];
        _staticPhysicsBodies = [[NSMutableArray alloc] init];
        _sensors = [[NSMutableDictionary alloc] init];
        
        string err = LoadObj(_shapes, (char *)[[[NSBundle mainBundle] pathForResource:fileName ofType:@"obj"] UTF8String],
                             (char *)[[[NSBundle mainBundle] pathForResource:fileName ofType:@"mtl"] UTF8String]);
        
        if (!err.empty()) {
            NSLog(@"Geometry could not successfully be loaded \n %s",err.c_str());
        }
        
        _numberOfLights = 8;
        _numberOfActiveLights = 8;
        
        _pointLightSceneAmbientIntensity = vec4(.16f, .16f, .16f, 1.0f);
        
        _pointLightsLocal.push_back(vec4(-0.22836f, 0.47183f, 0.34057f, 1.0f));
        _pointLightsLocal.push_back(vec4(-0.43182f, 0.54134f, 0.061f, 1.0f));
        _pointLightsLocal.push_back(vec4(-0.33782f, 0.63004f, -0.29455f,1.0f));
        _pointLightsLocal.push_back(vec4(-0.07318f, 0.70652f, -0.45723f, 1.0f));
        
        _pointLightsLocal.push_back(vec4(0.24994f,  0.64602f, -0.38737f, 1.0f));
        _pointLightsLocal.push_back(vec4(0.43677f,  0.71875f,  -0.05517f, 1.0f));
        _pointLightsLocal.push_back(vec4(0.31662f,  0.62291f, 0.27629f, 1.0f));
        _pointLightsLocal.push_back(vec4(0.0f, 0.9f, 0.0f, 1.0f));
        
        _pointLightDiffuseIntensitiesLocal.push_back(vec4(.31f, .31f, .31f, 1.0f));
        _pointLightSpecularIntensitiesLocal.push_back(vec4(.0031f, .0031f, .0031f,1.0f));
        
        _pointLightDiffuseIntensitiesLocal.push_back(vec4(.31f, .31f, .31f, 1.0f));
        _pointLightSpecularIntensitiesLocal.push_back(vec4(.0031f, .0031f, .0031f,1.0f));
        
        _pointLightDiffuseIntensitiesLocal.push_back(vec4(.31f, .31f, .31f, 1.0f));
        _pointLightSpecularIntensitiesLocal.push_back(vec4(.0031f, .0031f, .0031f,1.0f));
        
        _pointLightDiffuseIntensitiesLocal.push_back(vec4(.31f, .31f, .31f, 1.0f));
        _pointLightSpecularIntensitiesLocal.push_back(vec4(.0031f, .0031f, .0031f,1.0f));
        
        _pointLightDiffuseIntensitiesLocal.push_back(vec4(.31f, .31f, .31f, 1.0f));
        _pointLightSpecularIntensitiesLocal.push_back(vec4(.0031f, .0031f, .0031f,1.0f));
        
        _pointLightDiffuseIntensitiesLocal.push_back(vec4(.31f, .31f, .31f, 1.0f));
        _pointLightSpecularIntensitiesLocal.push_back(vec4(.0031f, .0031f, .0031f,1.0f));
        
        _pointLightDiffuseIntensitiesLocal.push_back(vec4(.31f, .31f, .31f, 1.0f));
        _pointLightSpecularIntensitiesLocal.push_back(vec4(.0031f, .0031f, .0031f,1.0f));
        
        _pointLightDiffuseIntensitiesLocal.push_back(vec4(.51f, .51f, .51f, 1.0f));
        _pointLightSpecularIntensitiesLocal.push_back(vec4(.0051f, .0051f, .0051f,1.0f));
        
        _nullLightsLocal.push_back(vec4(0.0f, 0.0f, 0.0f, 0.0f));
        _viewSpacePointLightsLocal.push_back(vec4(0.0f, 0.0f, 0.0f, 0.0f));
        _viewSpacePointLightsLocal.push_back(vec4(0.0f, 0.0f, 0.0f, 0.0f));
        _viewSpacePointLightsLocal.push_back(vec4(0.0f, 0.0f, 0.0f, 0.0f));
        _viewSpacePointLightsLocal.push_back(vec4(0.0f, 0.0f, 0.0f, 0.0f));
        _viewSpacePointLightsLocal.push_back(vec4(0.0f, 0.0f, 0.0f, 0.0f));
        _viewSpacePointLightsLocal.push_back(vec4(0.0f, 0.0f, 0.0f, 0.0f));
        _viewSpacePointLightsLocal.push_back(vec4(0.0f, 0.0f, 0.0f, 0.0f));
        _viewSpacePointLightsLocal.push_back(vec4(0.0f, 0.0f, 0.0f, 0.0f));
        _viewSpacePointLightsLocal.push_back(vec4(0.0f, 0.0f, 0.0f, 0.0f));
        
        self.currentNullLightIndex = 0;
        self.pointLights = &_pointLightsLocal;
        
        self.pointLightDiffuseIntensities = &_pointLightDiffuseIntensitiesLocal;
        self.pointLightSpecularIntensities = &_pointLightSpecularIntensitiesLocal;
        self.nullLights = &_nullLightsLocal;
        
        GLfloat maxCoordinate = 0.0f;
        GLfloat minCoordinate = 0.0f;
        
        // Normalize vertices and normals
        size_t i = 0;
        for (; i < _shapes.size(); i++) {
            size_t c = 0;
            for(; c < _shapes[i].mesh.positions.size(); c++){
                if(_shapes[i].mesh.positions[c] > maxCoordinate){
                    maxCoordinate = _shapes[i].mesh.positions[c];
                }
                if(_shapes[i].mesh.positions[c] < minCoordinate){
                    minCoordinate = _shapes[i].mesh.positions[c];
                }
            }
        }
        
        _collisionConfiguration = new btDefaultCollisionConfiguration();
        _dispatcher = new btCollisionDispatcher(_collisionConfiguration);
        _overlappingPairCache = new btDbvtBroadphase();
        _solver = new btSequentialImpulseConstraintSolver;
        _dynamicsWorld = new btDiscreteDynamicsWorld(_dispatcher, _overlappingPairCache, _solver, _collisionConfiguration);
        _dynamicsWorld->setGravity(btVector3(0,-9.81,0));
        
        _maxX = -INFINITY;
        _maxY = -INFINITY;
        _maxZ = -INFINITY;
        
        _minX = INFINITY;
        _minY = INFINITY;
        _minZ = INFINITY;

        NSDictionary *physicsBodiesProperties = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"physicsBodiesProperties" ofType:@"plist"]];
        NSDictionary *dynamicBodyProperties = [physicsBodiesProperties objectForKey:@"dynamicBodyProperties"];
        NSDictionary *kinematicBodyProperties = [physicsBodiesProperties objectForKey:@"kinematicBodyProperties"];
        NSDictionary *staticBodyProperties = [physicsBodiesProperties objectForKey:@"staticBodyProperties"];
        NSDictionary *sensors = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sensors" ofType:@"plist"]];
        
        NSDictionary *currentBodyProperties;
        NSInteger count = _shapes.size();
        NSInteger c = 0;
        for(; c < count; c++){
            tinyobj::shape_t * shape = &_shapes[c];
            
            PhysicsBodyShape typeOfShape;
            if((currentBodyProperties = [dynamicBodyProperties objectForKey:[[NSString alloc] initWithUTF8String:(const char *)shape->name.c_str()]])){
                if([[currentBodyProperties objectForKey:@"physicsObjectType"] isEqualToString:@"circle"]){
                    typeOfShape = circle;
                }
                else if([[currentBodyProperties objectForKey:@"physicsObjectType"] isEqualToString:@"box"]){
                    typeOfShape = box;
                }
                
                BQPhysicsBody *physicsBody = [[BQPhysicsBody alloc]initWithShape:shape physicsBodyType:dynamicBody physicsBodyShape:typeOfShape
                                                                        friction:(GLfloat)[[currentBodyProperties objectForKey:@"friction"] floatValue]
                                                                 rollingFriction:(GLfloat)[[currentBodyProperties objectForKey:@"rollingFriction"] floatValue]
                                                                     restitution:(GLfloat)[[currentBodyProperties objectForKey:@"restitution"] floatValue]
                                                                            mass:(GLfloat)[[currentBodyProperties objectForKey:@"mass"] floatValue]];
                [self.dynamicPhysicsBodies addObject:physicsBody];
                                physicsBody.physicsBody->setDamping(.015, .033);
                _dynamicsWorld->addRigidBody(physicsBody.physicsBody);
                _modelShapeMap[physicsBody] = physicsBody.physicsBody;
            }
            
            else if((currentBodyProperties = [kinematicBodyProperties objectForKey:[[NSString alloc] initWithUTF8String:(const char *)shape->name.c_str()]])){
                if([[currentBodyProperties objectForKey:@"physicsObjectType"] isEqualToString:@"mesh"]){
                    typeOfShape = mesh;
                }
                else if([[currentBodyProperties objectForKey:@"physicsObjectType"] isEqualToString:@"circle"]){
                    typeOfShape = circle;
                }
                else if([[currentBodyProperties objectForKey:@"physicsObjectType"] isEqualToString:@"box"]){
                    typeOfShape = box;
                }
                
                BQPhysicsBody *physicsBody = [[BQPhysicsBody alloc]initWithShape:shape physicsBodyType:kinematicBody physicsBodyShape:typeOfShape
                                                                        friction:(GLfloat)[[currentBodyProperties objectForKey:@"friction"] floatValue]
                                                                 rollingFriction:(GLfloat)[[currentBodyProperties objectForKey:@"rollingFriction"] floatValue]
                                                                     restitution:(GLfloat)[[currentBodyProperties objectForKey:@"restitution"] floatValue]
                                                                            mass:(GLfloat)[[currentBodyProperties objectForKey:@"mass"] floatValue]];
                [self.kinematicPhysicsBodies addObject:physicsBody];
                physicsBody.physicsBody->setCollisionFlags(physicsBody.physicsBody->getCollisionFlags() | btCollisionObject::CF_KINEMATIC_OBJECT);
                _dynamicsWorld->addRigidBody(physicsBody.physicsBody);
                _modelShapeMap[physicsBody] = physicsBody.physicsBody;
                
                [self updateSceneMinMaxCoordsWithMinMaxFromGeometry:physicsBody];
            }
            else if((currentBodyProperties = [staticBodyProperties objectForKey:[[NSString alloc] initWithUTF8String:(const char *)shape->name.c_str()]])){
                if([[currentBodyProperties objectForKey:@"physicsObjectType"] isEqualToString:@"mesh"]){
                    typeOfShape = mesh;
                }
                else if([[currentBodyProperties objectForKey:@"physicsObjectType"] isEqualToString:@"circle"]){
                    typeOfShape = circle;
                }
                else if([[currentBodyProperties objectForKey:@"physicsObjectType"] isEqualToString:@"box"]){
                    typeOfShape = box;
                }
                
                BQPhysicsBody *physicsBody = [[BQPhysicsBody alloc]initWithShape:shape
                                                                 physicsBodyType:staticBody
                                                                physicsBodyShape:typeOfShape
                                                                        friction:(GLfloat)[[currentBodyProperties objectForKey:@"friction"] floatValue]
                                                                 rollingFriction:(GLfloat)[[currentBodyProperties objectForKey:@"rollingFriction"] floatValue]
                                                                     restitution:(GLfloat)[[currentBodyProperties objectForKey:@"restitution"] floatValue]
                                                                            mass:(GLfloat)[[currentBodyProperties objectForKey:@"mass"] floatValue]];
                
                [self.staticPhysicsBodies addObject:physicsBody];
                _dynamicsWorld->addRigidBody(physicsBody.physicsBody);
                _modelShapeMap[physicsBody] = physicsBody.physicsBody;
                
                [self updateSceneMinMaxCoordsWithMinMaxFromGeometry:physicsBody];
            }
            else if((currentBodyProperties = [sensors objectForKey:[[NSString alloc] initWithUTF8String:(const char *)shape->name.c_str()]])){
                BQGeometry *geometry = [[BQGeometry alloc]initWithShape:shape];
                [_sensors setObject:geometry forKey:@"winSensor"];
            }
            else{
                BQGeometry *geometry = [[BQGeometry alloc]initWithShape:shape];
                [self.nonPhysicsBodyGeometries addObject:geometry];
                [self updateSceneMinMaxCoordsWithMinMaxFromGeometry:geometry];
            }
            
            currentBodyProperties = nil;
        }
        
        _originalCenter = vec4((_maxX + _minX) /2, (_maxY + _minY) /2, (_maxZ + _minZ) /2, 1.0f);
        _center = _originalCenter;
        
        if(maxCoordinate > 1 || minCoordinate < -1){
            GLfloat coordinateWithGreatestMagnitude = 0.0f;
            GLfloat maxCoordinateABS = abs(maxCoordinate);
            GLfloat minCoordinateABS = abs(minCoordinate);
            
            if(maxCoordinateABS > minCoordinateABS){
                coordinateWithGreatestMagnitude = maxCoordinateABS;
            }
            else{
                coordinateWithGreatestMagnitude = minCoordinateABS;
            }
            
            _canonicalViewScaleMatrix = scale(mat4(1.0f), vec3(1/coordinateWithGreatestMagnitude, 1/coordinateWithGreatestMagnitude, 1/coordinateWithGreatestMagnitude));
        }
        else{
            _canonicalViewScaleMatrix = mat4(1.0f);
        }
        
        for(BQPhysicsBody *physicsBody in self.dynamicPhysicsBodies){
            if([[[NSString alloc] initWithUTF8String:(const char *)physicsBody.shape.name.c_str()] isEqual:@"Ball_A"]){
                _user_character_ball_a = physicsBody;
            }
        }
        
        _cameraFovyAngles = @[@32.44, @145.292, @49.134, @34.312];
        
        _cameraPositions.push_back(vec4(-0.00515f, 0.9f, -0.02f,1.0f));
        _cameraLookatVectors.push_back(vec4(-0.0053,0.4947,-0.0221, 1.0f));
        _cameraUpVectors.push_back(vec3(0.0f, 0.000001f, 1.0f));
        
        BQGeometry *boardGeometry;
        for(BQGeometry *geometry in self.nonPhysicsBodyGeometries){
            if([[[NSString alloc] initWithUTF8String:(const char *)geometry.shape.name.c_str()] isEqual:@"Maze_Surfa"]){
                boardGeometry = geometry;
            }
        }
        
        _cameraPositions.push_back(vec4(boardGeometry.center.x, 0.5135f, boardGeometry.center.z,1.0f));
        _cameraLookatVectors.push_back(vec4(boardGeometry.center.x,boardGeometry.center.y,boardGeometry.center.z,1.0f));
        _cameraUpVectors.push_back(vec3(0.0f, 0.000001f, 1.0f));
        
        _cameraPositions.push_back(vec4(0.18186f, 0.69743f, -0.20682f, 1.0f));
        _cameraLookatVectors.push_back(vec4(-0.0057,0.4367,-0.0223, 1.0f));
        _cameraUpVectors.push_back(vec3(0.0f, 1.0f, 0.000001f));
        
        _cameraPositions.push_back(vec4(0.00019f, 0.56802f, 0.118f,1.0f));
        _cameraLookatVectors.push_back(vec4(_user_character_ball_a.center.x,_user_character_ball_a.center.y,_user_character_ball_a.center.z,1.0f));
        _cameraUpVectors.push_back(vec3(0.0f, 1.0f, 0.000001f));
        
        self.currentCameraIndex = 0;
        
        self.textureIDs = [[NSMutableArray alloc] init];
        self.textureIDForNameDictionary = [[NSMutableDictionary alloc] init];
        
        self.nonRenderBodies = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"nonRenderGeometryList" ofType:@"plist"]];
        self.originalThreshHoldTracking = vec4(self.center.x, self.minY, self.center.z, 1.0f);
    }
    
    return self;
}

-(void)updateSceneCenter{
    NSMutableArray *sceneGeometries = [[NSMutableArray alloc] initWithArray:self.nonPhysicsBodyGeometries];
    [sceneGeometries addObjectsFromArray:self.kinematicPhysicsBodies];
    [sceneGeometries addObjectsFromArray:self.staticPhysicsBodies];
    for(BQGeometry *geometry in sceneGeometries){
        [self updateSceneMinMaxCoordsWithMinMaxFromGeometry:geometry];
    }
    
    _center = vec4((_maxX + _minX) /2, (_maxY + _minY) /2, (_maxZ + _minZ) /2, 1.0f);
}

-(void)updateSceneMinMaxCoordsWithMinMaxFromGeometry:(BQGeometry *)geometry{
        if(geometry.maxX > _maxX)
        {
            _maxX = geometry.maxX;
        }
        
        if(geometry.minX < _minX)
        {
            _minX = geometry.minX;
        }
        
        if(geometry.maxY > _maxY)
        {
            _maxY = geometry.maxY;
        }
        
        if(geometry.minY < _minY)
        {
            _minY = geometry.minY;
        }
        
        if(geometry.maxZ > _maxZ)
        {
            _maxZ = geometry.maxZ;
        }
        
        if(geometry.minZ < _minZ)
        {
            _minZ = geometry.minZ;
        }
}

-(void)drawScene{
    NSMutableArray *scenePhysicsBodies = [[NSMutableArray alloc] initWithArray:self.nonPhysicsBodyGeometries];
    [scenePhysicsBodies addObjectsFromArray:self.kinematicPhysicsBodies];
    [scenePhysicsBodies addObjectsFromArray:self.staticPhysicsBodies];
    [scenePhysicsBodies addObjectsFromArray:self.dynamicPhysicsBodies];
    
    mat4 convertWorldLightPositionToViewingPosition = mat4(1.0f);
    vec4 lightPosition = vec4(1.0f);
    for(BQGeometry *geometry in scenePhysicsBodies){
        
        if([self.nonRenderBodies objectForKey:[[NSString alloc] initWithUTF8String:(const char *)geometry.shape.name.c_str()]]){
            continue;
        }
        
        glUniform4f(geometry.uniforms[LIGHT_SCENE_AMBIENT_INTENSITY_UNIFORM], self.pointLightSceneAmbientIntensity.x, self.pointLightSceneAmbientIntensity.y, self.pointLightSceneAmbientIntensity.z, self.pointLightSceneAmbientIntensity.w);
        
        lightPosition = convertWorldLightPositionToViewingPosition * (*self.pointLights)[0];
        glUniform4fv(geometry.uniforms[LIGHT0_POSITION_UNIFORM], 1, &lightPosition[0]);
        glUniform4fv(geometry.uniforms[LIGHT0_DIFFUSE_INTENSITY_UNIFORM], 1, &(*self.pointLightDiffuseIntensities)[0][0]);
        glUniform4fv(geometry.uniforms[LIGHT0_SPECULAR_INTENSITY_UNIFORM], 1, &(*self.pointLightSpecularIntensities)[0][0] );
        
        lightPosition = convertWorldLightPositionToViewingPosition * (*self.pointLights)[1];
        glUniform4fv(geometry.uniforms[LIGHT1_POSITION_UNIFORM], 1, &lightPosition[0]);
        glUniform4fv(geometry.uniforms[LIGHT1_DIFFUSE_INTENSITY_UNIFORM], 1, &(*self.pointLightDiffuseIntensities)[1][0]);
        glUniform4fv(geometry.uniforms[LIGHT1_SPECULAR_INTENSITY_UNIFORM], 1, &(*self.pointLightSpecularIntensities)[1][0]);
        
        lightPosition = convertWorldLightPositionToViewingPosition * (*self.pointLights)[2];
        glUniform4fv(geometry.uniforms[LIGHT2_POSITION_UNIFORM], 1, &lightPosition[0]);
        glUniform4fv(geometry.uniforms[LIGHT2_DIFFUSE_INTENSITY_UNIFORM], 1, &(*self.pointLightDiffuseIntensities)[2][0]);
        glUniform4fv(geometry.uniforms[LIGHT2_SPECULAR_INTENSITY_UNIFORM], 1, &(*self.pointLightSpecularIntensities)[2][0]);
        
        lightPosition = convertWorldLightPositionToViewingPosition * (*self.pointLights)[3];
        glUniform4fv(geometry.uniforms[LIGHT3_POSITION_UNIFORM], 1, &lightPosition[0]);
        glUniform4fv(geometry.uniforms[LIGHT3_DIFFUSE_INTENSITY_UNIFORM], 1, &(*self.pointLightDiffuseIntensities)[3][0]);
        glUniform4fv(geometry.uniforms[LIGHT3_SPECULAR_INTENSITY_UNIFORM], 1, &(*self.pointLightSpecularIntensities)[3][0]);
        
        lightPosition = convertWorldLightPositionToViewingPosition * (*self.pointLights)[4];
        glUniform4fv(geometry.uniforms[LIGHT4_POSITION_UNIFORM], 1, &lightPosition[0]);
        glUniform4fv(geometry.uniforms[LIGHT4_DIFFUSE_INTENSITY_UNIFORM], 1, &(*self.pointLightDiffuseIntensities)[4][0]);
        glUniform4fv(geometry.uniforms[LIGHT4_SPECULAR_INTENSITY_UNIFORM], 1, &(*self.pointLightSpecularIntensities)[4][0]);
        
        lightPosition = convertWorldLightPositionToViewingPosition * (*self.pointLights)[5];
        glUniform4fv(geometry.uniforms[LIGHT5_POSITION_UNIFORM], 1, &lightPosition[0]);
        glUniform4fv(geometry.uniforms[LIGHT5_DIFFUSE_INTENSITY_UNIFORM], 1, &(*self.pointLightDiffuseIntensities)[5][0]);
        glUniform4fv(geometry.uniforms[LIGHT5_SPECULAR_INTENSITY_UNIFORM], 1, &(*self.pointLightSpecularIntensities)[5][0]);
        
        lightPosition = convertWorldLightPositionToViewingPosition * (*self.pointLights)[6];
        glUniform4fv(geometry.uniforms[LIGHT6_POSITION_UNIFORM], 1, &lightPosition[0]);
        glUniform4fv(geometry.uniforms[LIGHT6_DIFFUSE_INTENSITY_UNIFORM], 1, &(*self.pointLightDiffuseIntensities)[6][0]);
        glUniform4fv(geometry.uniforms[LIGHT6_SPECULAR_INTENSITY_UNIFORM], 1, &(*self.pointLightSpecularIntensities)[6][0]);
        
        lightPosition = convertWorldLightPositionToViewingPosition * (*self.pointLights)[7];
        glUniform4fv(geometry.uniforms[LIGHT7_POSITION_UNIFORM], 1, &lightPosition[0]);
        glUniform4fv(geometry.uniforms[LIGHT7_DIFFUSE_INTENSITY_UNIFORM], 1, &(*self.pointLightDiffuseIntensities)[7][0]);
        glUniform4fv(geometry.uniforms[LIGHT7_SPECULAR_INTENSITY_UNIFORM], 1, &(*self.pointLightSpecularIntensities)[7][0]);
        
        [geometry drawGeometry];
    }
}

-(void)loadShaders{
    NSMutableArray *sceneGeometries = [[NSMutableArray alloc] initWithArray:self.nonPhysicsBodyGeometries];
    [sceneGeometries addObjectsFromArray:self.dynamicPhysicsBodies];
    [sceneGeometries addObjectsFromArray:self.kinematicPhysicsBodies];
    [sceneGeometries addObjectsFromArray:self.staticPhysicsBodies];
    for(BQGeometry *geometry in sceneGeometries){
        [geometry loadShaders];
    }
}

-(void)loadTextures{
    NSMutableArray *sceneGeometries = [[NSMutableArray alloc] initWithArray:self.nonPhysicsBodyGeometries];
    [sceneGeometries addObjectsFromArray:self.dynamicPhysicsBodies];
    [sceneGeometries addObjectsFromArray:self.kinematicPhysicsBodies];
    [sceneGeometries addObjectsFromArray:self.staticPhysicsBodies];
    for(BQGeometry *geometry in sceneGeometries){
        if(geometry.isTextured){
            if(![self.textureIDForNameDictionary valueForKey:[NSString stringWithUTF8String: &geometry.shape.material.diffuse_texname[0]]]) {
                glActiveTexture(GL_TEXTURE0);
                
                NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithUTF8String: &geometry.shape.material.diffuse_texname[0]] ofType:@""];
                NSData *texData = [[NSData alloc] initWithContentsOfFile:path];
                UIImage *texture = [[UIImage alloc] initWithData:texData];
                
                glGenTextures(1, &_glesTexturesLocal[TEXTURE_ONE_INDEX]);
                glBindTexture(GL_TEXTURE_2D, _glesTexturesLocal[TEXTURE_ONE_INDEX]);
                
                if (!texture){
                    NSLog(@"Image was not loaded properly");
                }
    
                
                if(geometry.isTextured){
                glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
                
                GLuint width = CGImageGetWidth(texture.CGImage);
                GLuint height = CGImageGetHeight(texture.CGImage);
                CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
                void *imageData = malloc( height * width * 4 );
                CGContextRef context = CGBitmapContextCreate( imageData, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big );
                
                CGContextTranslateCTM (context, 0, height);
                CGContextScaleCTM (context, 1.0, -1.0);
                
                CGColorSpaceRelease( colorSpace );
                CGContextDrawImage( context, CGRectMake( 0, 0, width, height ), texture.CGImage );
                
                glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
                
                glTexParameterf(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR_MIPMAP_LINEAR);
                glTexParameterf(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
                glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY_EXT, 1.0f);
                glTexParameterf(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_MIRRORED_REPEAT);
                glTexParameterf(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_MIRRORED_REPEAT);
                
                glGenerateMipmap(GL_TEXTURE_2D);
                
                CGContextRelease(context);
                free(imageData);
                
                glBindTexture(GL_TEXTURE_2D, 0);
                
                [self.textureIDs addObject:[[NSNumber alloc] initWithInteger:_glesTexturesLocal[TEXTURE_ONE_INDEX]]];
                [self.textureIDForNameDictionary setObject:[[NSNumber alloc] initWithInteger:_glesTexturesLocal[TEXTURE_ONE_INDEX]] forKey:[NSString stringWithUTF8String: &geometry.shape.material.diffuse_texname[0]]];
                }
            }
            else{
                _glesTexturesLocal[TEXTURE_ONE_INDEX] = (GLuint)[(NSNumber *)[self.textureIDForNameDictionary valueForKey:[NSString stringWithUTF8String: &geometry.shape.material.diffuse_texname[0]]] integerValue];
            }
            geometry.textureAtlasID = (GLuint)_glesTexturesLocal[TEXTURE_ONE_INDEX];
        }
    }
}

-(void)updateWithTimeInterval:(NSTimeInterval)timeInterval{
    [self.interationService updateUserInteractionData];
    
    if(self.interationService.deviceMotion.gravity.z < 0.0f){
    for(BQPhysicsBody *physicsBody in self.kinematicPhysicsBodies){
    if(self.currentCameraIndex == 3){
       [physicsBody setAccumulatedRotations:-dvec3(self.interationService.attitude.roll * DEFAULT_ROTATION_SCALE, self.interationService.attitude.pitch * DEFAULT_ROTATION_SCALE, self.interationService.attitude.yaw * DEFAULT_ROTATION_SCALE)];
    }
    else{
        [physicsBody setAccumulatedRotations:dvec3(self.interationService.attitude.roll * DEFAULT_ROTATION_SCALE, self.interationService.attitude.pitch * DEFAULT_ROTATION_SCALE, self.interationService.attitude.yaw * DEFAULT_ROTATION_SCALE)];
    }
        [self updateWorldRotationForBody:physicsBody
                           withRotations:dvec3(-physicsBody.accumulatedRotations.x, 0.0f, -physicsBody.accumulatedRotations.y)];
  }
    
    [self updatePhysicsWithElapsedTimeInterval:timeInterval];
    
    NSMutableArray *nonPhysicsGeometriesAndSensors = [[NSMutableArray alloc] initWithArray:self.nonPhysicsBodyGeometries];
    [nonPhysicsGeometriesAndSensors addObject:[self.sensors objectForKey:@"winSensor"]];
    for(BQGeometry *geometry in nonPhysicsGeometriesAndSensors){
        if(self.currentCameraIndex == 3){
            [geometry setAccumulatedRotations:-dvec3(self.interationService.attitude.roll * DEFAULT_ROTATION_SCALE, self.interationService.attitude.pitch * DEFAULT_ROTATION_SCALE, self.interationService.attitude.yaw * DEFAULT_ROTATION_SCALE)];
        }
        else{
            [geometry setAccumulatedRotations:dvec3(self.interationService.attitude.roll * DEFAULT_ROTATION_SCALE, self.interationService.attitude.pitch * DEFAULT_ROTATION_SCALE, self.interationService.attitude.yaw * DEFAULT_ROTATION_SCALE)];
        }
        
        vec3 EulerAngles(-geometry.accumulatedRotations.x, 0.0f, -geometry.accumulatedRotations.y);
        quat quaternion = quat(EulerAngles);
        
        mat4 rotationMatrix = toMat4(quaternion);
        mat4 inverseTranslateToOriginMatrix = translate(mat4(1.0f), vec3(self.center.x, self.center.y, self.center.z));
        mat4 translateToOriginMatrix = translate(mat4(1.0f), vec3(-self.center.x, -self.center.y, -self.center.z));
        mat4 transformMatrix = geometry.accumulatedTransformations;
        mat4 compoundRotationMatrix = inverseTranslateToOriginMatrix * rotationMatrix * translateToOriginMatrix;
        transformMatrix =  transformMatrix * compoundRotationMatrix;
        
        if(self.currentCameraIndex == 3){
            [self setViewMatrix: _canonicalViewScaleMatrix * lookAt(vec3([self getWorldTranslation:_user_character_ball_a] * _cameraPositions[_currentCameraIndex]),vec3([self getWorldTranslation:_user_character_ball_a] * _cameraLookatVectors[self.currentCameraIndex]),_cameraUpVectors[_currentCameraIndex])];
            [geometry setViewMatrix:self.viewMatrix];
        }
        else{
            [self setViewMatrix: _canonicalViewScaleMatrix * lookAt(vec3(_cameraPositions[_currentCameraIndex]),vec3(_cameraLookatVectors[self.currentCameraIndex]),_cameraUpVectors[_currentCameraIndex])];
        [geometry setViewMatrix:self.viewMatrix];
        }
        
        NSNumber *fovy = [self.cameraFovyAngles objectAtIndex:self.currentCameraIndex];
        [self setProjectionMatrix: perspective([fovy floatValue], 4.0f / 3.0f, 0.001f, 2.0f)];
        [geometry setProjectionMatrix:self.projectionMatrix];
        
        NSString *geometryName = [[NSString alloc] initWithUTF8String:(const char *)geometry.shape.name.c_str()];
        if([geometryName isEqual:@"handle.000"]){
            mat4 inverseTranslateToOriginMatrix = translate(mat4(1.0f), vec3(geometry.originalCenter.x, geometry.originalCenter.y, geometry.originalCenter.z));
            mat4 translateToOriginMatrix = translate(mat4(1.0f), vec3(-geometry.originalCenter.x, -geometry.originalCenter.y, -geometry.originalCenter.z));
            vec3 localEulerAngles(geometry.accumulatedRotations.x * 5.0f, 0.0f, 0.0f);
            quat localQuaternion = quat(localEulerAngles);
            mat4 localRotationMatrix = toMat4(localQuaternion);
            mat4 compoundGeometryCenterBasedRotationMatrix = inverseTranslateToOriginMatrix * localRotationMatrix * translateToOriginMatrix;
            
            [geometry setModelMatrix:transformMatrix * compoundGeometryCenterBasedRotationMatrix];
        }
        else if([geometryName isEqual:@"handle.001"]){
            mat4 inverseTranslateToOriginMatrix = translate(mat4(1.0f), vec3(geometry.originalCenter.x, geometry.originalCenter.y, geometry.originalCenter.z));
            mat4 translateToOriginMatrix = translate(mat4(1.0f), vec3(-geometry.originalCenter.x, -geometry.originalCenter.y, -geometry.originalCenter.z));
            vec3 localEulerAngles(0.0f, 0.0f, geometry.accumulatedRotations.y * 5.0f);
            quat localQuaternion = quat(localEulerAngles);
            mat4 localRotationMatrix = toMat4(localQuaternion);
            mat4 compoundGeometryCenterBasedRotationMatrix = inverseTranslateToOriginMatrix * localRotationMatrix * translateToOriginMatrix;
            
            [geometry setModelMatrix:transformMatrix * compoundGeometryCenterBasedRotationMatrix];
        }
        else{
            [geometry setModelMatrix: transformMatrix];
        }
        
        geometry.center = geometry.modelMatrix * geometry.originalCenter;
        self.lossThreshHoldTracking = geometry.modelMatrix * self.originalThreshHoldTracking;
        
        [geometry setModelViewProjectionMatrix: self.projectionMatrix * self.viewMatrix * geometry.modelMatrix];
        [geometry setModelViewMatrix: self.viewMatrix * geometry.modelMatrix];
        [geometry setNormalMatrix: transpose(inverse(mat3(self.viewMatrix * geometry.modelMatrix)))];
    }
}
    
    NSMutableArray *physicsBodyGeometries = [[NSMutableArray alloc] initWithArray:self.dynamicPhysicsBodies];
    [physicsBodyGeometries addObjectsFromArray:self.kinematicPhysicsBodies];
    [physicsBodyGeometries addObjectsFromArray:self.staticPhysicsBodies];
    for(BQPhysicsBody *physicsBody in physicsBodyGeometries){
        mat4 worldTransform = [self getWorldTransform:physicsBody];
        [physicsBody setModelMatrix: mat4(1.0f) * worldTransform];
        
        [physicsBody setViewMatrix:self.viewMatrix];
        
        NSNumber *fovy = [self.cameraFovyAngles objectAtIndex:self.currentCameraIndex];
        [physicsBody setProjectionMatrix: perspective([fovy floatValue], 4.0f / 3.0f, 0.001f, 2.0f)];
        
        physicsBody.center = physicsBody.modelMatrix * physicsBody.originalCenter;
        self.lossThreshHoldTracking = physicsBody.modelMatrix * self.originalThreshHoldTracking;
        
        [physicsBody setModelViewProjectionMatrix: _canonicalViewScaleMatrix * physicsBody.projectionMatrix * physicsBody.viewMatrix * physicsBody.modelMatrix];
        [physicsBody setModelViewMatrix: _canonicalViewScaleMatrix * physicsBody.viewMatrix * physicsBody.modelMatrix];
        [physicsBody setNormalMatrix: transpose(inverse(mat3(_canonicalViewScaleMatrix * physicsBody.viewMatrix * physicsBody.modelMatrix)))];
    }
    
    if(!self.winOrLoseAlertView){
    if([self didLose]){
        self.winOrLoseAlertView = [[UIAlertView alloc] initWithTitle:@"You Lose!"
                                                             message:@"Would you like to try again?"
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
            self.winOrLoseAlertView.tag = 31;
            [self.winOrLoseAlertView setDelegate:self];
            [self.winOrLoseAlertView show];
    }
    else if([self didWin]){
        self.winOrLoseAlertView = [[UIAlertView alloc] initWithTitle:@"You Won!"
                                                             message:@"Congradulations! Would you like to play again?"
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
        self.winOrLoseAlertView.tag = 31;
        [self.winOrLoseAlertView setDelegate:self];
        [self.winOrLoseAlertView show];
    }
  }
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if(alertView.tag == 31){
        
        BQPhysicsBody *ballPhysicsBody;
        for(BQPhysicsBody *physicsBody in self.dynamicPhysicsBodies){
            if([[[NSString alloc] initWithUTF8String:(const char *)physicsBody.shape.name.c_str()] isEqual:@"Ball_A"]){
                ballPhysicsBody = physicsBody;
            }
        }
        
        [self.dynamicPhysicsBodies removeObject:ballPhysicsBody];
        _dynamicsWorld->removeCollisionObject(ballPhysicsBody.physicsBody);
        
        delete ballPhysicsBody.physicsBody->getMotionState();
        delete ballPhysicsBody.physicsBody->getCollisionShape();
        delete ballPhysicsBody.physicsBody;
        
        [ballPhysicsBody createDynamicPhysicsBody];
        
        ballPhysicsBody.physicsBody->setDamping(.015, .033);
        _dynamicsWorld->addRigidBody(ballPhysicsBody.physicsBody);
        
        _modelShapeMap[ballPhysicsBody] = ballPhysicsBody.physicsBody;
        [self.dynamicPhysicsBodies addObject:ballPhysicsBody];
        
        self.winOrLoseAlertView = nil;
    }
}

-(void)resetPhysicsBodyInWorld:(BQPhysicsBody *)physicsBody{
    [self.dynamicPhysicsBodies removeObject:physicsBody];
    _dynamicsWorld->removeCollisionObject(physicsBody.physicsBody);
    
    delete physicsBody.physicsBody->getMotionState();
    delete physicsBody.physicsBody->getCollisionShape();
    delete physicsBody.physicsBody;
    
    [physicsBody createDynamicPhysicsBody];
    
    physicsBody.physicsBody->setDamping(.015, .033);
    _dynamicsWorld->addRigidBody(physicsBody.physicsBody);
    
    _modelShapeMap[physicsBody] = physicsBody.physicsBody;
    [self.dynamicPhysicsBodies addObject:physicsBody];
}

- (void)updateWorldRotationForBody:(BQPhysicsBody *)physicsBody
                     withRotations:(dvec3)rotations{
    // Conversion from Euler angles (in radians) to Quaternion
    vec3 EulerAngles(rotations.x, rotations.y, rotations.z);
    quat quaternion = quat(EulerAngles);
    
    mat4 rotationMatrix = toMat4(quaternion);

    mat4 inverseTranslateToSceneOriginMatrix = translate(mat4(1.0f), vec3(self.center.x * GEOMETRY_TO_PHYSICS_WORLD_CONVERSION_FACTOR, self.center.y * GEOMETRY_TO_PHYSICS_WORLD_CONVERSION_FACTOR, self.center.z * GEOMETRY_TO_PHYSICS_WORLD_CONVERSION_FACTOR));
    mat4 translateToSceneOriginMatrix = translate(mat4(1.0f), vec3(-self.center.x * GEOMETRY_TO_PHYSICS_WORLD_CONVERSION_FACTOR, -self.center.y * GEOMETRY_TO_PHYSICS_WORLD_CONVERSION_FACTOR, -self.center.z * GEOMETRY_TO_PHYSICS_WORLD_CONVERSION_FACTOR));
    mat4 compoundRotationMatrix = inverseTranslateToSceneOriginMatrix * rotationMatrix * translateToSceneOriginMatrix;
    mat4 transformationMatrix = compoundRotationMatrix * translate(mat4(1.0f), vec3(physicsBody.origin.x, physicsBody.origin.y, physicsBody.origin.z));
     
    btCollisionObject *obj = _modelShapeMap[physicsBody];
    btRigidBody *body = btRigidBody::upcast(obj);
    
    btTransform newTransform;
    newTransform.setFromOpenGLMatrix(&transformationMatrix[0][0]);
    body->getMotionState()->setWorldTransform(newTransform);
}

- (mat4)getWorldTransform:(BQPhysicsBody *)physicsBody
{
    mat4 worldTransform = mat4(1.0f);
    btCollisionObject *obj = _modelShapeMap[physicsBody];
    btRigidBody *body = btRigidBody::upcast(obj);
    
    if(body != NULL)
    {
        btTransform transform;
        body->getMotionState()->getWorldTransform(transform);
        
        btQuaternion quaternion = transform.getRotation();
        btVector3 newOrigin = transform.getOrigin();
        newOrigin = newOrigin * (GLfloat)1.0f/ GEOMETRY_TO_PHYSICS_WORLD_CONVERSION_FACTOR;
        
        btTransform newTransform;
        newTransform.setIdentity();
        newTransform.setOrigin(btVector3(newOrigin.x(), newOrigin.y(), newOrigin.z()));
        newTransform.setRotation(quaternion);
        
        btScalar glESMatrix[16];
        newTransform.getOpenGLMatrix(glESMatrix);
        
        worldTransform = make_mat4(glESMatrix) * translate(mat4(1.0f), vec3(-physicsBody.originalCenter.x, -physicsBody.originalCenter.y, -physicsBody.originalCenter.z));
    }
    
    return worldTransform;
}

- (mat4)getWorldTranslation:(BQPhysicsBody *)physicsBody{
    mat4 worldTranslation = mat4(1.0f);
    btCollisionObject *obj = _modelShapeMap[physicsBody];
    btRigidBody *body = btRigidBody::upcast(obj);
    
    if(body != NULL)
    {
        btTransform transform;
        body->getMotionState()->getWorldTransform(transform);
        
        btQuaternion quaternion(0.0f, 0.0f, 0.0f);
        btVector3 newOrigin = transform.getOrigin();
        newOrigin = newOrigin * (GLfloat)1.0f/ GEOMETRY_TO_PHYSICS_WORLD_CONVERSION_FACTOR;
        
        btTransform newTransform;
        newTransform.setIdentity();
        newTransform.setOrigin(btVector3(newOrigin.x(), newOrigin.y(), newOrigin.z()));
        newTransform.setRotation(quaternion);
        
        btScalar glESMatrix[16];
        newTransform.getOpenGLMatrix(glESMatrix);
        
        worldTranslation = make_mat4(glESMatrix) * translate(mat4(1.0f), vec3(-physicsBody.originalCenter.x, -physicsBody.originalCenter.y, -physicsBody.originalCenter.z));
    }
    
    return worldTranslation;
}

- (mat4)getWorldRotation:(BQPhysicsBody *)physicsBody
{
    mat4 worldRotation = mat4(1.0f);
    btCollisionObject *obj = _modelShapeMap[physicsBody];
    btRigidBody *body = btRigidBody::upcast(obj);
    
    if(body != NULL)
    {
        btTransform transform;
        body->getMotionState()->getWorldTransform(transform);
        
        btQuaternion quaternion = transform.getRotation();
        btTransform rotationTransform;
        rotationTransform.getIdentity();
        
        rotationTransform.setRotation(quaternion);
        
        btScalar glESMatrix[16];
        rotationTransform.getOpenGLMatrix(glESMatrix);
        
        worldRotation = make_mat4(glESMatrix);
    }
    
    return worldRotation;
}

- (BOOL)didLose{
    BOOL didLose = NO;
    for(BQPhysicsBody *physicsBody in self.dynamicPhysicsBodies){
        if([[[NSString alloc] initWithUTF8String:(const char *)physicsBody.shape.name.c_str()] isEqual:@"Ball_A"]){
            if(physicsBody.center.y < self.lossThreshHoldTracking.y){
                didLose = YES;
            }
        }
    }
    return didLose;
}

- (BOOL)didWin{
    BOOL didWin = NO;
    for(BQPhysicsBody *physicsBody in self.dynamicPhysicsBodies){
        if([[[NSString alloc] initWithUTF8String:(const char *)physicsBody.shape.name.c_str()] isEqual:@"Ball_A"]){
            BQGeometry *winSensor = [self.sensors objectForKey:@"winSensor"];
            if((physicsBody.center.x >= winSensor.minX && physicsBody.center.x <= winSensor.maxX) &&
               (physicsBody.center.y >= winSensor.minY && physicsBody.center.y <= winSensor.maxY) &&
               (physicsBody.center.z >= winSensor.minZ && physicsBody.center.z <= winSensor.maxZ)){
                didWin = YES;
            }
        }
    }
    return didWin;
}

- (void)updatePhysicsWithElapsedTimeInterval:(NSTimeInterval)seconds{
   _dynamicsWorld->stepSimulation(seconds, 4, 1/60.0f);
}

- (void)setupGL
{
    NSMutableArray *sceneGeometries = [[NSMutableArray alloc] initWithArray:self.nonPhysicsBodyGeometries];
    [sceneGeometries addObjectsFromArray:self.dynamicPhysicsBodies];
    [sceneGeometries addObjectsFromArray:self.kinematicPhysicsBodies];
    [sceneGeometries addObjectsFromArray:self.staticPhysicsBodies];
    for(BQGeometry *geometry in sceneGeometries){
        [geometry setupGL];
    }
}

- (void)tearDownGL
{
    NSMutableArray *sceneGeometries = [[NSMutableArray alloc] initWithArray:self.nonPhysicsBodyGeometries];
    [sceneGeometries addObjectsFromArray:self.dynamicPhysicsBodies];
    [sceneGeometries addObjectsFromArray:self.kinematicPhysicsBodies];
    [sceneGeometries addObjectsFromArray:self.staticPhysicsBodies];
    for(BQGeometry *geometry in sceneGeometries){
        [geometry tearDownGL];
    }
}

-(void)tearDownPhysics{
    delete _collisionConfiguration;
    delete _dispatcher;
    delete _overlappingPairCache;
    delete _solver;
    delete _dynamicsWorld;
}

@end
