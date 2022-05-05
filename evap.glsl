#ifdef PIXEL

uniform vec4 defaultColor = vec4(1);
uniform float evapRate = 1.0;

vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
{
    return Texel(tex, texture_coords) - (defaultColor / vec4(evapRate) );
}

#endif