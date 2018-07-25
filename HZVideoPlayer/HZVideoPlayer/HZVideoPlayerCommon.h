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
#define kNormalStatusBar_Height (iPhoneX?44.0f:20.0f)
//底部安全距离 iphoneX->34 其他 0
#define kBottomSafeHeight (iPhoneX?34.0f:0.0f)

// 图片路径
#define HZPlayerSrc(file)  [@"HZVideoPlayer.bundle" stringByAppendingPathComponent:file]
#define HZPlayerImage(file)     [UIImage imageNamed:HZPlayerSrc(file)]

#ifndef weakify
#if DEBUG
#if __has_feature(objc_arc)
#define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
#endif
#else
#if __has_feature(objc_arc)
#define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
#endif
#endif
#endif

#ifndef strongify
#if DEBUG
#if __has_feature(objc_arc)
#define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
#endif
#else
#if __has_feature(objc_arc)
#define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
#endif
#endif
#endif

#endif /* HZVideoPlayerCommon_h */
