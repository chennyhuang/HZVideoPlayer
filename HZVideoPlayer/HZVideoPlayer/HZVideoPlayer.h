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
@property (nonatomic,assign) HZVideoPlayerStyle playerStyle;
/// 封面图
@property (nonatomic, strong) UIImageView *coverImageView;

@end
