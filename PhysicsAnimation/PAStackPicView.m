//
//  PAPhysicalStackPicView.m
//  WeHeartPics
//
//  Created by Pavel Panov on 7/17/12.
//  Copyright (c) 2012 WeHeartPics. All rights reserved.
//

#import "PAStackPicView.h"

#import "PAStackPicsView.h"

@interface PAStackPicView ()
{
    PAPhysicsAnimation *_space;
    ChipmunkBody *_body;
    ChipmunkShape *_shape;
    
    UIView *_spaceView;

    CGPoint _initialCenter;
    int _touchCount;
    BOOL _nowTouching;
}

- (void)moveOut;

@end

@implementation PAStackPicView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _touchCount = 0;
    }
    return self;
}

- (void)setupPhysicalAnimation
{
    cpFloat mass = 3.0;
    cpFloat width = self.frame.size.width;
    cpFloat height = self.frame.size.height;

    _space = [[PAPhysicsAnimation alloc] init];
    
    _body = [ChipmunkBody bodyWithMass:mass andMoment:cpMomentForBox(mass, width, height)];
    _body.pos = self.center;
    [_space add:_body];
    
    _shape = [ChipmunkPolyShape boxWithBody:_body width:width height:height];
    _shape.elasticity = 0.0;
    _shape.friction = 1.7;
    [_space add:_shape];
    
    [_space startAnimation];
    
    [_space handleAnimationForBody:_body
                       updateBlock:^(CGPoint center, CGFloat angle) {

                           self.transform = CGAffineTransformRotate(CGAffineTransformIdentity, angle);
                           
                           CGPoint vCenter = (_nowTouching) ? [self.superview convertPoint:center fromView:_spaceView] : center;
                           self.center = vCenter;
                           
                           if (vCenter.y > 1000)
                               [self moveOut];
                           else if (_body.kineticEnergy <= 0.0001 && !_nowTouching)
                               [_space stopAnimation], _space = nil, _body = nil, _shape = nil;
                       }];
}

- (CGPoint)offsetPoint:(CGPoint)offset
{
    CGPoint offsetPoint = CGPointMake(64 + offset.x, 64 + offset.y);
    
    return offsetPoint;
}

- (void)endTouches
{
    [_delegate stackPicViewRemoveFromSuperview:self];
    _nowTouching = NO;
    
    [_space add:[ChipmunkPivotJoint pivotJointWithBodyA:_space.staticBody bodyB:_body anchr1:[self offsetPoint:cpv(-10, -10)] anchr2:cpv(-10, -10)]];
    [_space add:[ChipmunkPivotJoint pivotJointWithBodyA:_space.staticBody bodyB:_body anchr1:[self offsetPoint:cpv(10, 10)] anchr2:cpv(10, 10)]];
}

- (void)startTouches
{
    [_delegate stackPicViewAddToSuperview:self];
    _nowTouching = YES;
    
    _initialCenter = self.center;
}

- (void)cancelTouch
{
    _touchCount = 0;
}

- (void)stackPicViewDidMovedOut
{
    [_delegate stackPicViewDidMovedOut:self];
}

- (void)moveOut
{
    [_space stopAnimation], _space = nil, _body = nil, _shape = nil;
    
    if ([_delegate respondsToSelector:@selector(stackPicViewDidMovedOut:)])
        [self performSelectorOnMainThread:@selector(stackPicViewDidMovedOut) withObject:nil waitUntilDone:YES];

    [self removeFromSuperview];
}

- (CGFloat)distanceFormPoint:(CGPoint)point1 toPoint:(CGPoint)point2
{
    CGFloat dx = point1.x - point2.x;
    CGFloat dy = point1.y - point2.y;
    return sqrt(dx*dx + dy*dy);
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
{
    if (!_spaceView)
        _spaceView = self.superview;
    
    if (!_space)
    {
        [self setupPhysicalAnimation];
    } else {
        
        @try {
            for (id line in [_space.space constraints])
                [_space.space remove:line];
        }
        @catch (NSException *exception) {
            //
        }
    }
    
    [_space touchesBegan:touches inView:_spaceView];
    
    if (_touchCount == 0)
        [self startTouches];
    _touchCount++;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_space touchesMoved:touches inView:_spaceView];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
{
    CGFloat distance = [self distanceFormPoint:_initialCenter toPoint:self.center];
    
    _touchCount--;
    if (_touchCount == 0)
    {
        if (distance < 40.f && _body.kineticEnergy < 500000.f)
        {
            [self endTouches];
            
            if (distance < 5)
            {
                if ([_delegate respondsToSelector:@selector(stackPicDidTouch:)])
                    [_delegate stackPicDidTouch:self];
            }
        }
    }

    [_space touchesEnded:touches inView:_spaceView];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_space touchesCancelled:touches inView:_spaceView];
}

@end
