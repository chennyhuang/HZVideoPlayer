//
//  HZForwardBackwardView.m
//  HZVideoPlayer
//
//  Created by huangzhenyu on 2018/7/24.
//  Copyright © 2018年 huangzhenyu. All rights reserved.
//

#import "HZForwardBackwardView.h"
@interface HZForwardBackwardView()
@property (nonatomic,strong) UILabel *timeLabel;
@property (nonatomic, strong) UIProgressView *progressView;
@end

@implementation HZForwardBackwardView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.timeLabel];
        [self addSubview:self.progressView];
        self.clipsToBounds = NO;
        [self hideself];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat viewW = self.frame.size.width;
    CGFloat timeLabelH = 40;
    self.timeLabel.frame = CGRectMake(-viewW*0.5, 0, viewW*2, timeLabelH);
    self.progressView.frame = CGRectMake(0, timeLabelH + 15, viewW, 2);
}

- (void)updateTime:(NSTimeInterval)sumTime totalTime:(NSTimeInterval)totalTime{
    CGFloat progress = sumTime/totalTime;
    if (progress >= 1) {
        progress = 1;
    } else if (progress <= 0) {
        progress = 0;
    }
    NSString *sumTimeStr = [self getTime:sumTime];
    NSString *totalTimeStr = [self getTime:totalTime];
    
    NSString *normalString = [NSString stringWithFormat:@"%@/%@",sumTimeStr,totalTimeStr];
    NSMutableAttributedString *timeString = [[NSMutableAttributedString alloc] initWithString:normalString];
    [timeString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, sumTimeStr.length)];
    
    [timeString addAttribute:NSForegroundColorAttributeName value:[[UIColor whiteColor] colorWithAlphaComponent:0.6] range:NSMakeRange(sumTimeStr.length+1, totalTimeStr.length)];
    
    self.timeLabel.attributedText = timeString;
    
    self.hidden = NO;
    self.progressView.progress = progress;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideself) object:nil];
    [self performSelector:@selector(hideself) withObject:nil afterDelay:1.0];
}

- (void)hideself{
    self.hidden = YES;
}

//将秒数换算成具体时长
- (NSString *)getTime:(NSInteger)second
{
    NSString *time;
    if (second < 60) {
        time = [NSString stringWithFormat:@"00:%02ld",(long)second];
    } else {
        if (second < 3600) {
            time = [NSString stringWithFormat:@"%02ld:%02ld",second/60,second%60];
        } else {
            
            time = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",second/3600,(second-second/3600*3600)/60,second%60];
        }
    }
    return time;
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

- (UILabel *)timeLabel{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.font = [UIFont systemFontOfSize:33];
    }
    return _timeLabel;
}


@end
