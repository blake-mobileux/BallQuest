//
//  BQGeometry.m
//  SuperBallQuest
//
//  Created by Blake Harrison on 3/4/14.
//  Copyright (c) 2014 Blake Harrison. All rights reserved.
//

#import "BQGeometry.h"

@implementation BQGeometry

#pragma mark -  OpenGL ES 2 shader compilation

- (id)initWithShape:(tinyobj::shape_t *)shape{
    
    self = [super init];
    
    if(self){
        self.uniforms = &(_uniformsLocal[0]);
        self.vertexArrayObjects = &(_vertexArrayObjectsLocal[0]);
        self.vertexBufferObjects = &(_vertexBufferObjectsLocal[0]);
        _shape = *shape;
        
        self.originalCenter = vec4(0.0f, 0.0f, 0.0f, 0.0f);
        
        _maxX = -INFINITY;
        _maxY = -INFINITY;
        _maxZ = -INFINITY;
        
        _minX = INFINITY;
        _minY = INFINITY;
        _minZ = INFINITY;
        
        NSInteger count = _shape.mesh.positions.size();
        NSInteger c = 0;
        for(; c < count; c+=3){
            if(_shape.mesh.positions[c] > _maxX)
            {
                _maxX = _shape.mesh.positions[c];
            }
            
            if(_shape.mesh.positions[c] < _minX)
            {
                _minX = _shape.mesh.positions[c];
            }
            
            if(_shape.mesh.positions[c+1] > _maxY)
            {
                _maxY = _shape.mesh.positions[c+1];
            }
            
            if(_shape.mesh.positions[c+1] < _minY)
            {
                _minY = _shape.mesh.positions[c+1];
            }
            
            if(_shape.mesh.positions[c+2] > _maxZ)
            {
                _maxZ = _shape.mesh.positions[c+2];
            }
            
            if(_shape.mesh.positions[c+2] < _minZ)
            {
                _minZ = _shape.mesh.positions[c+2];
            }
        }
        
        self.widthHeightDepth = vec3(abs(_maxX - _minX), abs(_maxY - _minY), abs(_maxZ - _minZ));
        
        self.originalCenter = vec4((_maxX + _minX) /2, (_maxY + _minY) /2, (_maxZ + _minZ) /2, 1.0f);
        self.center = self.originalCenter;

        self.materialAmbient = vec3(1.0f, 1.0f, 1.0f);
        
        if(_shape.mesh.texcoords.size() > 0){
            _isTextured = YES;
        }
        else{
            _isTextured = NO;
        }
        
        _accumulatedRotations = vec3(0.0f);
        _clampedAccumulatedRotations = vec3(0.0f);
    }
    
    return self;
}

-(tinyobj::shape_t)shape{
    return _shape;
}

- (BOOL)loadShaders
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    self.program = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"VertexShader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"FragmentShader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(self.program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(self.program, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(self.program, VERTEX_POS_ATTRIB, "a_position");
    glBindAttribLocation(self.program, VERTEX_NORMAL_ATTRIB, "a_normal");
    glBindAttribLocation(self.program, VERTEX_TEXTURE_COORDS_ATTRIB, "a_texCoord");
    
    // Link program.
    if (![self linkProgram:self.program]) {
        NSLog(@"Failed to link program: %d", self.program);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (self.program) {
            glDeleteProgram(self.program);
            self.program = 0;
        }
        
        return NO;
    }
    
    // Get uniform locations.
    _uniforms[MODELVIEWPROJECTION_MATRIX_UNIFORM] = glGetUniformLocation(self.program, "modelViewProjectionMatrix");
    _uniforms[NORMAL_MATRIX_UNIFORM] = glGetUniformLocation(self.program, "normalMatrix");
    _uniforms[MODELVIEW_MATRIX_UNIFORM] = glGetUniformLocation(self.program, "modelViewMatrix");
    _uniforms[VIEW_MATRIX_UNIFORM] = glGetUniformLocation(self.program, "viewMatrix");
    
    _uniforms[MATERIAL_AMBIENT_UNIFORM] = glGetUniformLocation(self.program, "materialAmbient");
    _uniforms[MATERIAL_DIFFUSE_UNIFORM] = glGetUniformLocation(self.program, "materialDiffuse");
    _uniforms[MATERIAL_SPECULAR_UNIFORM] = glGetUniformLocation(self.program, "materialSpecular");
    _uniforms[MATERIAL_SPECULAR_EXP_UNIFORM] = glGetUniformLocation(self.program, "materialSpecularExponent");
    
    _uniforms[LIGHT_SCENE_AMBIENT_INTENSITY_UNIFORM] = glGetUniformLocation(self.program, "sceneAmbientIntensity");
    
    _uniforms[LIGHT0_POSITION_UNIFORM] = glGetUniformLocation(self.program, "light0Position");
    _uniforms[LIGHT0_DIFFUSE_INTENSITY_UNIFORM] = glGetUniformLocation(self.program, "light0DiffuseIntensity");
    _uniforms[LIGHT0_SPECULAR_INTENSITY_UNIFORM] = glGetUniformLocation(self.program, "light0SpecularIntensity");
    
    _uniforms[LIGHT1_POSITION_UNIFORM] = glGetUniformLocation(self.program, "light1Position");
    _uniforms[LIGHT1_DIFFUSE_INTENSITY_UNIFORM] = glGetUniformLocation(self.program, "light1DiffuseIntensity");
    _uniforms[LIGHT1_SPECULAR_INTENSITY_UNIFORM] = glGetUniformLocation(self.program, "light1SpecularIntensity");
    
    _uniforms[LIGHT2_POSITION_UNIFORM] = glGetUniformLocation(self.program, "light2Position");
    _uniforms[LIGHT2_DIFFUSE_INTENSITY_UNIFORM] = glGetUniformLocation(self.program, "light2DiffuseIntensity");
    _uniforms[LIGHT2_SPECULAR_INTENSITY_UNIFORM] = glGetUniformLocation(self.program, "light2SpecularIntensity");
    
    _uniforms[LIGHT3_POSITION_UNIFORM] = glGetUniformLocation(self.program, "light3Position");
    _uniforms[LIGHT3_DIFFUSE_INTENSITY_UNIFORM] = glGetUniformLocation(self.program, "light3DiffuseIntensity");
    _uniforms[LIGHT3_SPECULAR_INTENSITY_UNIFORM] = glGetUniformLocation(self.program, "light3SpecularIntensity");
    
    _uniforms[LIGHT4_POSITION_UNIFORM] = glGetUniformLocation(self.program, "light4Position");
    _uniforms[LIGHT4_DIFFUSE_INTENSITY_UNIFORM] = glGetUniformLocation(self.program, "light4DiffuseIntensity");
    _uniforms[LIGHT4_SPECULAR_INTENSITY_UNIFORM] = glGetUniformLocation(self.program, "light4SpecularIntensity");
    
    _uniforms[LIGHT5_POSITION_UNIFORM] = glGetUniformLocation(self.program, "light5Position");
    _uniforms[LIGHT5_DIFFUSE_INTENSITY_UNIFORM] = glGetUniformLocation(self.program, "light5DiffuseIntensity");
    _uniforms[LIGHT5_SPECULAR_INTENSITY_UNIFORM] = glGetUniformLocation(self.program, "light5SpecularIntensity");
    
    _uniforms[LIGHT6_POSITION_UNIFORM] = glGetUniformLocation(self.program, "light6Position");
    _uniforms[LIGHT6_DIFFUSE_INTENSITY_UNIFORM] = glGetUniformLocation(self.program, "light6DiffuseIntensity");
    _uniforms[LIGHT6_SPECULAR_INTENSITY_UNIFORM] = glGetUniformLocation(self.program, "light6SpecularIntensity");
    
    _uniforms[LIGHT7_POSITION_UNIFORM] = glGetUniformLocation(self.program, "light7Position");
    _uniforms[LIGHT7_DIFFUSE_INTENSITY_UNIFORM] = glGetUniformLocation(self.program, "light7DiffuseIntensity");
    _uniforms[LIGHT7_SPECULAR_INTENSITY_UNIFORM] = glGetUniformLocation(self.program, "light7SpecularIntensity");
    
    _uniforms[IS_TEXTURED_UNIFORM] = glGetUniformLocation(self.program, "isTextured");
    _uniforms[TEXTURE_SAMPLER_UNIFORM] = glGetUniformLocation(self.program, "s_texture");
    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(self.program, vertShader);
        glDeleteShader(vertShader);
        vertShader = 0;
    }
    if (fragShader) {
        glDetachShader(self.program, fragShader);
        glDeleteShader(fragShader);
        fragShader = 0;
    }
    
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

-(NSString *)filePathForTextureWithName:(NSString *)texName{
    return [[NSBundle mainBundle] pathForResource:texName ofType:@"png"];
}

-(void)drawGeometry{
    glBindVertexArrayOES(_vertexArrayObjects[VERTEX_ARRAY_BUFFER_OBJECT_0]);
    
    // Render the object again with ES2
    glUseProgram([self program]);
    
    if(self.isTextured){
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, (GLuint)self.textureAtlasID);
        glUniform1i(_uniforms[TEXTURE_SAMPLER_UNIFORM], 0);
        
        glUniform1f(_uniforms[IS_TEXTURED_UNIFORM], 1.0f);
    }
    else{
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, 0);
        
        glUniform1f(_uniforms[IS_TEXTURED_UNIFORM], 0.0f);
    }
    
    glUniformMatrix4fv(_uniformsLocal[MODELVIEWPROJECTION_MATRIX_UNIFORM], 1, 0, &self.modelViewProjectionMatrix[0][0]);
    glUniformMatrix4fv(_uniforms[MODELVIEW_MATRIX_UNIFORM], 1, 0, &self.modelViewMatrix[0][0]);
    
    mat4 convertWorldLightPositionToViewingPosition = self.viewMatrix * mat4(1.0f);;
    glUniformMatrix4fv(_uniforms[VIEW_MATRIX_UNIFORM], 1, 0, &convertWorldLightPositionToViewingPosition[0][0]);
    glUniformMatrix3fv(_uniforms[NORMAL_MATRIX_UNIFORM], 1, 0, &self.normalMatrix[0][0]);
    
    glUniform3fv(_uniforms[MATERIAL_AMBIENT_UNIFORM], 1, &self.materialAmbient[0]);
    glUniform3fv(_uniforms[MATERIAL_DIFFUSE_UNIFORM], 1, self.shape.material.diffuse);
    glUniform3fv(_uniforms[MATERIAL_SPECULAR_UNIFORM], 1, self.shape.material.specular);
    glUniform1f(_uniforms[MATERIAL_SPECULAR_EXP_UNIFORM], self.shape.material.shininess);
    
    glDrawElements(GL_TRIANGLES, (GLsizei)[self shape].mesh.indices.size(), GL_UNSIGNED_SHORT, 0);
    
    if(self.textureUnit == 0){
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, 0);
    }
    else if(self.textureUnit == 1){
        glActiveTexture(GL_TEXTURE1);
        glBindTexture(GL_TEXTURE_2D, 0);
    }
    else if(self.textureUnit == 2){
        glActiveTexture(GL_TEXTURE2);
        glBindTexture(GL_TEXTURE_2D, 0);
    }
    else if(self.textureUnit == 3){
        glActiveTexture(GL_TEXTURE3);
        glBindTexture(GL_TEXTURE_2D, 0);
    }
}

- (void)setupGL{
    glGenVertexArraysOES(1, &_vertexArrayObjects[VERTEX_ARRAY_BUFFER_OBJECT_0]);
    glBindVertexArrayOES(_vertexArrayObjects[VERTEX_ARRAY_BUFFER_OBJECT_0]);
    
    glGenBuffers(1, &_vertexBufferObjects[VERTEX_POS_ATTRIB]);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBufferObjects[VERTEX_POS_ATTRIB]);
    glBufferData(GL_ARRAY_BUFFER, [self shape].mesh.positions.size() * sizeof(GLfloat), &[self shape].mesh.positions[0], GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(VERTEX_POS_ATTRIB);
    glVertexAttribPointer(VERTEX_POS_ATTRIB, 3, GL_FLOAT, GL_FALSE, 0, NULL);
    
    glGenBuffers(1, &_vertexBufferObjects[VERTEX_NORMAL_ATTRIB]);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBufferObjects[VERTEX_NORMAL_ATTRIB]);
    glBufferData(GL_ARRAY_BUFFER, [self shape].mesh.normals.size() * sizeof(GLfloat), &[self shape].mesh.normals[0], GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(VERTEX_NORMAL_ATTRIB);
    glVertexAttribPointer(VERTEX_NORMAL_ATTRIB, 3, GL_FLOAT, GL_FALSE, 0, NULL);
    
    glGenBuffers(1, &_vertexBufferObjects[VERTEX_INDICES_ATTRIB]);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _vertexBufferObjects[VERTEX_INDICES_ATTRIB]);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, [self shape].mesh.indices.size() * sizeof(GLushort), &[self shape].mesh.indices[0], GL_STATIC_DRAW);
    
    if(self.isTextured){
        glGenBuffers(1, &_vertexBufferObjects[VERTEX_TEXTURE_COORDS_ATTRIB]);
        glBindBuffer(GL_ARRAY_BUFFER, _vertexBufferObjects[VERTEX_TEXTURE_COORDS_ATTRIB]);
        glBufferData(GL_ARRAY_BUFFER, [self shape].mesh.texcoords.size() * sizeof(GLfloat), &[self shape].mesh.texcoords[0], GL_STATIC_DRAW);
        
        glEnableVertexAttribArray(VERTEX_TEXTURE_COORDS_ATTRIB);
        glVertexAttribPointer(VERTEX_TEXTURE_COORDS_ATTRIB, 2, GL_FLOAT, GL_FALSE, 0, NULL);
    }
    
    glBindVertexArrayOES(0);
}

- (void)tearDownGL{
    glDeleteBuffers(1, &_vertexBufferObjects[VERTEX_POS_ATTRIB]);
    glDeleteBuffers(1, &_vertexBufferObjects[VERTEX_NORMAL_ATTRIB]);
    glDeleteBuffers(1, &_vertexBufferObjects[VERTEX_INDICES_ATTRIB]);
    glDeleteBuffers(1, &_vertexBufferObjects[VERTEX_TEXTURE_COORDS_ATTRIB]);
    
    glDeleteVertexArraysOES(1, &_vertexArrayObjects[VERTEX_ARRAY_BUFFER_OBJECT_0]);
    
    if (self.program) {
        glDeleteProgram(self.program);
        self.program = 0;
    }
}

@end
