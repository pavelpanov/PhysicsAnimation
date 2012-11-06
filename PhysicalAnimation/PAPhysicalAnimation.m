//
//  PAPhysicalAnimation.m
//  WeHeartPics
//
//  Created by Pavel Panov on 7/17/12.
//  Copyright (c) 2012 WeHeartPics. All rights reserved.
//


#import "PAPhysicalAnimation.h"

#import "ChipmunkHastySpace.h"

#import <QuartzCore/QuartzCore.h>
#import <sys/sysctl.h>

#import "transform.h"

#define GRABABLE_MASK_BIT (1<<31)

@interface PAPhysicalAnimation() {
	ChipmunkHastySpace *_space;
	ChipmunkMultiGrab *_multiGrab;
	
	Transform _touchTransform;
	
	NSTimeInterval _accumulator;
	NSTimeInterval _fixedTime;
    
	CADisplayLink *_displayLink;
	NSTimeInterval _lastTime, _lastFrameTime, _lastUpdateTicksTime;
    
    int _physicsTicks, _updateTicks;
    
    ChipmunkBody *_updateBody;
    UpdateBlockType _updateBlock;
}

@property (nonatomic, readonly) NSUInteger ticks;
@property (nonatomic, readonly) NSTimeInterval fixedTime;
@property (nonatomic, readonly) NSTimeInterval updateTime;
@property (nonatomic, readonly) NSTimeInterval accumulator;
@property (nonatomic, assign) cpFloat timeScale;

@property (nonatomic, readonly) NSTimeInterval preferredTimeStep;
@property (nonatomic, assign) NSTimeInterval timeStep;

@property (nonatomic, assign) Transform touchTransform;

- (Class)spaceClass;

- (void)update:(NSTimeInterval)dt;
- (void)tick:(CADisplayLink *)displayLink;

@end

@implementation PAPhysicalAnimation

@synthesize touchTransform = _touchTransform;
@synthesize space = _space;
@synthesize ticks = _ticks;
@synthesize fixedTime = _fixedTime;
@synthesize accumulator = _accumulator;
@synthesize timeScale = _timeScale;
@synthesize timeStep = _timeStep;

@dynamic staticBody;

- (NSTimeInterval)updateTime
{
	return _fixedTime + _accumulator;
}

- (ChipmunkBody *)staticBody
{
	return _space.staticBody;
}

- (Class)spaceClass
{
	return [ChipmunkHastySpace class];
}

- (id)init
{
	if ((self = [super init])) {
		_space = [[self.spaceClass alloc] init];
		_space.threads = 0;
		
		cpFloat grabForce = 1e5;
		_multiGrab = [[ChipmunkMultiGrab alloc] initForSpace:self.space withSmoothing:cpfpow(0.3, 60) withGrabForce:grabForce];
		_multiGrab.layers = GRABABLE_MASK_BIT;
		_multiGrab.grabFriction = grabForce*0.1;
		_multiGrab.grabRotaryFriction = 1e3 * 8;
		_multiGrab.grabRadius = 20.0;
		_multiGrab.pushMass = 10.0;
		_multiGrab.pushFriction = 0.7;
		_multiGrab.pushMode = TRUE;
		
		_timeScale = 1.0;
		_timeStep = self.preferredTimeStep;
	}
	
	return self;
}

- (void)handleAnimationForBody:(ChipmunkBody *)body
                   updateBlock:(UpdateBlockType)updateBlock
{
    _updateBody = body;
    _updateBlock = updateBlock;
}

- (void)startAnimation
{
	_displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick:)];
	_displayLink.frameInterval = 1;
	[_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)stopAnimation
{
    _updateBody = nil;
    _updateBlock = nil;
    
    [_displayLink invalidate], _displayLink = nil;
}

- (id)add:(NSObject<ChipmunkObject> *)obj
{
    return [_space add:obj];
}
- (id)remove:(NSObject<ChipmunkObject> *)obj
{
    return [_space remove:obj];
}

- (NSTimeInterval)preferredTimeStep;
{
	return 1.0/60.0;
}

- (void)update:(NSTimeInterval)dt
{
    self.space.gravity = cpvmult(cpv(0, 1), 3000.0);

	NSTimeInterval fixed_dt = _timeStep;
	
	_accumulator += dt*self.timeScale;
	while (_accumulator > fixed_dt) {
        [self.space step:dt];
        _ticks++;

		_accumulator -= fixed_dt;
		_fixedTime += fixed_dt;
	}
}

#define MAX_DT (1.0/60.0)

- (void)tick:(CADisplayLink *)displayLink
{
    @try {
        NSTimeInterval time = _displayLink.timestamp;
        
        NSTimeInterval dt = MIN(time - _lastTime, MAX_DT);
        [self update:dt];
        
        BOOL needs_sync = (time - _lastFrameTime > MAX_DT);
        if (needs_sync) {
            [self performSelectorOnMainThread:@selector(animationDidUpdate) withObject:nil waitUntilDone:YES];
            
            _updateTicks++;
            if (_updateTicks == 30)
                NSLog(@"fps %f", _updateTicks / (time - _lastUpdateTicksTime)), _updateTicks = 0, _lastUpdateTicksTime = time;
        }
        
        _lastTime = time;
    }
    @catch (NSException *exception) {
        
        printf("space catch :(\n");
    }
}

#pragma mark WPPhysicalAnimationUpdate

- (void)animationDidUpdate
{
    if (_updateBody && _updateBlock && [_space.bodies containsObject:_updateBody])
    {
        cpBody *cbody = _updateBody.body;
        cpVect pos = cpvadd(cbody->p, cpvmult(cbody->v, _accumulator));
        float ang = cbody->a + cbody->w*_accumulator;
        
        _updateBlock(pos, ang);
    }
}

#pragma mark Touches

- (cpVect)convertTouch:(UITouch *)touch inView:(UIView *)view;
{
	cpVect point = [touch locationInView:view];
    
    return point;
}

- (void)touchesBegan:(NSSet *)touches inView:(UIView *)view
{
    for (UITouch *touch in touches)
        [_multiGrab beginLocation:[self convertTouch:touch inView:(UIView *)view]];
}

- (void)touchesMoved:(NSSet *)touches inView:(UIView *)view
{
    for (UITouch *touch in touches)
        [_multiGrab updateLocation:[self convertTouch:touch inView:(UIView *)view]];
}

- (void)touchesEnded:(NSSet *)touches inView:(UIView *)view
{
    for (UITouch *touch in touches)
        [_multiGrab endLocation:[self convertTouch:touch inView:(UIView *)view]];
}

- (void)touchesCancelled:(NSSet *)touches inView:(UIView *)view
{
    [self touchesEnded:touches inView:view];
}

@end
