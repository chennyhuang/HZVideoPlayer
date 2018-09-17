//
//  HZVideoPlayer.m
//  HZVideoPlayer
//
//  Created by huangzhenyu on 2018/7/17.
//  Copyright © 2018年 huangzhenyu. All rights reserved.
//

#import "HZVideoPlayer.h"
#import "UIImageView+WebCache.h"
@interface HZVideoPlayer()
@property (nonatomic,assign) CGRect selfOriginRect;//自身初始frame
@property (nonatomic,assign) CGRect containerOriginRect;
@property (nonatomic,assign) UIStatusBarStyle originStatusBarStyle;//记录状态栏初始style
@property (nonatomic,strong) UIWindow *keyWindow;

@property (nonatomic,strong) UIView *statusView;
@property (nonatomic,strong) UIButton *playButton;//播放暂停按钮
@property (nonatomic,strong) UIView *containerView;//放置播放界面，播放控制界面
/**封面图*/
@property (nonatomic, strong) UIImageView *coverImageView;

@end

@implementation HZVideoPlayer
- (void)dealloc{
    NSLog(@"放播放器的view 销毁");
    [[UIApplication sharedApplication] setStatusBarStyle:self.originStatusBarStyle];
    [self stop];
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initUI];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self initFrame];
}

- (void)didMoveToSuperview{
    [super didMoveToSuperview];
    [self initFrame];
    if (self.autoPlay && ([[self.videoUrl absoluteString] length] != 0)) {
        [self addPlayer];
    }
}

#pragma mark getter setter
- (UIButton *)playButton{
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton setImage:HZPlayerImage(@"HZPlayer_pause") forState:UIControlStateNormal];
        [_playButton addTarget:self action:@selector(startPlay) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playButton;
}

- (void)setEnableVolumLightProgress:(BOOL)enableVolumLightProgress{
    _enableVolumLightProgress = enableVolumLightProgress;
    _playerView.enableVolumLightProgress = _enableVolumLightProgress;
}


- (void)setPlayerStyle:(HZVideoPlayerStyle)playerStyle{
    _playerStyle = playerStyle;
    if (self.playerStyle == HZVideoPlayerStyleTop) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    } else {
        [[UIApplication sharedApplication] setStatusBarStyle:self.originStatusBarStyle];
    }
}

- (UIWindow *)keyWindow{
    return [UIApplication sharedApplication].keyWindow;
}

- (UIView *)containerView{
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
        _containerView.backgroundColor = [UIColor blackColor];
    }
    return _containerView;
}

- (UIView *)statusView{
    if (!_statusView) {
        _statusView = [[UIView alloc] init];
    }
    return _statusView;
}

- (UIImageView *)coverImageView{
    if (!_coverImageView) {
        _coverImageView = [[UIImageView alloc] init];
        _coverImageView.userInteractionEnabled = YES;
        _coverImageView.contentMode = UIViewContentModeScaleAspectFit;
        _coverImageView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    }
    return _coverImageView;
}

- (void)setCoverImageUrl:(NSURL *)coverImageUrl{
    if (!coverImageUrl || ([[coverImageUrl absoluteString] length] == 0)) {
        return;
    }
    _coverImageUrl = coverImageUrl;
    [self.coverImageView sd_setImageWithURL:coverImageUrl];
}

#pragma mark private methods
- (void)initUI{
    //默认自动播放
    self.autoPlay = NO;
    //默认可以横竖屏旋转
    self.enableAutoRotate = YES;
    //设置播放器默认样式
    self.playerStyle = HZVideoPlayerStyleInner;
    self.enableVolumLightProgress = YES;
    
    self.originStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.statusView];
    [self addSubview:self.coverImageView];
    [self.coverImageView addSubview:self.playButton];
    
    self.statusView.backgroundColor = [UIColor blackColor];
    if (self.playerStyle == HZVideoPlayerStyleTop) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
}

- (void)initFrame{
    CGFloat playerX = self.frame.origin.x;
    CGFloat playerY = self.frame.origin.y;
    CGFloat playerW = self.frame.size.width;
    CGFloat playerH = self.frame.size.height;
    
    CGFloat statusViewH = 0;
    self.frame = CGRectMake(playerX, playerY, playerW, playerH);
    self.selfOriginRect = self.frame;
    self.statusView.frame = CGRectMake(0, 0, playerW, statusViewH);
    self.coverImageView.frame = CGRectMake(0, statusViewH, playerW, playerH - statusViewH);
    self.playButton.frame = CGRectMake((self.coverImageView.frame.size.width - 100)*0.5, (self.coverImageView.frame.size.height - 100)*0.5, 100, 100);
}

- (void)addPlayer{
    //获取播放器相对于 superview 的坐标
    self.containerOriginRect = [self convertRect:self.coverImageView.frame toView:self.superview];
    NSLog(@"%@",NSStringFromCGRect(self.containerOriginRect));
    //添加黑色遮罩
    self.containerView.frame = self.containerOriginRect;
    self.containerView.hidden = NO;
    [self.superview addSubview:self.containerView];
    
    if (_playerView) {
        [_playerView stop];
        [_playerView removeFromSuperview];
        _playerView = nil;
    }
    //添加播放器
    self.playerView = [[HZPlayerView alloc] init];
    self.playerView.enableVolumLightProgress = self.enableVolumLightProgress;
    self.playerView.hidden = YES;
    self.playerView.frame = self.containerOriginRect;
    self.playerView.playPauseClick = self.playPauseClick;
    [self.superview addSubview:self.playerView];
    self.playerView.videoUrl = self.videoUrl;
    [self pause];
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5/*延迟执行时间*/ * NSEC_PER_SEC));
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        [self play];
        self.playerView.hidden = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeviceOrientationChange) name:UIDeviceOrientationDidChangeNotification object:nil];
    });
    
    @weakify(self);
    self.playerView.rotateToPortrait = ^{
        @strongify(self);
        [self rotateToPortrait:nil];
    };
    
    self.playerView.rotateToLandScape = ^{
        @strongify(self);
        [self rotateToLandScape:nil];
    };
    
    self.playerView.playEnd = ^{
        @strongify(self);
        [self rotateToPortrait:^{
            [self stop];
            if (self.playerView) {
                self.playerView = nil;
            }
            [self.containerView removeFromSuperview];
            if (self.containerView) {
                self.containerView = nil;
            }
        }];
    };
    
    
}

- (void)startPlay{
    [self addPlayer];
}

#pragma mark orientation
-(void)onDeviceOrientationChange
{
    if (!self.enableAutoRotate) {
        return;
    }
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(orientation)) {
        [self rotateToLandScape:nil];
    } else if (orientation==UIDeviceOrientationPortrait){
        [self rotateToPortrait:nil];
    }
}

- (void)rotateToPortrait:(void(^)(void))completion{
    CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
    self.keyWindow.windowLevel = UIWindowLevelNormal;//展示状态栏
    self.containerView.hidden = YES;
    self.playerView.playerOrientation = HZPlayerOrientationPortrait;
    [self.playerView rotateBeginHideItems];
    //竖屏时候，再将containerView playerView 移到superView上面
    [self.superview addSubview:self.containerView];
    [self.superview addSubview:self.playerView];
    self.playerView.userInteractionEnabled = NO;
    [UIView animateWithDuration:duration delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.containerView.transform = CGAffineTransformIdentity;
        self.playerView.transform = CGAffineTransformIdentity;
        
        self.containerView.frame = self.containerOriginRect;
        self.playerView.frame = self.containerOriginRect;
    } completion:^(BOOL finished) {
        [self.playerView rotateEndShowItems];
        self.playerView.userInteractionEnabled = YES;
        if (completion) {
            completion();
        }
    }];
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)rotateToLandScape:(void(^)(void))completion{
    CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    self.keyWindow.windowLevel = UIWindowLevelStatusBar+10.0f;//隐藏状态栏
    self.containerView.hidden = NO;
    self.playerView.playerOrientation = HZPlayerOrientationLandScape;
    [self.playerView rotateBeginHideItems];
    
    //横屏时候将containerView playerView 移到keyWindow上，解决有热点打开的情况下，左侧20的空隙BUG
    [self.keyWindow addSubview:self.containerView];
    [self.keyWindow addSubview:self.playerView];
    self.playerView.userInteractionEnabled = NO;
    [UIView animateWithDuration:duration delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.containerView.transform = (orientation==UIDeviceOrientationLandscapeRight)?CGAffineTransformMakeRotation(-M_PI/2):CGAffineTransformMakeRotation(M_PI/2);
        self.playerView.transform = (orientation==UIDeviceOrientationLandscapeRight)?CGAffineTransformMakeRotation(-M_PI/2):CGAffineTransformMakeRotation(M_PI/2);
        self.containerView.frame = CGRectMake(0, 0, kAPPWidth, KAppHeight);
        if (iPhoneX) {
            self.playerView.frame = CGRectMake(0, kNormalStatusBar_Height, kAPPWidth, KAppHeight - kNormalStatusBar_Height - kBottomSafeHeight);
        } else {
            self.playerView.frame = CGRectMake(0, 0, kAPPWidth, KAppHeight);
        }
    } completion:^(BOOL finished) {
        [self.playerView rotateEndShowItems];
        self.playerView.userInteractionEnabled = YES;
        if (completion) {
            completion();
        }
    }];
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark public methods
- (void)pause{
    if (self.playerView) {
        if (self.playerView.playerState == HZPlayerStateFailed) {
            return;
        }
        self.playerView.playOrPauseBtn.selected = YES;
        [self.playerView pause];
    }
}

- (void)play{
    if (self.playerView) {
        if (self.playerView.playerState == HZPlayerStateFailed) {
            return;
        }
        self.playerView.playOrPauseBtn.selected = NO;
        [self.playerView play];
    }
}

- (void)stop{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_playerView) {
        [_playerView stop];
        _playerView = nil;
    }
    [_containerView removeFromSuperview];
    _containerView = nil;
}
@end
