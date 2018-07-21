//
//  HZPlayerView.h
//  HZVideoPlayer
//
//  Created by huangzhenyu on 2018/7/18.
//  Copyright © 2018年 huangzhenyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger, HZPlayerScalingMode) {
    HZPlayerScalingModeNone,       // No scaling.
    HZPlayerScalingModeAspectFit,  // Uniform scale until one dimension fits.
    HZPlayerScalingModeAspectFill, // Uniform scale until the movie fills the visible bounds. One dimension may have clipped contents.
    HZPlayerScalingModeFill        // Non-uniform scale. Both render dimensions will exactly match the visible bounds.
};

typedef NS_ENUM(NSInteger, HZPlayerOrientation) {
    HZPlayerOrientationPortrait, //竖直（正常方向，非横屏）
    HZPlayerOrientationLandScape //横屏
};

@interface HZPlayerView : UIView
/**拉伸方式，默认全屏填充*/
@property (nonatomic, assign) HZPlayerScalingMode scalingMode;
/**视频url*/
@property (nonatomic, strong) NSURL *url;
/**播放器当前的方向*/
@property (nonatomic, assign) HZPlayerOrientation playerOrientation;
/**播放器是否自动播放(默认 YES 自动播放)*/
@property (nonatomic,assign) BOOL autoPlay;
@property (nonatomic,copy) void(^rotateToPortrait)(void);
@property (nonatomic,copy) void(^rotateToLandScape)(void);
/**播放结束*/
@property (nonatomic,copy) void(^playEnd)(void);
- (void)rotateBeginHideItems;
- (void)rotateEndShowItems;

/**播放*/
- (void)play;
/**暂停*/
- (void)pause;
/**停止*/
- (void)stop;
@end
