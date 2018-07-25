//
//  HZVideoPlayer.h
//  HZVideoPlayer
//
//  Created by huangzhenyu on 2018/7/17.
//  Copyright © 2018年 huangzhenyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HZVideoPlayerCommon.h"

@interface HZVideoPlayer : UIView
/**播放器类型,默认HZVideoPlayerStyleTop（初始化播放器时设置）*/
@property (nonatomic,assign) HZVideoPlayerStyle playerStyle;
/**是否自动播放,默认YES（初始化播放器时设置）*/
@property (nonatomic,assign) BOOL autoPlay;
/**视频url（初始化播放器时设置，支持本地和在线视频）*/
@property (nonatomic, strong) NSURL *url;
/**是否能够响应横竖屏旋转,默认YES(播放过程中可动态设置)*/
@property (nonatomic,assign) BOOL enableAutoRotate;
/**封面图(播放过程中可动态设置)*/
@property (nonatomic, strong) UIImageView *coverImageView;
/**播放（播放过程中可外部触发）*/
- (void)play;
/**暂停（播放过程中可外部触发）*/
- (void)pause;
/**停止（播放过程中可外部触发）*/
- (void)stop;
@end
