#ifdef PIXEL

float r = 1.0;
uniform vec4 defaultColor = vec4(1);
uniform vec4 evapRate = vec4(10.0);
uniform vec2 imageSize;

float max(float a, float b)
{
    if (a > b)
    {
        return a;
    }
    else
    {
        return b;
    }
}

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

	final = final - evapRate;

    final.x = max(final.x,0);
    final.y = max(final.y,0);
    final.z = max(final.z,0);
    final.w = max(final.w,0);

    return final;
}

#endif