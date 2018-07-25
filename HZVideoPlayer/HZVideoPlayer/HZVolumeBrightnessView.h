//
//  HZVolumeBrightnessView.h
//  HZVideoPlayer
//
//  Created by huangzhenyu on 2018/7/24.
//  Copyright © 2018年 huangzhenyu. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, HZVolumeBrightnessType) {
    HZVolumeBrightnessTypeVolume = 0,
    HZVolumeBrightnessTypeBrightness
};

@interface HZVolumeBrightnessView : UIView
@property (nonatomic, assign) HZVolumeBrightnessType volumeBrightnessType;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UIImageView *iconImageView;

- (void)updateProgress:(CGFloat)progress withVolumeBrightnessType:(HZVolumeBrightnessType)volumeBrightnessType;
@end
