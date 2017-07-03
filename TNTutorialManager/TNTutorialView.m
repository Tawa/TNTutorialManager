//
//  TNTutorialView.m
//  HelloMetal
//
//  Created by Tawa Nicolas on 29/6/17.
//  Copyright © 2017 Tawa Nicolas. All rights reserved.
//

#import "TNTutorialView.h"

#if (TN_DISABLE_METAL)

@import MetalKit;

const float vertexData[] = {
	-1.0, 1.0, 0.0, 1.0,1.0,1.0, 1.0, 0.0, 0.0,
	-1.0,-1.0, 0.0, 1.0,1.0,0.0, 1.0, 0.0, 1.0,
	1.0, 1.0, 0.0, 1.0,1.0,0.0, 1.0, 1.0, 0.0,
	1.0,-1.0, 0.0, 1.0,1.0,1.0, 1.0, 1.0, 1.0,
};

@interface TNTutorialView ()
{
	id<MTLDevice> device;
	CAMetalLayer *metalLayer;
	
	id<MTLBuffer> vertexBuffer;
	
	id<MTLRenderPipelineState> pipelineState;
	
	id<MTLCommandQueue> commandQueue;
	
	id<MTLTexture> texture;
	id<MTLSamplerState> samplerState;
	
	id<MTLTexture> overlayTexture;
	
	id<MTLTexture> weightsTexture;
}

@end

@implementation TNTutorialView

+(instancetype)instance
{
	return [[TNTutorialView alloc] initWithFrame:[UIScreen mainScreen].bounds];
}

-(instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	
	if (self) {
		self.backgroundColor = [UIColor clearColor];
		
		device = MTLCreateSystemDefaultDevice();
		
		[self generateWeights];
		
		self.animationIndex = 0;

		metalLayer = [[CAMetalLayer alloc] init];
		metalLayer.device = device;
		metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;
		metalLayer.framebufferOnly = YES;
		metalLayer.opaque = NO;
		metalLayer.backgroundColor = [[UIColor clearColor] CGColor];
		metalLayer.frame = [UIScreen mainScreen].bounds;
		[self.layer addSublayer:metalLayer];
		
		NSUInteger dataSize = sizeof(vertexData);
		vertexBuffer = [device newBufferWithBytes:vertexData length:dataSize options:0];
		
		id<MTLLibrary> defaultLibrary = [device newDefaultLibrary];
		NSError *error = nil;
		if (error) {
			NSLog(@"Error: %@", [error localizedDescription]);
		}
		id<MTLFunction> fragmentProgram = [defaultLibrary newFunctionWithName:@"tntutorial_fragment"];
		id<MTLFunction> vertexProgram = [defaultLibrary newFunctionWithName:@"tntutorial_vertex"];
		
		MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
		pipelineStateDescriptor.fragmentFunction = fragmentProgram;
		pipelineStateDescriptor.vertexFunction = vertexProgram;
		pipelineStateDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
		
		pipelineState = [device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor error:&error];
		if (error) {
			NSLog(@"Error making render pipeline state: %@", [error localizedDescription]);
		}
		
		commandQueue = [device newCommandQueue];
		
		MTLSamplerDescriptor *sampler = [[MTLSamplerDescriptor alloc] init];
		sampler.minFilter = MTLSamplerMinMagFilterLinear;
		sampler.magFilter = MTLSamplerMinMagFilterLinear;
		sampler.mipFilter = MTLSamplerMipFilterLinear;
		sampler.maxAnisotropy = 1;
		sampler.sAddressMode = MTLSamplerAddressModeClampToEdge;
		sampler.tAddressMode = MTLSamplerAddressModeClampToEdge;
		sampler.rAddressMode = MTLSamplerAddressModeClampToEdge;
		sampler.normalizedCoordinates = YES;
		sampler.lodMinClamp = 0;
		sampler.lodMaxClamp = FLT_MAX;

		samplerState = [device newSamplerStateWithDescriptor:sampler];
	}
	
	return self;
}

-(void)setImage:(UIImage *)image
{
	MTKTextureLoader *textureLoader = [[MTKTextureLoader alloc] initWithDevice:device];
	NSError *error = nil;
	texture = [textureLoader newTextureWithCGImage:[image CGImage] options:0 error:&error];
	if (error) {
		NSLog(@"Error Loading Texture from Image: %@", [error localizedDescription]);
	}
}

-(void)setOverlay:(UIImage *)overlay
{
	MTKTextureLoader *textureLoader = [[MTKTextureLoader alloc] initWithDevice:device];
	NSError *error = nil;
	overlayTexture = [textureLoader newTextureWithCGImage:[overlay CGImage] options:0 error:&error];
	if (error) {
		NSLog(@"Error Loading Texture from Image: %@", [error localizedDescription]);
	}
}

-(void)layoutSubviews
{
	[super layoutSubviews];
	
	metalLayer.frame = self.bounds;
}

-(id<MTLTexture>)generateWeight:(NSInteger)radius
{
	const float sigma = radius/2;
	const int size = (round(radius) * 2) + 1;
	
	float delta = 0;
	float expScale = 0;;
	if (radius > 0.0)
	{
		delta = (radius * 2) / (size - 1);;
		expScale = -1 / (2 * sigma * sigma);
	}
	
	float *weights = malloc(sizeof(float) * size * size);
	
	float weightSum = 0;
	float y = -radius;
	for (int j = 0; j < size; ++j, y += delta)
	{
		float x = -radius;
		
		for (int i = 0; i < size; ++i, x += delta)
		{
			float weight = expf((x * x + y * y) * expScale);
			weights[j * size + i] = weight;
			weightSum += weight;
		}
	}
	
	const float weightScale = 1 / weightSum;
	for (int j = 0; j < size; ++j)
	{
		for (int i = 0; i < size; ++i)
		{
			weights[j * size + i] *= weightScale;
		}
	}
	
	MTLTextureDescriptor *textureDescriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatR32Float
																								 width:size
																								height:size
																							 mipmapped:NO];
	
	id <MTLTexture> tempTexture = [device newTextureWithDescriptor:textureDescriptor];
	
	MTLRegion region = MTLRegionMake2D(0, 0, size, size);
	[tempTexture replaceRegion:region mipmapLevel:0 withBytes:weights bytesPerRow:sizeof(float) * size];
	
	free(weights);
	
	return tempTexture;
}

-(void)generateWeights
{
	weightsTexture = [self generateWeight:5];
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
	id<CAMetalDrawable> drawable = [metalLayer nextDrawable];
	MTLRenderPassDescriptor *renderPassDescriptor = [[MTLRenderPassDescriptor alloc] init];
	renderPassDescriptor.colorAttachments[0].texture = drawable.texture;
	renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
	renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 0);
	
	
	id<MTLCommandBuffer> commandBuffer = [commandQueue commandBuffer];
	id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
	[renderEncoder setRenderPipelineState:pipelineState];
	[renderEncoder setVertexBuffer:vertexBuffer offset:0 atIndex:0];
	
	[renderEncoder setFragmentSamplerState:samplerState atIndex:0];

	[renderEncoder setFragmentTexture:texture atIndex:0];
	[renderEncoder setFragmentTexture:overlayTexture atIndex:1];
	[renderEncoder setFragmentTexture:weightsTexture atIndex:2];
	
	[renderEncoder setCullMode:MTLCullModeFront];
	
	[renderEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4 instanceCount:1];
	[renderEncoder endEncoding];
	
	[commandBuffer presentDrawable:drawable];
	[commandBuffer commit];
}

@end

#endif
