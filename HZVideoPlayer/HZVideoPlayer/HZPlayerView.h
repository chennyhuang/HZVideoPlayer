//
//  HZPlayerView.h
//  HZVideoPlayer
//
//  Created by huangzhenyu on 2018/7/18.
//  Copyright © 2018年 huangzhenyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger,HZVideoFillMode){
    HZVideoFillModeResize = 0,       //拉伸占满整个播放器，不按原比例拉伸
    HZVideoFillModeResizeAspect,     //按原视频比例显示，是竖屏的就显示出竖屏的，两边留黑
    HZVideoFillModeResizeAspectFill, //按照原比例拉伸占满整个播放器，但视频内容超出部分会被剪切
};

@interface HZPlayerView : UIView
/**拉伸方式，默认全屏填充*/
@property (nonatomic, assign) HZVideoFillMode videoFillMode;
/**视频url*/
@property (nonatomic, strong) NSURL *url;

@end
