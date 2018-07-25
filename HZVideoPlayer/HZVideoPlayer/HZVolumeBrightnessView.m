//
//  HZVolumeBrightnessView.m
//  HZVideoPlayer
//
//  Created by huangzhenyu on 2018/7/24.
//  Copyright © 2018年 huangzhenyu. All rights reserved.
//

#import "HZVolumeBrightnessView.h"
#import "HZVideoPlayerCommon.h"

@interface HZVolumeBrightnessView()

@end

@implementation HZVolumeBrightnessView
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
        [self addSubview:self.iconImageView];
        [self addSubview:self.progressView];
        self.layer.cornerRadius = 4;
        self.layer.masksToBounds = YES;
        [self hideself];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat viewW = self.frame.size.width;
    CGFloat viewH = self.frame.size.height;
    self.layer.cornerRadius = self.frame.size.height * 0.5;
    CGFloat imageX = 20;
    CGFloat imageWH = 14;
    self.iconImageView.frame = CGRectMake(imageX, (viewH - imageWH)*0.5, imageWH, imageWH);
    CGFloat leftEdge = 10;
    CGFloat rightEdge = 20;
    CGFloat progressH = 1;
    self.progressView.frame = CGRectMake(imageWH + leftEdge + imageX, (viewH - progressH)*0.5, viewW - imageWH - leftEdge - rightEdge - imageX, progressH);
}

- (void)updateProgress:(CGFloat)progress withVolumeBrightnessType:(HZVolumeBrightnessType)volumeBrightnessType{
    if (progress >= 1) {
        progress = 1;
    } else if (progress <= 0) {
        progress = 0;
    }
    self.progressView.progress = progress;
    self.volumeBrightnessType = volumeBrightnessType;
    if (volumeBrightnessType == HZVolumeBrightnessTypeVolume) {
        if (progress == 0) {
            self.iconImageView.image = HZPlayerImage(@"HZPlayer_volume_close");
        } else if(progress <= 0.4) {
            self.iconImageView.image = HZPlayerImage(@"HZPlayer_volume_low");
        } else {
            self.iconImageView.image = HZPlayerImage(@"HZPlayer_volume_high");
        }
    }
    self.hidden = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideself) object:nil];
    [self performSelector:@selector(hideself) withObject:nil afterDelay:1.0];
}

- (void)hideself{
    self.hidden = YES;
}

#pragma mark getter setter
- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] init];
        _progressView.progressTintColor = [UIColor whiteColor];
        _progressView.trackTintColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.4];;
    }
    return _progressView;
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [UIImageView new];
    }
    return _iconImageView;
}

- (void)setVolumeBrightnessType:(HZVolumeBrightnessType)volumeBrightnessType{
    _volumeBrightnessType = volumeBrightnessType;
    if (volumeBrightnessType == HZVolumeBrightnessTypeVolume) {
//        self.iconImageView.image = HZPlayerImage(@"HZPlayer_volume");
    } else {
        self.iconImageView.image = HZPlayerImage(@"HZPlayer_brightness");
    }
}

@end
