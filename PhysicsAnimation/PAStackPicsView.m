//
//  PAStackPicsView.m
//  WeHeartPics
//
//  Created by admin on 12/23/11.
//  Copyright (c) 2011 WeHeartPics. All rights reserved.
//

#import "PAStackPicsView.h"

CGFloat picRotateAngle = 1.5f;

@interface PAStackPicsView ()
{
    NSInteger _stackPicsCount;
    NSInteger _lastTag;
}

- (void)loadPics;
- (void)layoutPicsAnimated:(BOOL)animated;

@end

@implementation PAStackPicsView

@synthesize pics = _pics;

- (void)setPics:(NSArray *)pics
{
    _pics = pics;
    [self loadPics];
}

- (void)loadPics
{
    for (UIView *view in [self subviews])
        [view removeFromSuperview];
    
    [self layoutPicsAnimated:NO];
}

- (void)layoutPicsAnimated:(BOOL)animated;
{
    NSInteger subviewsCount = [[self subviews] count];
    
    if (subviewsCount > 0)
    {
        for (UIView *view in [self subviews])
            _lastTag = MAX(_lastTag, view.tag);
    } else {
        _lastTag = -1;
        _stackPicsCount = 3;
    }
    
    for (int i = _lastTag + 1; i < MIN(_lastTag + 1 + (_stackPicsCount - subviewsCount), [_pics count]); i++)
    {
        PAStackPicView *picView = [[[UINib nibWithNibName:@"PAStackPicView" bundle:nil] instantiateWithOwner:nil options:nil] objectAtIndex:0];
        picView.delegate = self;
        picView.borderView.image = [UIImage imageNamed:[NSString stringWithFormat:@"stackpic-frame-%d.png", i % 3]];
        picView.imageView.userInteractionEnabled = NO;
        picView.imageView.backgroundColor = [UIColor whiteColor];
        picView.imageView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, -(i % 3) *  M_PI * (picRotateAngle / 180.f));
        picView.tag = i;
        picView.imageView.image = [UIImage imageNamed:[_pics objectAtIndex:i]];
        [self insertSubview:picView atIndex:0];

        if (_lastTag == -1 && animated)
        {
            picView.center = CGPointMake(CGRectGetWidth(self.frame) / 2 - 320,
                                         CGRectGetHeight(self.frame) / 2 - 480);
            
            [UIView animateWithDuration:0.3
                                  delay:0.1 * (MIN(_stackPicsCount, [_pics count]) - i) 
                                options:UIViewAnimationOptionAllowUserInteraction
                             animations:^{
                                 picView.center = CGPointMake(CGRectGetWidth(self.frame) / 2,
                                                              CGRectGetHeight(self.frame) / 2);
                             }
                             completion:^(BOOL finished) {
                                 ;
                             }
             ];
        } else {
            picView.center = CGPointMake(CGRectGetWidth(self.frame) / 2,
                                         CGRectGetHeight(self.frame) / 2);
        }
    }
}

#pragma mark WPStackPicViewDelegate

- (void)stackPicViewWillMove:(PAStackPicView *)stackPicView
{
    int indexOfObject = [self.subviews indexOfObject:stackPicView];
    int nextIndexOfObject = indexOfObject - 1;
    
    if (nextIndexOfObject >= 0 && nextIndexOfObject < [self.subviews count])
    {
        PAStackPicView *picView = [self.subviews objectAtIndex:nextIndexOfObject];
        if (!picView.imageView.image) {
            picView.imageView.image = [UIImage imageNamed:[_pics objectAtIndex:picView.tag]];
        }
    }
    
    _stackPicsCount = MAX(_stackPicsCount, [self.subviews count] + 1);
    
    [self layoutPicsAnimated:NO];    
}

- (void)stackPicViewDidMovedOut:(PAStackPicView *)stackPicView
{
    _stackPicsCount = 3;
    [self layoutPicsAnimated:YES];    
}

- (void)stackPicViewRemoveFromSuperview:(PAStackPicView *)stackPicView
{
    if (stackPicView.superview != self)
    {
        CGPoint center = [self convertPoint:stackPicView.center fromView:stackPicView.superview];
        [self addSubview:stackPicView];
        stackPicView.center = center;
    }
}

- (void)stackPicViewAddToSuperview:(PAStackPicView *)stackPicView
{
    if (stackPicView.superview != self.superview)
    {
        [self stackPicViewWillMove:stackPicView];
        
        CGPoint center = [self.superview convertPoint:stackPicView.center fromView:stackPicView.superview];
        [self.superview addSubview:stackPicView];
        stackPicView.center = center;
    }
    
    [self.superview bringSubviewToFront:stackPicView];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
