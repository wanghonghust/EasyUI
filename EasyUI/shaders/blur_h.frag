#version 440

layout(location = 0) in vec2 texCoord;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 1) uniform buf {
    float step;
    float r;
};

layout(binding = 2) uniform sampler2D src;

void main()
{
    float s = step * r * 0.5;
    vec2 uv = texCoord;
    vec4 c = vec4(0.0);
    c += texture(src, uv + vec2(-4.0 * s, 0.0)) * 0.0162;
    c += texture(src, uv + vec2(-3.0 * s, 0.0)) * 0.0540;
    c += texture(src, uv + vec2(-2.0 * s, 0.0)) * 0.1214;
    c += texture(src, uv + vec2(-1.0 * s, 0.0)) * 0.1950;
    c += texture(src, uv)                        * 0.2268;
    c += texture(src, uv + vec2(1.0 * s, 0.0))  * 0.1950;
    c += texture(src, uv + vec2(2.0 * s, 0.0))  * 0.1214;
    c += texture(src, uv + vec2(3.0 * s, 0.0))  * 0.0540;
    c += texture(src, uv + vec2(4.0 * s, 0.0))  * 0.0162;
    fragColor = c;
}
