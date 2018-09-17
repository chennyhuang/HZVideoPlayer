//
//  HZLoadingView.h
//  HZVideoPlayer
//
//  Created by huangzhenyu on 2018/7/22.
//  Copyright © 2018年 huangzhenyu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, HZLoadingType) {
    HZLoadingTypeKeep,
    HZLoadingTypeFadeOut,
};

@interface HZLoadingView : UIView

/// default is HZLoadingTypeKeep.
@property (nonatomic, assign) HZLoadingType animType;

/// default is whiteColor.
@property (nonatomic, strong, null_resettable) UIColor *lineColor;

/// Sets the line width of the spinner's circle.
@property (nonatomic) CGFloat lineWidth;

/// Sets whether the view is hidden when not animating.
@property (nonatomic) BOOL hidesWhenStopped;

/// Property indicating the duration of the animation, default is 1.5s.
@property (nonatomic, readwrite) NSTimeInterval duration;

/// anima state
@property (nonatomic, assign, readonly, getter=isAnimating) BOOL animating;

/**
 *  Starts animation of the spinner.
 */
- (void)startAnimating;

/**
 *  Stops animation of the spinnner.
 */
- (void)stopAnimating;

@end

NS_ASSUME_NONNULL_END
