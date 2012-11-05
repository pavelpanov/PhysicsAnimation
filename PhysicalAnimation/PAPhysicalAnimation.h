//
//  PAPhysicalAnimation.h
//  WeHeartPics
//
//  Created by Pavel Panov on 7/17/12.
//  Copyright (c) 2012 WeHeartPics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjectiveChipmunk.h"

@protocol WPPhysicalAnimationUpdate;

@interface PAPhysicalAnimation : NSObject
{
    __weak id<WPPhysicalAnimationUpdate> _animationUpdate;
}

@property (nonatomic, readonly) ChipmunkSpace *space;
@property (nonatomic, readonly) ChipmunkBody *staticBody;

@property (nonatomic, weak) id<WPPhysicalAnimationUpdate> animationUpdate;

- (void)startAnimation;
- (void)stopAnmation;

- (id)add:(NSObject<ChipmunkObject> *)obj;
- (id)remove:(NSObject<ChipmunkObject> *)obj;

- (void)touchesBegan:(NSSet *)touches inView:(UIView *)view;
- (void)touchesMoved:(NSSet *)touches inView:(UIView *)view;
- (void)touchesEnded:(NSSet *)touches inView:(UIView *)view;
- (void)touchesCancelled:(NSSet *)touches inView:(UIView *)view;

@end


@protocol WPPhysicalAnimationUpdate <NSObject>

- (void)updateBody:(ChipmunkBody *)body
            center:(CGPoint)newCenter
             angle:(CGFloat)newAngle;

@end


