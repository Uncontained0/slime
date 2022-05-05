#ifdef PIXEL

uniform vec2 imageSize;

float r = 1.0;

vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
{
    vec4 final = vec4(0);

    for(float x = -r; x <= r; x += 1.0)
    {
        for(float y = -r; y <= r; y += 1.0)
        {
            final += Texel(tex, texture_coords + (vec2(x,y)/imageSize) );
        }
    }
    
    final = final / 9;

    return final;
}

#endif