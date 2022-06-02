// This shader was not written by me (I don't know GLSL yet, it's so intimidating despite just being fancy C)
// This shader has been posted in many places and improved upon or modified in pretty much all of them,
// so I don't know the origin. Lost to time, I guess.
// I THINK this is as far as it goes: https://www.geeks3d.com/20091116/shader-library-2d-shockwave-post-processing-filter-glsl/
// Anyway, this took a few tweaks from me to get it to work well.

precision mediump float;
#define PROCESSING_TEXTURE_SHADER

varying vec4 vertTexCoord;
uniform sampler2D tex0;
uniform vec2 center;
uniform float time;
uniform vec3 shockParams;
void main() 
{
    vec2 uv = vertTexCoord.xy;
    uv.y = 1.-uv.y;
    vec2 texCoord = uv;
    float dist = distance(uv, center);
    if ((dist <= (time + shockParams.z)) && (dist >= (time - shockParams.z))) {
        float diff = (dist - time);
        float powDiff = 1.0 - pow(abs(diff*shockParams.x), shockParams.y); 
        float diffTime = diff  * powDiff;
        vec2 diffUV = normalize(uv - center); 
        texCoord = uv + (diffUV * diffTime);
    }
    gl_FragColor = texture2D(tex0, texCoord);
}
