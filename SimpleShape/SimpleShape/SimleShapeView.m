// SimleShapeView.m
// SimpleShape
//
// Copyright © 2022 Paul Godavari. All rights reserved.


#import "SimleShapeView.h"

@import Metal;


@implementation SimleShapeView
{
    CAMetalLayer* metalLayer;
    id<MTLRenderPipelineState> pipelineState;
    id<MTLCommandQueue> cmdQueue;
}


+ (id) layerClass
{
    return [CAMetalLayer class];
}


- (instancetype) initWithCoder:(NSCoder *)coder
{
    if (self = [super initWithCoder:coder]) {
        [self initializeMetal];
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
    
//    MTLRenderPipelineDescriptor* pipeline = [[MTLRenderPipelineDescriptor alloc] init];
//    pipeline.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
//    
//    NSError* error = nil;
//    pipelineState = [metalLayer.device newRenderPipelineStateWithDescriptor:pipeline error:&error];
//    if (!pipelineState) {
//        NSLog(@"Creating pipeline state failed: %@", error);
//    }
}


- (void) drawBackground
{
    id<MTLCommandBuffer> cmdBuffer = [cmdQueue commandBuffer];
    
    MTLRenderPassDescriptor* render = [MTLRenderPassDescriptor renderPassDescriptor];
    id<CAMetalDrawable> drawable = [metalLayer nextDrawable];
    render.colorAttachments[0].texture = drawable.texture;
    render.colorAttachments[0].loadAction = MTLLoadActionClear;
    render.colorAttachments[0].storeAction = MTLStoreActionStore;
    render.colorAttachments[0].clearColor = MTLClearColorMake(1.0, 0.0, 0.0, 1.0);
    
    id<MTLRenderCommandEncoder> encoder = [cmdBuffer renderCommandEncoderWithDescriptor:render];
    [encoder endEncoding];
    
    [cmdBuffer presentDrawable:drawable];
    [cmdBuffer commit];
}


@end
