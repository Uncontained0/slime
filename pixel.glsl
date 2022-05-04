#ifdef PIXEL

uniform float r = 3.0;
uniform vec2 imageSize;

vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
{
    vec4 final = vec4(0.0);

    for(float x = -r; x <= r; x += 1.0)
    {
        for(float y = -r; y <= r; y += 1.0)
        {
            final += Texel(tex, texture_coords + (vec2(x,y)/imageSize) );
        }
    }

    return final / ((2.0 * r + 1.0) * (2.0 * r + 1.0));
}

#endif