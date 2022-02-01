// SimpleShapeView.m
// SimpleShape
//
// Copyright © 2022 Paul Godavari. All rights reserved.


#import "SimpleShapeView.h"

@import Metal;
@import simd;


typedef struct
{
    vector_float4 position;
    vector_float4 color;
} SimpleVertex;


@implementation SimpleShapeView
{
    CAMetalLayer* metalLayer;
    id<MTLRenderPipelineState> pipelineState;
    id<MTLCommandQueue> cmdQueue;
    id<MTLBuffer> vertexBuffer;
    id<MTLBuffer> indexBuffer;
}


+ (id) layerClass
{
    return [CAMetalLayer class];
}


- (instancetype) initWithCoder:(NSCoder *)coder
{
    if (self = [super initWithCoder:coder]) {
        [self initializeMetal];
        [self createBuffers];
        [self drawBackground];
    }
    return self;
}


- (void) initializeMetal
{
    metalLayer = (CAMetalLayer*) self.layer;
    metalLayer.device = MTLCreateSystemDefaultDevice();
    metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;
    
    cmdQueue = [metalLayer.device newCommandQueue];
    
    id<MTLLibrary> library = [metalLayer.device newDefaultLibrary];
    id<MTLFunction> vertexFunc = [library newFunctionWithName:@"vertex_main"];
    id<MTLFunction> fragmentFunc = [library newFunctionWithName:@"fragment_main"];
    
    MTLRenderPipelineDescriptor* pipeline = [[MTLRenderPipelineDescriptor alloc] init];
    pipeline.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    pipeline.vertexFunction = vertexFunc;
    pipeline.fragmentFunction = fragmentFunc;
    
    NSError* error = nil;
    pipelineState = [metalLayer.device newRenderPipelineStateWithDescriptor:pipeline error:&error];
    if (!pipelineState) {
        NSLog(@"Creating pipeline state failed: %@", error);
    }
}


- (void) createBuffers
{
    static const SimpleVertex vertexes[] = {
        { {  0.5,  0.0,  0.0, 1.0 }, { 1.0, 0.0, 0.0, 1.0 } },
        { {  0.0,  0.5,  0.0, 1.0 }, { 1.0, 1.0, 0.0, 1.0 } },
        { { -0.5,  0.0,  0.0, 1.0 }, { 1.0, 0.0, 0.0, 1.0 } },
        { {  0.0, -0.25, 0.0, 1.0 }, { 0.0, 0.0, 1.0, 1.0 } },
        { { -0.5, -0.5,  0.0, 1.0 }, { 0.0, 1.0, 0.0, 1.0 } },
        { {  0.5, -0.5,  0.0, 1.0 }, { 0.0, 1.0, 0.0, 1.0 } },
    };
    
    vertexBuffer = [metalLayer.device newBufferWithBytes:vertexes length:sizeof(vertexes) options:MTLResourceOptionCPUCacheModeDefault];
    
    static const uint16_t indices[] = {
        0, 1, 2,
        0, 2, 3,
        2, 4, 3,
        3, 5, 0
    };
    
    indexBuffer = [metalLayer.device newBufferWithBytes:indices length:sizeof(indices) options:MTLResourceOptionCPUCacheModeDefault];
}


- (void) drawBackground
{
    id<MTLCommandBuffer> cmdBuffer = [cmdQueue commandBuffer];

    id<CAMetalDrawable> drawable = [metalLayer nextDrawable];
    
    MTLRenderPassDescriptor* render = [MTLRenderPassDescriptor renderPassDescriptor];
    render.colorAttachments[0].texture = drawable.texture;
    render.colorAttachments[0].loadAction = MTLLoadActionClear;
    render.colorAttachments[0].storeAction = MTLStoreActionStore;
    render.colorAttachments[0].clearColor = MTLClearColorMake(0.5, 0.5, 0.5, 1.0);
    
    id<MTLRenderCommandEncoder> encoder = [cmdBuffer renderCommandEncoderWithDescriptor:render];
    [encoder setRenderPipelineState:pipelineState];
    [encoder setVertexBuffer:vertexBuffer offset:0 atIndex:0];
    [encoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle
                        indexCount:(indexBuffer.length / sizeof(uint16_t))
                         indexType:MTLIndexTypeUInt16
                       indexBuffer:indexBuffer
                 indexBufferOffset:0];
    [encoder endEncoding];
    
    [cmdBuffer presentDrawable:drawable];
    [cmdBuffer commit];
}


@end
