//
//  Shaders.metal
//  HelloMetal
//
//  Created by Tawa Nicolas on 29/6/17.
//  Copyright © 2017 Tawa Nicolas. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn {
	packed_float3 position;
	packed_float4 color;
	packed_float2 texCoord;
};

struct VertexOut {
	float4 position [[position]];
	float4 color;
	float2 texCoord;
};

vertex VertexOut tntutorial_vertex(const device VertexIn *vertex_array [[buffer(0)]],
								   unsigned int vid [[vertex_id]]) {
	
	VertexIn vIn = vertex_array[vid];
	
	VertexOut vOut;
	vOut.position = float4(vIn.position, 1.0);
	vOut.color = vIn.color;
	vOut.texCoord = vIn.texCoord;
	
	return vOut;
}

fragment float4 tntutorial_fragment(VertexOut interpolated [[stage_in]],
									sampler textureSampler [[sampler(0)]],
									texture2d<float> texture [[texture(0)]],
									texture2d<float> overlay [[texture(1)]],
									texture2d<float> weights [[texture(2)]]) {
	float4 cols1 = overlay.sample(textureSampler, interpolated.texCoord);
	if(cols1.r > 0) {
		return float4(0);
	}
	
	uint2 gid = uint2(interpolated.texCoord.x * texture.get_width(), interpolated.texCoord.y * texture.get_height());
	int size = weights.get_width();
	int radius = size / 2;
	
	float4 accumColor(0, 0, 0, 0);
	for (int j = 0; j < size; ++j)
	{
		for (int i = 0; i < size; ++i)
		{
			uint2 kernelIndex(i, j);
			uint2 textureIndex(gid.x + (i - radius), gid.y + (j - radius));
			float4 color = texture.read(textureIndex).rgba;
			float4 weight = weights.read(kernelIndex).rrrr;
			accumColor += weight * color;
		}
	}
	
	return float4(accumColor.rgb*0.5, 1);
}
