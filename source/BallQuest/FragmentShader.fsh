//
//  Shader.fsh
//  GLKit Example
//
//  Created by Blake Harrison on 1/29/14.
//  Copyright (c) 2014 Blake Harrison. All rights reserved.
//

precision highp float;
precision highp int;

uniform float isTextured;

uniform vec3 materialAmbient;
uniform vec3 materialDiffuse;
uniform vec3 materialSpecular;
uniform float materialSpecularExponent;

uniform vec4 sceneAmbientIntensity;

uniform vec4 light0Position;
uniform vec4 light0DiffuseIntensity;
uniform vec4 light0SpecularIntensity;

uniform vec4 light1Position;
uniform vec4 light1DiffuseIntensity;
uniform vec4 light1SpecularIntensity;

uniform vec4 light2Position;
uniform vec4 light2DiffuseIntensity;
uniform vec4 light2SpecularIntensity;

uniform vec4 light3Position;
uniform vec4 light3DiffuseIntensity;
uniform vec4 light3SpecularIntensity;

uniform vec4 light4Position;
uniform vec4 light4DiffuseIntensity;
uniform vec4 light4SpecularIntensity;

uniform vec4 light5Position;
uniform vec4 light5DiffuseIntensity;
uniform vec4 light5SpecularIntensity;

uniform vec4 light6Position;
uniform vec4 light6DiffuseIntensity;
uniform vec4 light6SpecularIntensity;

uniform vec4 light7Position;
uniform vec4 light7DiffuseIntensity;
uniform vec4 light7SpecularIntensity;

uniform mat4 viewMatrix;

varying vec2 v_texCoord;
varying vec3 v_cameraspace_normal;
varying vec4 v_cameraspace_position;

uniform sampler2D s_texture;

struct lightSource
{
    vec4 position;
    vec4 diffuse;
    vec4 specular;
    float constantAttenuation, linearAttenuation, quadraticAttenuation;
};

vec3 ambientTerms(){
    return sceneAmbientIntensity.xyz * materialAmbient;
}

float diffuseTerm(in vec3 normal, in vec3 lightDirection){
    float diffuseTerm = max(0.0, dot(normal, lightDirection));
    
    return  diffuseTerm;
}

float specularTerm( in vec3 lightDirection, in vec3 normal, in vec3 viewDirection){
    highp vec3 reflectDirection = normalize(reflect(-lightDirection, normal));
    highp float specularTerm = max(0.0, dot(reflectDirection, viewDirection));
    if(materialSpecularExponent != 0.0){
        specularTerm = pow(specularTerm, materialSpecularExponent);
    }
    else{
        specularTerm = 0.0;
    }
    
    return specularTerm;
}

vec3 phongReflection(in lightSource light, in vec3 color, in vec3 normal, in vec4 diffuseTextureColor, in vec3 viewDirection){
    highp vec3 lightDirection;
    float attenuation;
    
    if(light.position.w == 0.0){
        lightDirection = normalize(vec3(light.position));
        attenuation = 1.0;
    }
    else{
        lightDirection = vec3(light.position - v_cameraspace_position);
        float distance = length(lightDirection);
        
        attenuation = (625.0 / (625.0 + light.quadraticAttenuation * distance * distance));
        lightDirection = normalize(lightDirection);
    }
    
    return color + light.diffuse.xyz * diffuseTerm(normal, lightDirection) * diffuseTextureColor.xyz * attenuation + light.specular.xyz * specularTerm(lightDirection, normal, viewDirection) * materialSpecular * attenuation;
}

void main()
{
    const int numberOfLights = 8;
    
    lightSource lights[numberOfLights];
    
    lightSource light0 = lightSource(
                                     viewMatrix * light0Position,
                                     light0DiffuseIntensity,
                                     light0SpecularIntensity,
                                     0.0, 0.0, 1.0
                                     );
    
    lightSource light1 = lightSource(
                                     viewMatrix * light1Position,
                                     light1DiffuseIntensity,
                                     light1SpecularIntensity,
                                     0.0, 0.0, 1.0    );
    
    lightSource light2 = lightSource(
                                     viewMatrix * light2Position,
                                     light2DiffuseIntensity,
                                     light2SpecularIntensity,
                                     0.0, 0.0, 1.0
                                     );
    
    lightSource light3 = lightSource(
                                     viewMatrix * light3Position,
                                     light3DiffuseIntensity,
                                     light3SpecularIntensity,
                                     0.0, 0.0, 1.0
                                     );
    
    lightSource light4 = lightSource(
                                     viewMatrix * light4Position,
                                     light4DiffuseIntensity,
                                     light4SpecularIntensity,
                                     0.0, 0.0, 1.0
                                     );
    
    lightSource light5 = lightSource(
                                     viewMatrix * light5Position,
                                     light5DiffuseIntensity,
                                     light5SpecularIntensity,
                                     0.0, 0.0, 1.0
                                     );
    
    lightSource light6 = lightSource(
                                     viewMatrix * light6Position,
                                     light6DiffuseIntensity,
                                     light6SpecularIntensity,
                                     0.0, 0.0, 1.0
                                     );
    
    lightSource light7 = lightSource(
                                     viewMatrix * light7Position,
                                     light7DiffuseIntensity,
                                     light7SpecularIntensity,
                                     0.0, 0.0, 1.0
                                     );
    
    lights[0] = light0;
    lights[1] = light1;
    lights[2] = light2;
    lights[3] = light3;
    lights[4] = light4;
    lights[5] = light5;
    lights[6] = light6;
    lights[7] = light7;
    
    highp vec4 diffuseTextureColor = texture2D(s_texture, v_texCoord);
    
    if(isTextured == 0.0){
        diffuseTextureColor = vec4(materialDiffuse, 1.0);
    }
    
    highp vec3 normal = normalize(v_cameraspace_normal);
    highp vec3 viewDirection = vec3(0.0, 0.0, 1.0);
    
    highp vec3 color = ambientTerms();
    color =  phongReflection(lights[7],phongReflection(lights[6], phongReflection(lights[5], phongReflection(lights[4], phongReflection(lights[3], phongReflection(lights[2], phongReflection(lights[1], phongReflection(lights[0], color, normal, diffuseTextureColor, viewDirection), normal, diffuseTextureColor, viewDirection), normal, diffuseTextureColor, viewDirection), normal, diffuseTextureColor, viewDirection), normal, diffuseTextureColor, viewDirection), normal, diffuseTextureColor, viewDirection), normal, diffuseTextureColor, viewDirection), normal, diffuseTextureColor, viewDirection);
    
    color.x = min(1.0, color.x);
    color.y = min(1.0, color.y);
    color.z = min(1.0, color.z);
    
    gl_FragColor = vec4(color, 1.0);
}