//
//  PAPhysicalStackPicView.h
//  WeHeartPics
//
//  Created by Pavel Panov on 7/17/12.
//  Copyright (c) 2012 WeHeartPics. All rights reserved.
//

#import "PAStackPicView.h"
#import "PAPhysicalAnimation.h"

#import "ChipmunkBody.h"

@class PAStackPicsView;

@protocol WPStackPicViewDelegate;

@interface PAStackPicView : UIView
{
    __weak id<WPStackPicViewDelegate> _delegate;
}

@property (weak) id<WPStackPicViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *borderView;

@end


@protocol WPStackPicViewDelegate <NSObject>

@optional
- (void)stackPicDidTouch:(PAStackPicView *)stackPicView;
- (void)stackPicViewWillMove:(PAStackPicView *)stackPicView;
- (void)stackPicViewDidMovedOut:(PAStackPicView *)stackPicView;

- (void)stackPicViewRemoveFromSuperview:(PAStackPicView *)stackPicView;
- (void)stackPicViewAddToSuperview:(PAStackPicView *)stackPicView;

@end