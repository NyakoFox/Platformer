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
    float distance = distance(uv, center);
    if ((distance <= (time + shockParams.z)) && (distance >= (time - shockParams.z))) {
        float diff = (distance - time);
        float powDiff = 1.0 - pow(abs(diff*shockParams.x), shockParams.y); 
        float diffTime = diff  * powDiff;
        vec2 diffUV = normalize(uv - center); 
        texCoord = uv + (diffUV * diffTime);
    }
    gl_FragColor = texture2D(tex0, texCoord);
}
