//
//  HZPlayerView.h
//  HZVideoPlayer
//
//  Created by huangzhenyu on 2018/7/18.
//  Copyright © 2018年 huangzhenyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
// 播放器的几种状态
typedef NS_ENUM(NSInteger, HZPlayerState) {
    HZPlayerStateFailed,     // 播放失败
    HZPlayerStateBuffering,  // 缓冲中
    HZPlayerStatePlaying,    // 播放中
    HZPlayerStatePause,      //暂停中
    HZPlayerStateDone        //播放完成
};

typedef NS_ENUM(NSInteger, HZPlayerScalingMode) {
    HZPlayerScalingModeNone = 0,       // No scaling.
    HZPlayerScalingModeAspectFit,  // Uniform scale until one dimension fits.
    HZPlayerScalingModeAspectFill, // Uniform scale until the movie fills the visible bounds. One dimension may have clipped contents.
    HZPlayerScalingModeFill        // Non-uniform scale. Both render dimensions will exactly match the visible bounds.
};

typedef NS_ENUM(NSInteger, HZPlayerOrientation) {
    HZPlayerOrientationPortrait = 0, //竖直（正常方向，非横屏）
    HZPlayerOrientationLandScape //横屏
};

@interface HZPlayerView : UIView
/**拉伸方式，默认全屏填充*/
@property (nonatomic, assign) HZPlayerScalingMode scalingMode;
/**视频url*/
@property (nonatomic, strong) NSURL *videoUrl;
/**播放器当前的方向*/
@property (nonatomic, assign) HZPlayerOrientation playerOrientation;
/**播放器播放状态*/
@property (nonatomic,assign) HZPlayerState playerState;
/**是否能够响应横竖屏旋转,默认YES(播放过程中可动态设置)*/
@property (nonatomic,assign) BOOL enableAutoRotate;

@property (nonatomic,assign) BOOL enableVolumLightProgress;

@property (nonatomic,copy) void(^rotateToPortrait)(void);
@property (nonatomic,copy) void(^rotateToLandScape)(void);
/**播放结束*/
@property (nonatomic,copy) void(^playEnd)(void);
/**播放暂停按钮点击回调*/
@property (nonatomic,copy) void(^playPauseClick)(UIButton *button);
- (void)rotateBeginHideItems;
- (void)rotateEndShowItems;
/**播放或暂停按钮*/
@property (nonatomic, strong) UIButton *playOrPauseBtn;
/**播放*/
- (void)play;
/**暂停*/
- (void)pause;
/**停止*/
- (void)stop;
@end
