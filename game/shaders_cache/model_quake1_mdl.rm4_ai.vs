// Autogenerated by LunarViewer
// ANIM_INTERPOLATION = 1
// RENDERMODE = 4
// VERTEX_SHADER = 1
#version 330



#line 1










uniform mat4 mvp;
uniform mat4 matModel;
uniform mat4 matNormal;
uniform vec2 screenSize;
uniform vec3 modelScale;

uniform ivec4 animData;






uniform float floorOffset;
uniform float lightOffset;
uniform int isMirrored;
uniform bool isAlphaTested;

uniform sampler2D textureModelSkin;
uniform sampler2D textureColormapLUT;
uniform sampler2D texturePaletteLUT;
uniform sampler2D textureNormalLUT;
uniform sampler2D textureVertexAnim;


in vec3 vertexPosition;
in vec2 vertexTexCoord;
in vec4 vertexColor;
in vec3 vertexNormal;
in vec4 vertexTangent;

out float gl_ClipDistance[2];


            noperspective out vec2 fragTexCoord;
            noperspective out vec4 fragColor;
            noperspective out vec3 fragNormal;
            noperspective out vec4 fragTangent;
            noperspective out float fragLight;
            noperspective out float fog;





const float SCREEN_WIDTH = 160.0;
const float SCREEN_HEIGHT = 120.0;

struct AnimatedVert
{
 vec3 Position;
 vec3 Normal;
};

float GetInterpolationValue(int val)
{
 return float(val)/ 16384.0;
}

float easeOutElastic(float x)
{
 float c4 =(2 * 3.14)/ 3;

 return pow(2, - 10 * x)* sin((x * 10 - 0.75)* c4)+ 1;
}

float easeOutBounce(float x)
{
 float n1 = 7.5625;
 float d1 = 2.75;

 if(x < 1 / d1){
  return n1 * x * x;
 } else if(x < 2 / d1){
  return n1 *(x -= 1.5 / d1)* x + 0.75;
 } else if(x < 2.5 / d1){
  return n1 *(x -= 2.25 / d1)* x + 0.9375;
 } else {
  return n1 *(x -= 2.625 / d1)* x + 0.984375;
 }
}

float easeOutCubic(float x)
{
 return 1 - pow(1 - x, 3);
}

vec3 Interpolate(vec3 a, vec3 b, float alpha)
{

 return mix(a, b, alpha);




}

AnimatedVert GetLocalInterpolatedVertex(float U)
{
 AnimatedVert v;
 float interp = GetInterpolationValue(animData . w);


 float V1 = float(animData . x + 0.1f)/ float(animData . z);
 float V2 = float(animData . y + 0.1f)/ float(animData . z);

 vec4 a1 = texture2D(textureVertexAnim, vec2(U, V1)). rgba;
 vec4 a2 = texture2D(textureVertexAnim, vec2(U, V2)). rgba;

 v . Position = Interpolate(a1 . rgb, a2 . rgb, interp);
 v . Normal = normalize((Interpolate(texture2D(textureNormalLUT, vec2(a1 . a, 0.0)). rgb,
    texture2D(textureNormalLUT, vec2(a2 . a, 0.0)). rgb, interp)));

 return v;
}

AnimatedVert GetLocalVertex(float U)
{
 AnimatedVert v;

 float V2 = float(animData . y + 0.1f)/ float(animData . z);

 vec4 a2 = texture2D(textureVertexAnim, vec2(U, V2)). rgba;

 v . Position = a2 . rgb;
 v . Normal = normalize(texture2D(textureNormalLUT, vec2(a2 . a, 0.0)). rgb);

 return v;
}

void main(void)
{
 AnimatedVert v =

  GetLocalInterpolatedVertex(vertexTangent . r)



 ;

 vec3 finalVertPos = vertexPosition +(v . Position * 256.f * modelScale);

 finalVertPos = vec3(finalVertPos . x, finalVertPos . z, - finalVertPos . y);

 vec3 normal = vec3(v . Normal . x, isMirrored > 0 ? - v . Normal . z : v . Normal . z, - v . Normal . y);

 normal = normalize(vec3(matNormal * vec4(normal, 1)));

   gl_Position = mvp * vec4(finalVertPos, 1);

   fragTexCoord = vertexTexCoord;
 vec3 fragPosition = vec3(matModel * vec4(finalVertPos, 1.0));

   vec2 screenSpace =(gl_Position . xyz / gl_Position . w). xy;
   screenSpace = floor(screenSpace * screenSize)/ screenSize;
   screenSpace *= gl_Position . w;
   gl_Position . x = screenSpace . x;
   gl_Position . y = screenSpace . y;

   fragColor = vertexColor;

 fragLight =((clamp((dot(normal, normalize(vec3(0.0, 1, 0)))+ 1.0)/ 2.0, 0.0, 1.0))+(lightOffset));

 fragTangent = vertexTangent;

 fragNormal = normal;

 gl_ClipDistance[0]= dot(vec4(fragPosition, 1.0), vec4(0, 1, 0, - floorOffset));
 gl_ClipDistance[1]= dot(vec4(fragPosition, 1.0), vec4(0, - 1, 0, floorOffset));
}
