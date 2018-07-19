//
//  HZVideoPlayerCommon.h
//  HZVideoPlayer
//
//  Created by huangzhenyu on 2018/7/18.
//  Copyright © 2018年 huangzhenyu. All rights reserved.
//

#ifndef HZVideoPlayerCommon_h
#define HZVideoPlayerCommon_h
//播放器类型
typedef NS_ENUM(NSUInteger,HZVideoPlayerStyle) {
    HZVideoPlayerStyleTop,
    HZVideoPlayerStyleInner
};

#define kAPPWidth [UIScreen mainScreen].bounds.size.width
#define KAppHeight [UIScreen mainScreen].bounds.size.height
#define iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)
//状态栏高度，iphoneX->44 其他 20
#define kStatusBar_Height [UIApplication sharedApplication].statusBarFrame.size.height
//底部安全距离 iphoneX->34 其他 0
#define kBottomSafeHeight (iPhoneX?34.0f:0.0f)
//横竖屏切换动画时长
#define kRotateAnimationDuration 0.2f

// 图片路径
#define HZPlayerSrc(file)  [@"HZVideoPlayer.bundle" stringByAppendingPathComponent:file]
#define HZPlayerImage(file)     [UIImage imageNamed:HZPlayerSrc(file)]

#endif /* HZVideoPlayerCommon_h */
