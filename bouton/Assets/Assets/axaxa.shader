Shader "Unlit/axaxa"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		truc ("truc", float) = 0.0 
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float	truc;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			/*
void mainImage(out float4 c_out, in float2 f)
{
    
}


			*/

float2	march(float3 pos, float3 dir);
float3	camera(float2 uv);
void	rotate(inout float2 v, float angle);
float3	calcNormal( in float3 pos, float e, float3 dir);
float	loop_circle(float3 p);
float	circle(float3 p, float phase);
float	sdTorus( float3 p, float2 t, float phase );
float	mylength(float2 p);
float	mylength(float3 p);
float	nrand( float2 n );

float3	ret_col;	// color
float3 h;
float is_started;
float proche_cottin;
float trans_appear;

#define I_MAX		200.
#define E			0.0001
#define FAR			110.
#define PI			3.14159
#define TAU			PI*2.

// anim == clamp(exp(-time/value+offset/value), .0, 1.);

float	trans(float start, float time, float speed)
{
	return 1. - clamp(exp(-time*speed+start*speed), .0, 1. );
}

float	cube(float3 p)
{
	return max(abs(p.x), max(abs(p.y), abs(p.z)));
}

float nrand(float x, float y)
    {
        return frac(sin(dot(float2(x, y), float2(12.9898, 78.233))) * 43758.5453);
    }

float	scene(float3 p)
{  
    float	var;
    float	mind = 1e5;
    float displz = truc*1.;//is_started;
//    p.y -= -.25;
    p.z -= displz;
    
    rotate(p.xy, .5*sin( .0*sin(p.z*.125-_Time.y*.5)*3.06125+(p.z*.125)+_Time.y*.5) );
    
    //p.xy += float2(cos(p.z*3.125)*.125, sin(p.z*3.125)*.125);
    float3 pp = p;
//    rotate(pp.xy, p.z*.125);
    pp = frac(pp)-.5;
    
    mind = min(mylength(pp.yz), min(mylength(pp.xy), mylength(pp.xz) ))-.051;
    
    pp = p;
    //float turn = 1.57*( (p.z*1.)/1.);
	float r = length(float2(pp.x, frac(pp.z)-.5) );
    mind = min(mind
               ,
               mylength(float2(abs(pp.x)-.5, pp.y))-.051 // rails
              );
    float cadres = max(abs(abs(pp.x)-.2)-.2, max(abs(pp.y)-.3, abs(pp.z+1.75-proche_cottin+displz-2.+2.*trans_appear)-.01) );
    float2 texcd = float2(abs(pp.x) , (pp.y)+.250 )*1.5;
    if (cadres <= E*1.)
    {
        float3 texcol = tex2D(_MainTex, texcd).xyz;
		
        float2 texcdg = texcd;
        float2 texcdb = texcd;
        texcdg.x += .01250151*(sin(floor(texcdg.y*500.)+_Time.y*0. ) );
        texcdb.x += .01250151*(sin(floor(texcdb.y*500.)+_Time.y*0. +1.57) );
        float3 tcg = tex2D(_MainTex, texcdg).xyz;
        float3 tcb = tex2D(_MainTex, texcdb).xyz;
        texcol = float3(texcol.x, tcg.y, tcb.z);
		
    	h = (texcol*1.);//*1./max(cadres*cadres+1.75, .1);
    }
    mind = min(mind
               ,
               cadres
              );
    mind = min(mind
               , // cadres des cadres
               mylength(float2(mylength(float2(abs(pp.x)-.2, abs(pp.y)-.1) )-.2, pp.z+1.75-proche_cottin+displz-2.+2.*trans_appear ))-.0251
               );
    mind = min(mind
               ,
               max(-(mylength(float2(abs(pp.x)-.45,pp.y) )-.025), mylength(float3(abs(pp.x)-.45,pp.y, pp.z+1.75-proche_cottin+displz-2.+2.*trans_appear) )-.05)
               );
    h += float3(.75, .45, .1)*1./max(mind*mind*30000.+50., .001);
    
    float ecrous = 1e5;
    pp = p;
    pp.x = abs(pp.x)-.5;
    pp.z = fmod(pp.z, .0625);//-.0625*.5;
    
    ecrous = mylength(float2(length(pp.xz)-.051, pp.y ))-.01251;

    mind = min(mind
               ,
               ecrous
               );
    
    return (mind);
}

float2	march(float3 pos, float3 dir)
{
    float2	dist = float2(0.0, 0.0);
    float3	p = float3(0.0, 0.0, 0.0);
    float2	s = float2(0.0, 0.0);
		[loop]
	    for (float i = -1.; i < I_MAX; ++i)
	    {
            float3 dirr;
            dirr = dir;
            rotate(dirr.xz, dist.y*.02510+_Time.y*.0+.0*sin(_Time.y*1.)*.125);
            //rotate(dirr.zy, dist.y*.0510+_Time.y*.0+.0*sin(_Time.y*1.)*.125);
	    	p = pos + dirr * dist.y;
	        dist.x = scene(p);
	        dist.y += dist.x;
	        if (dist.x < E || dist.y > FAR)
            {
                break;
            }
	        s.x++;
    }
    s.y = dist.y;
    return (s);
}

// Utilities

float	mylength(float2 p)
{
	float	ret;

    //ret = max( abs(p.x)+.5*abs(p.y), abs(p.y)+.5*abs(p.x) );
    ret = max( abs(p.x), abs(p.y) );
    
    return ret;
}

float	mylength(float3 p)
{
	float	ret;

    //ret = max( abs(p.x)+.5*abs(p.y), abs(p.y)+.5*abs(p.x) );
    //ret = max(abs(p.z)+.5*abs(p.x), ret);
    ret = max(abs(p.x), max(abs(p.y), abs(p.z)));
    return ret;
}

void rotate(inout float2 v, float angle)
{
	v = float2(cos(angle)*v.x+sin(angle)*v.y,-sin(angle)*v.x+cos(angle)*v.y);
}

float2	rot(float2 p, float2 ang)
{
	float	c = cos(ang.x);
    float	s = sin(ang.y);
    float2x2	m = float2x2(c, -s, s, c);
    
    return mul(p, m);
}

float3    camera(float2 u)
{
    return normalize(u.x * float3(1.,.0,.0)*4./3. + u.y * float3(.0,1.,.0)*3./4. - float3(.0,.0,1.)*1.);
}

float3 calcNormal( in float3 pos, float e, float3 dir)
{
    float3 eps = float3(e,0.0,0.0);

    return normalize(float3(
           march(pos+eps.xyy, dir).y - march(pos-eps.xyy, dir).y,
           march(pos+eps.yxy, dir).y - march(pos-eps.yxy, dir).y,
           march(pos+eps.yyx, dir).y - march(pos-eps.yyx, dir).y ));
}

			float4 frag (v2f i) : SV_Target
			{
				// sample the texture
				float4 col = tex2D(_MainTex, i.uv);
				// apply fog

				is_started = .0;//clamp(exp(_Time.y*.125-10.), .0, 1.);
				trans_appear = trans(.25, truc, 1.);
			    proche_cottin = -55.*trans(10., truc, .25);//(1. -clamp(exp(-_Time.y*.125+5.), .0, 1.) ) ;
			    col.xyz = float3(0., 0., 0.);
				//float2 R = iResolution.xy,
		        float2 uv  = i.uv.xy*1.;//float2(f-R/2.) / R.y;
				float3	dir = camera(uv-.5);
    			float3	pos = float3(.0, .0, 0.0);

    			float2	inter = (march(pos, dir));
    //if (inter.y >= FAR)
    //    ret_col = float3(.90, .82, .70);
    //else
    //    ret_col = .5*float3(.6, .26, .3);
    //col.xyz = ret_col*(1.-inter.x*.005);
    			col.xyz = max(col.xyz, h);
    			//c_out =  float4(col,1.0);
				col.xyz *= (1.1-length( (uv-.5)*float2(3./4., 4./3.) )*1.5);;
				return col;
			}
			ENDCG
		}
	}
}
