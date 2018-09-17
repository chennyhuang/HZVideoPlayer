//
//  HZVideoPlayer.h
//  HZVideoPlayer
//
//  Created by huangzhenyu on 2018/7/17.
//  Copyright © 2018年 huangzhenyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HZVideoPlayerCommon.h"
#import "HZPlayerView.h"

@interface HZVideoPlayer : UIView
@property (nonatomic,strong) HZPlayerView *playerView;
/**播放器类型,默认HZVideoPlayerStyleInner（初始化播放器时设置）*/
@property (nonatomic,assign) HZVideoPlayerStyle playerStyle;
/**是否自动播放,默认YES（初始化播放器时设置）*/
@property (nonatomic,assign) BOOL autoPlay;
/**视频url（初始化播放器时设置，支持本地和在线视频）*/
@property (nonatomic, strong) NSURL *videoUrl;
/**是否能够响应横竖屏旋转,默认YES(播放过程中可动态设置)*/
@property (nonatomic,assign) BOOL enableAutoRotate;
/**是否能调节亮度声音（默认YES）*/
@property (nonatomic,assign) BOOL enableVolumLightProgress;
/**配图地址*/
@property (nonatomic,strong) NSURL *coverImageUrl;

- (void)stop;
- (void)pause;
- (void)play;

- (void)startPlay;

@property (nonatomic,copy) void(^playPauseClick)(UIButton *button);
@end
