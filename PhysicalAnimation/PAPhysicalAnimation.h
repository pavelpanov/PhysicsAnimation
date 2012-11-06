//
//  PAPhysicalAnimation.h
//  WeHeartPics
//
//  Created by Pavel Panov on 7/17/12.
//  Copyright (c) 2012 WeHeartPics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjectiveChipmunk.h"

typedef void (^UpdateBlockType)(CGPoint center, CGFloat angle);

@interface PAPhysicalAnimation : NSObject

@property (nonatomic, readonly) ChipmunkSpace *space;
@property (nonatomic, readonly) ChipmunkBody *staticBody;

- (void)startAnimation;
- (void)stopAnimation;

- (void)handleAnimationForBody:(ChipmunkBody *)body
                   updateBlock:(UpdateBlockType)updateBlock;

- (id)add:(NSObject<ChipmunkObject> *)obj;
- (id)remove:(NSObject<ChipmunkObject> *)obj;

- (void)touchesBegan:(NSSet *)touches inView:(UIView *)view;
- (void)touchesMoved:(NSSet *)touches inView:(UIView *)view;
- (void)touchesEnded:(NSSet *)touches inView:(UIView *)view;
- (void)touchesCancelled:(NSSet *)touches inView:(UIView *)view;

@end



