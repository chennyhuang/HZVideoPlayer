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
    HZLoadingTypeKeep = 0,
    HZLoadingTypeFadeOut,
};

@interface HZLoadingView : UIView

/// default is HZLoadingType_Keep.
@property (nonatomic, assign) HZLoadingType animType;

/// default is whiteColor.
@property (nonatomic, strong, null_resettable) UIColor *lineColor;

/// default is 1.
@property (nonatomic, assign) double speed;

/// anima state
@property (nonatomic, assign, readonly, getter=isAnimating) BOOL animating;

/// begin anim
- (void)start;

/// stop anim
- (void)stop;

@end

NS_ASSUME_NONNULL_END
