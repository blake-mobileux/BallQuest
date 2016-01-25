//
//  Shader.vsh
//  GLKit Example
//
//  Created by Blake Harrison on 1/29/14.
//  Copyright (c) 2014 Blake Harrison. All rights reserved.
//

attribute vec2 a_texCoord;
attribute vec3 a_normal;
attribute vec4 a_position;

uniform mat3 normalMatrix;
uniform mat4 modelViewProjectionMatrix;
uniform mat4 modelViewMatrix;

varying vec2 v_texCoord;
varying vec3 v_cameraspace_normal;
varying vec4 v_cameraspace_position;

void main()
{
    v_cameraspace_normal = normalMatrix * normalize(a_normal);
    v_cameraspace_position = modelViewMatrix * a_position;
    v_texCoord = a_texCoord;
    gl_Position = modelViewProjectionMatrix * a_position;
}