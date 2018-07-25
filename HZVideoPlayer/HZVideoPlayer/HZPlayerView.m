//
//  HZPlayerView.m
//  HZVideoPlayer
//
//  Created by huangzhenyu on 2018/7/18.
//  Copyright © 2018年 huangzhenyu. All rights reserved.
//

#import "HZPlayerView.h"
#import "HZVideoPlayerCommon.h"
#import "HZSliderView.h"
#import "HZPlayerGestureControl.h"
#import "HZLoadingView.h"
#import "HZGCDTimerManager.h"
#import <MediaPlayer/MediaPlayer.h>
#import "HZVolumeBrightnessView.h"
#import "HZForwardBackwardView.h"

// 播放器的几种状态
typedef NS_ENUM(NSInteger, HZPlayerState) {
    HZPlayerStateFailed,     // 播放失败
    HZPlayerStateBuffering,  // 缓冲中
    HZPlayerStatePlaying,    // 播放中
    HZPlayerStatePause,      //暂停中
    HZPlayerStateDone        //播放完成
};
static NSString *HZPlayerToolBarHideTimer = @"HZPlayerToolBarHideTimer";
@interface HZPlayerView() <HZSliderViewDelegate,HZSliderViewDelegate>{
    id _timeObserver;
    id _itemEndObserver;
}
/**播放器*/
@property (nonatomic, strong) AVPlayer *player;
/**播放器item*/
@property (nonatomic, strong) AVPlayerItem *playerItem;
/**playerLayer*/
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
/**播放器播放状态*/
@property (nonatomic,assign) HZPlayerState playerState;
/**转圈圈*/
@property (nonatomic, strong) HZLoadingView *activity;
/**顶部工具条*/
@property (nonatomic,strong) UIView *topToolView;
/**底部工具条*/
@property (nonatomic,strong) UIView *bottomToolView;
/**加载失败，点击重试按钮*/
@property (nonatomic,strong) UIButton *retryButton;
/**播放或暂停按钮*/
@property (nonatomic, strong) UIButton *playOrPauseBtn;
/**播放的当前时间*/
@property (nonatomic, strong) UILabel *currentTimeLabel;
/**返回按钮*/
@property (nonatomic, strong) UIButton *backBtn;
/**底部播放进度*/
@property (nonatomic, strong) HZSliderView *bottomProgress;
/**滑杆*/
@property (nonatomic, strong) HZSliderView *slider;
/**视频总时间*/
@property (nonatomic, strong) UILabel *totalTimeLabel;
/**全屏按钮*/
@property (nonatomic, strong) UIButton *fullScreenBtn;
/**音量和亮度调节的View*/
@property (nonatomic,strong) HZVolumeBrightnessView *tipView;
/**前进后退view*/
@property (nonatomic,strong) HZForwardBackwardView *timeView;
/**手势控制*/
@property (nonatomic,strong) HZPlayerGestureControl *gestureControl;
/**视频总时长*/
@property (nonatomic, assign) NSTimeInterval totalTime;
/**快进快退后的时间点*/
@property (nonatomic, assign) NSTimeInterval sumTime;
/**屏幕亮度*/
@property (nonatomic,assign) float brightness;
/**音量滑杆*/
@property (nonatomic,strong) UISlider *volumeViewSlider;
/**音量*/
@property (nonatomic,assign) float volume;
/**工具条和播放暂停按钮是否展示*/
@property (nonatomic,assign) BOOL isToolBarShow;
/**标记视频是否可以播放*/
@property (nonatomic,assign) BOOL isPrepareToPlay;
@end

@implementation HZPlayerView
- (void)dealloc{
    [self stop];
    NSLog(@"播放器被销毁了");
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initUI];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat viewW = self.bounds.size.width;
    CGFloat viewH = self.bounds.size.height;
    CGFloat toolBarH = 50;
    self.playerLayer.frame = self.bounds;
    self.topToolView.frame = CGRectMake(0, 0, viewW, toolBarH);
    self.bottomToolView.frame = CGRectMake(0, viewH - toolBarH, viewW, toolBarH);
    CGFloat playPauseBtnWH = 50;
    CGFloat activityWH = 20;
    if (self.playerOrientation == HZPlayerOrientationLandScape) {
        playPauseBtnWH = 60;
//        activityWH = 60;
    }
    self.playOrPauseBtn.frame = CGRectMake((viewW - playPauseBtnWH)*0.5, (viewH - playPauseBtnWH)*0.5, playPauseBtnWH, playPauseBtnWH);
    self.activity.frame = CGRectMake((viewW - activityWH)*0.5, (viewH - activityWH)*0.5, activityWH, activityWH);
    self.bottomProgress.frame = CGRectMake(0, viewH - 2, viewW, 2);
    CGFloat backBtnWH = toolBarH;
    self.backBtn.frame = CGRectMake(10, 0, backBtnWH, backBtnWH);
    //bottomToolView相关
    CGFloat leftSpace = 10;//最左侧间距
    CGFloat rightSpace = 10;//最右侧间距
    CGFloat timeLabelW = 70;
    self.currentTimeLabel.frame = CGRectMake(leftSpace, 0, timeLabelW, toolBarH);
    CGFloat fullBtnWH = toolBarH;
    self.fullScreenBtn.frame = CGRectMake(viewW - fullBtnWH - rightSpace, 0, fullBtnWH, fullBtnWH);
    self.totalTimeLabel.frame = CGRectMake(viewW - fullBtnWH - rightSpace - timeLabelW, 0, timeLabelW, toolBarH);
    self.slider.frame = CGRectMake(CGRectGetMaxX(self.currentTimeLabel.frame), (toolBarH - 30)*0.5, viewW - fullBtnWH - rightSpace - timeLabelW - leftSpace - timeLabelW, 30);
    CGFloat tipViewW = 120;
    CGFloat tipViewH = 30;
    self.tipView.frame = CGRectMake((viewW - tipViewW)*0.5, 30, tipViewW, tipViewH);
    CGFloat timeViewW = 180;
    CGFloat timeViewH = 90;
    self.timeView.frame = CGRectMake((viewW - timeViewW)*0.5, (viewH - timeViewH)*0.5, timeViewW, timeViewH);
    CGFloat retryW = 128;
    CGFloat retryH = 32;
    self.retryButton.frame = CGRectMake((viewW - retryW)*0.5, (viewH - retryH)*0.5, retryW, retryH);
}

- (void)initUI{
    //属性初始化
    self.scalingMode = HZPlayerScalingModeAspectFit;
    self.playerOrientation = HZPlayerOrientationPortrait;
    
    [self addSubview:self.topToolView];
    [self addSubview:self.bottomToolView];
    [self addSubview:self.activity];
    [self addSubview:self.playOrPauseBtn];
    [self addSubview:self.bottomProgress];
    [self addSubview:self.backBtn];
    [self addSubview:self.tipView];
    [self addSubview:self.timeView];
    [self addSubview:self.retryButton];
    
    [self.bottomToolView addSubview:self.currentTimeLabel];
    [self.bottomToolView addSubview:self.totalTimeLabel];
    [self.bottomToolView addSubview:self.slider];
    [self.bottomToolView addSubview:self.fullScreenBtn];
    [self configureVolume];
    //启动默认隐藏工具条
    [self singleTapHideItems];
    //添加事件
    [self.gestureControl addGestureToView:self];
}

#pragma mark getter setter
- (void)setUrl:(NSURL *)url{
    _url = url;
    [self removeObservers];
    [self resetPlayer];
    self.playerItem = [AVPlayerItem playerItemWithAsset:[AVAsset assetWithURL:_url]];
    //创建
    _player = [AVPlayer playerWithPlayerItem:_playerItem];
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    _playerLayer.backgroundColor = [UIColor blackColor].CGColor;
    //放到最下面，防止遮挡
    [self.layer insertSublayer:_playerLayer atIndex:0];
#warning ????????????
    //如果需要减少性能消耗，在视频流暂停的时候，如果不需要使用播放状态可以把这个属性设为关闭
    if (@available(iOS 9.0, *)) {
        _playerItem.canUseNetworkResourcesForLiveStreamingWhilePaused = NO;
    }
    
    if (@available(iOS 10.0, *)) {
        _playerItem.preferredForwardBufferDuration = 1;
        _player.automaticallyWaitsToMinimizeStalling = NO;
    }
    [self addObservers];
}

- (void)setPlayerItem:(AVPlayerItem *)playerItem{
    if (_playerItem == playerItem) {
        return;
    }
    _playerItem = playerItem;
}

- (void)setPlayerState:(HZPlayerState)playerState{
    _playerState = playerState;
    switch (playerState) {
        case HZPlayerStatePause:
            break;
        case HZPlayerStatePlaying:
            if (self.player) {
                [self.activity stop];
            }
            break;
        case HZPlayerStateBuffering:
            if (self.player) {
                [self.activity start];
            }
            break;
        case HZPlayerStateFailed:
            self.retryButton.hidden = NO;
            [self removeObservers];
            [self resetPlayer];
            break;
        case HZPlayerStateDone:
            if (self.playEnd) {
                self.playEnd();
            }
            break;
        default:
            break;
    }
}

- (void)setScalingMode:(HZPlayerScalingMode)scalingMode{
    _scalingMode = scalingMode;
    switch (scalingMode) {
        case HZPlayerScalingModeNone:
            self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
            break;
        case HZPlayerScalingModeAspectFit:
            self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
            break;
        case HZPlayerScalingModeAspectFill:
            self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            break;
        case HZPlayerScalingModeFill:
            self.playerLayer.videoGravity = AVLayerVideoGravityResize;
            break;
        default:
            break;
    }
}

- (HZLoadingView *)activity{
    if (!_activity) {
        _activity = [[HZLoadingView alloc] init];
    }
    return _activity;
}

- (UIView *)topToolView {
    if (!_topToolView) {
        _topToolView = [[UIView alloc] init];

        UIImage *image = HZPlayerImage(@"HZPlayer_top_shadow");
        _topToolView.layer.contents = (id)image.CGImage;
    }
    return _topToolView;
}

- (UIView *)bottomToolView {
    if (!_bottomToolView) {
        _bottomToolView = [[UIView alloc] init];
        UIImage *image = HZPlayerImage(@"HZPlayer_bottom_shadow");
        _bottomToolView.layer.contents = (id)image.CGImage;
    }
    return _bottomToolView;
}

- (UIButton *)retryButton{
    if(!_retryButton){
        _retryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _retryButton.hidden = YES;
//        _retryButton.backgroundColor = [UIColor blackColor];
        _retryButton.layer.borderWidth = 1;
        _retryButton.layer.cornerRadius = 5;
        _retryButton.layer.borderColor = [UIColor whiteColor].CGColor;
        _retryButton.alpha = 0.9;
        _retryButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_retryButton setTitle:@"加载失败，点击重试" forState:UIControlStateNormal];
        [_retryButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_retryButton addTarget:self action:@selector(retry:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _retryButton;
}

- (UIButton *)backBtn {
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backBtn setImage:HZPlayerImage(@"HZPlayer_back") forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

- (UIButton *)playOrPauseBtn {
    if (!_playOrPauseBtn) {
        _playOrPauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playOrPauseBtn setBackgroundImage:HZPlayerImage(@"HZPlayer_play") forState:UIControlStateNormal];
        [_playOrPauseBtn setBackgroundImage:HZPlayerImage(@"HZPlayer_pause") forState:UIControlStateSelected];
        [_playOrPauseBtn addTarget:self action:@selector(playPause:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playOrPauseBtn;
}

- (UILabel *)currentTimeLabel {
    if (!_currentTimeLabel) {
        _currentTimeLabel = [[UILabel alloc] init];
        _currentTimeLabel.textColor = [UIColor whiteColor];
        _currentTimeLabel.font = [UIFont systemFontOfSize:12.0f];
        _currentTimeLabel.textAlignment = NSTextAlignmentCenter;
        _currentTimeLabel.text = @"00:00";
    }
    return _currentTimeLabel;
}

- (HZSliderView *)slider {
    if (!_slider) {
        _slider = [[HZSliderView alloc] init];
        _slider.delegate = self;
        _slider.maximumTrackTintColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.8];
        _slider.bufferTrackTintColor  = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
        _slider.minimumTrackTintColor = [UIColor whiteColor];
        [_slider setThumbImage:HZPlayerImage(@"HZPlayer_slider") forState:UIControlStateNormal];
        _slider.sliderHeight = 2;
    }
    return _slider;
}

- (HZSliderView *)bottomProgress {
    if (!_bottomProgress) {
        _bottomProgress = [[HZSliderView alloc] init];
        _bottomProgress.maximumTrackTintColor = [UIColor clearColor];
        _bottomProgress.minimumTrackTintColor = [UIColor redColor];
        _bottomProgress.bufferTrackTintColor  = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
        _bottomProgress.sliderHeight = 2;
        _bottomProgress.isHideSliderBlock = YES;
    }
    return _bottomProgress;
}

- (UILabel *)totalTimeLabel {
    if (!_totalTimeLabel) {
        _totalTimeLabel = [[UILabel alloc] init];
        _totalTimeLabel.textColor = [UIColor whiteColor];
        _totalTimeLabel.font = [UIFont systemFontOfSize:12.0f];
        _totalTimeLabel.textAlignment = NSTextAlignmentCenter;
        _totalTimeLabel.text = @"00:00";
//        _totalTimeLabel.backgroundColor = [UIColor redColor];
    }
    return _totalTimeLabel;
}

- (UIButton *)fullScreenBtn {
    if (!_fullScreenBtn) {
        _fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fullScreenBtn setImage:HZPlayerImage(@"HZPlayer_fullscreen") forState:UIControlStateNormal];
        [_fullScreenBtn setImage:HZPlayerImage(@"HZPlayer_hideFullscreen") forState:UIControlStateSelected];
        [_fullScreenBtn addTarget:self action:@selector(fullClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fullScreenBtn;
}

- (HZVolumeBrightnessView *)tipView{
    if (!_tipView) {
        _tipView = [[HZVolumeBrightnessView alloc] init];
    }
    return _tipView;
}

- (HZForwardBackwardView *)timeView{
    if (!_timeView) {
        _timeView = [[HZForwardBackwardView alloc] init];
    }
    return _timeView;
}

- (float)brightness{
    return [UIScreen mainScreen].brightness;
}

- (void)setBrightness:(float)brightness{
     brightness = MIN(MAX(0, brightness), 1);
    [UIScreen mainScreen].brightness = brightness;
}

- (float)volume {
    CGFloat volume = self.volumeViewSlider.value;
    if (volume == 0) {
        volume = [[AVAudioSession sharedInstance] outputVolume];
    }
    return volume;
}

- (void)setVolume:(float)volume{
    volume = MIN(MAX(0, volume), 1);
    self.volumeViewSlider.value = volume;
}

- (void)setPlayerOrientation:(HZPlayerOrientation)playerOrientation{
    _playerOrientation = playerOrientation;
    if (playerOrientation == HZPlayerOrientationPortrait) {
        _fullScreenBtn.selected = NO;
    } else {
        _fullScreenBtn.selected = YES;
    }
}

//手势相关处理
- (HZPlayerGestureControl *)gestureControl {
    if (!_gestureControl) {
        _gestureControl = [[HZPlayerGestureControl alloc] init];
        @weakify(self)
        _gestureControl.triggerCondition = ^BOOL(HZPlayerGestureControl * _Nonnull control, HZPlayerGestureType type, UIGestureRecognizer * _Nonnull gesture, UITouch *touch) {
            @strongify(self)
            if(!self.isPrepareToPlay) return NO;
            CGPoint point = [touch locationInView:self];
            if (self.isToolBarShow) {
                BOOL topContains = CGRectContainsPoint(self.topToolView.frame, point);
                BOOL bottomContains = CGRectContainsPoint(self.bottomToolView.frame, point);
                if (self.playerOrientation == HZPlayerOrientationPortrait) {
                    if (bottomContains) {
                        return NO;
                    } else {
                        return YES;
                    }
                } else {
                    if (topContains || bottomContains) {
                        return NO;
                    } else {
                        return YES;
                    }
                }
            } else {
                return YES;
            }
        };
        
        _gestureControl.singleTapped = ^(HZPlayerGestureControl * _Nonnull control) {
            @strongify(self)
//            NSLog(@"singleTapped");
            self.isToolBarShow == YES? [self singleTapHideItems]:[self singleTapShowItems];
        };
        
        _gestureControl.doubleTapped = ^(HZPlayerGestureControl * _Nonnull control) {
            @strongify(self)
        };
        
        _gestureControl.beganPan = ^(HZPlayerGestureControl * _Nonnull control, HZPanDirection direction, HZPanLocation location) {
            @strongify(self)
            if (direction == HZPanDirectionH) {
                self.sumTime = CMTimeGetSeconds(self.player.currentTime);
            }
//            NSLog(@"beganPan");
            [self singleTapHideItems];
        };
        
        _gestureControl.changedPan = ^(HZPlayerGestureControl * _Nonnull control, HZPanDirection direction, HZPanLocation location, CGPoint velocity) {
            @strongify(self)
            if (direction == HZPanDirectionH) {
                //每次滑动需要叠加时间
                self.sumTime += velocity.x / 200;
                NSTimeInterval totalTime = self.totalTime;
                if (totalTime == 0) return;
                if (self.sumTime > totalTime) {
                    self.sumTime = totalTime;
                }
                if (self.sumTime < 0) {
                    self.sumTime = 0;
                }
                //改变播放进度 view的展示
                [self.timeView updateTime:self.sumTime totalTime:self.totalTime];
            } else if(direction == HZPanDirectionV){
                if (location == HZPanLocationLeft) {
                    //调节亮度
                    self.brightness -= (velocity.y) / 10000;
                    [self.tipView updateProgress:self.brightness withVolumeBrightnessType:HZVolumeBrightnessTypeBrightness];
                } else if(location == HZPanLocationRight) {
                    //调节声音
                    self.volume -= (velocity.y) / 10000;
//                    [self.tipView updateProgress:self.volume withVolumeBrightnessType:HZVolumeBrightnessTypeVolume];
                }
            }
            
        };
        
        _gestureControl.endedPan = ^(HZPlayerGestureControl * _Nonnull control, HZPanDirection direction, HZPanLocation location) {
            @strongify(self)
             if (direction == HZPanDirectionH && self.sumTime >= 0 && self.totalTime > 0) {
                 [self sliderChange:self.sumTime/self.totalTime];
                 [self.timeView updateTime:self.sumTime totalTime:self.totalTime];
             }
            [self singleTapHideItems];
            
//            NSLog(@"endedPan");
        };
        
        _gestureControl.pinched = ^(HZPlayerGestureControl * _Nonnull control, float scale) {
            @strongify(self)
//            NSLog(@"pinched");
            if (scale > 1) {
                self.scalingMode = HZPlayerScalingModeAspectFill;
            } else {
                self.scalingMode = HZPlayerScalingModeAspectFit;
            }
        };
    }
    _gestureControl.disableTypes = HZPlayerDisableGestureTypesDoubleTap;
    return _gestureControl;
}

#pragma mark public method
- (void)rotateBeginHideItems{
    self.backBtn.hidden = YES;
    self.topToolView.hidden = YES;
    self.bottomToolView.hidden = YES;
    self.bottomProgress.hidden = YES;
    self.playOrPauseBtn.hidden = YES;
    self.isToolBarShow = NO;
}

- (void)rotateEndShowItems{
    self.bottomProgress.hidden = NO;
}

//暂停
- (void)pause{
    self.playerState = HZPlayerStatePause;
    [self.player pause];
}

//播放
- (void)play{
    if (self.isPrepareToPlay) {
//        NSLog(@"play -- ");
        if (!self.playerItem.isPlaybackLikelyToKeepUp) {
            [self bufferingSomeSecond];
        } else {
//            NSLog(@"播放");
            self.playerState = HZPlayerStatePlaying;
            [self.player play];
        }
    } else {
        self.playerState = HZPlayerStateBuffering;
    }
}

- (void)stop{
    [self removeTimer];
    [self removeObservers];
    [self resetPlayer];
    [self removeFromSuperview];
}


#pragma mark private methods
//获取系统声音
- (void)configureVolume {
    //通过设置 MPVolumeView 的frame,同时将其添加到试图上面，可以隐藏丑陋的系统音量HUD
    MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(-1000, -1000, 100, 100)];
    [self addSubview:volumeView];
    self.volumeViewSlider = nil;
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            self.volumeViewSlider = (UISlider *)view;
            break;
        }
    }
    // 当手机静音按钮打开时，设置应用仍然可以播放声音
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
//    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}

//加载失败，点击重试
- (void)retry:(UIButton *)button{
    button.hidden = YES;
    [self setUrl:_url];
}

#pragma mark - 缓冲较差时候
//卡顿缓冲几秒
- (void)bufferingSomeSecond{
    if (!_player) {
        return;
    }
    // 需要先暂停一小会之后再播放，否则网络状况不好的时候时间在走，声音播放不出来
    [self.player pause];
    self.playerState = HZPlayerStateBuffering;
//    NSLog(@"网络较差，3秒缓冲中 --- ");
    //延迟执行
    [self performSelector:@selector(bufferingSomeSecondEnd)
               withObject:@"Buffering"
               afterDelay:3];
}
//卡顿缓冲结束
- (void)bufferingSomeSecondEnd{
    if (!_player) {
        return;
    }
    // 如果执行了play还是没有播放则说明还没有缓存好，则再次缓存一段时间
    if (!self.playerItem.isPlaybackLikelyToKeepUp) {
        [self bufferingSomeSecond];
    } else {
        if (!self.playOrPauseBtn.selected) {
            [self play];
        } else {
            [self.activity stop];
        }
    }
}

- (void)removeObservers{
    [_playerItem removeObserver:self forKeyPath:@"status"];
    [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [_playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillResignActiveNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:_player.currentItem];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionInterruptionNotification object:nil];
    [_player removeTimeObserver:_timeObserver];
}

- (void)addObservers{
    //APP运行状态通知，将要被挂起
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidEnterBackground:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    // app进入前台
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidEnterPlayground:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerDidEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:_playerItem];
    //线路改变 (插入耳机，麦克风)
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleRouteChange:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:nil];
    //监听中断
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(interruption:)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:nil];
    //监听手机按键音量
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(volumeDidChangeNotification:)
                                                 name:@"AVSystemController_SystemVolumeDidChangeNotification"
                                               object:nil];
    [_playerItem addObserver:self
                  forKeyPath:@"status"
                     options:NSKeyValueObservingOptionNew
                     context:nil];
    [_playerItem addObserver:self
                  forKeyPath:@"loadedTimeRanges"
                     options:NSKeyValueObservingOptionNew
                     context:nil];
    [_playerItem addObserver:self
                  forKeyPath:@"playbackBufferEmpty"
                     options:NSKeyValueObservingOptionNew
                     context:nil];
    CMTime interval = CMTimeMakeWithSeconds(1.0, 1.0);
    @weakify(self)
    _timeObserver = [self.player addPeriodicTimeObserverForInterval:interval queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        @strongify(self)
        if (!self) return;
        //播放器正在在播放中
        if (@available(iOS 10.0, *)) {
            if (self.player.timeControlStatus == AVPlayerTimeControlStatusPlaying){
//                NSLog(@"播放中 --");
                self.playerState = HZPlayerStatePlaying;
                [self playerTimeChange];
            } else if (self.player.timeControlStatus == AVPlayerTimeControlStatusWaitingToPlayAtSpecifiedRate) {
//                NSLog(@"AVPlayerTimeControlStatusWaitingToPlayAtSpecifiedRate");
                self.playerState = HZPlayerStateBuffering;
            } else {
//                NSLog(@"pause -- ");
            }
            
        } else {
            if (self.player.rate == 1) {
//                NSLog(@"播放中");
                self.playerState = HZPlayerStatePlaying;
                [self playerTimeChange];
            } else {
//                NSLog(@"pause -- ");
            }
            
        }
    }];
}

//重置播放器
- (void)resetPlayer{
    if (_playerLayer) {
        [_playerLayer removeFromSuperlayer];
        _playerLayer = nil;
    }
    [_player pause];
    if (_player) {
        _player = nil;
    }
    if (_playerItem) {
        _playerItem = nil;
    }
    self.totalTime = 0;
    self.currentTimeLabel.text = @"00:00";
    self.totalTimeLabel.text = @"00:00";
    self.slider.value = 0;
    self.slider.bufferValue = 0;
    self.bottomProgress.value = 0;
    self.bottomProgress.bufferValue = 0;
}

//视频播放完成
- (void)playerDidEnd:(id)sender{
    self.playerState = HZPlayerStateDone;
}

- (void)seekToTime:(NSTimeInterval)time completionHandler:(void (^ __nullable)(BOOL finished))completionHandler {
    [self.player pause];
    CMTime seekTime = CMTimeMake(time, 1); //kCMTimeZero
//    [_playerItem cancelPendingSeeks];
    //如果需要精准定位，那么把toleranceBefore:和toleranceAfter:的参数都设置为kCMTimeZero即可
    [_player seekToTime:seekTime toleranceBefore:CMTimeMake(1,1) toleranceAfter:CMTimeMake(1,1) completionHandler:completionHandler];
}

- (void)singleTapHideItems{
    [self removeTimer];
    self.isToolBarShow = NO;
    self.topToolView.hidden = YES;
    self.bottomToolView.hidden = YES;
    self.playOrPauseBtn.hidden = YES;
    self.backBtn.hidden = YES;
    self.bottomProgress.hidden = NO;
}

- (void)singleTapShowItems{
    [self addTimer];
    if (self.playerOrientation == HZPlayerOrientationPortrait) {
        self.backBtn.hidden = YES;
        self.topToolView.hidden = YES;
    } else {
        self.backBtn.hidden = NO;
        self.topToolView.hidden = NO;
    }
    self.isToolBarShow = YES;
    
    self.bottomToolView.hidden = NO;
    self.playOrPauseBtn.hidden = NO;
    self.bottomProgress.hidden = YES;
}

- (void)playPause:(UIButton *)button{
//    NSLog(@"playPause");
    if (button.selected) {
        button.selected = NO;
        [self play];
    } else {
        button.selected = YES;
        [self pause];
    }
    [self addTimer];
}

- (void)backClick{
    if (self.rotateToPortrait) {
        self.rotateToPortrait();
    }
}

- (void)fullClick:(UIButton *)button{
    if (self.playerOrientation == HZPlayerOrientationPortrait) {
        if (self.rotateToLandScape) {
            self.rotateToLandScape();
        }
    } else {
        if (self.rotateToPortrait) {
            self.rotateToPortrait();
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([keyPath isEqualToString:@"status"]) {
            if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
//                NSLog(@"准备播放");
                CMTime duration = self.playerItem.duration;
                self.totalTime = CMTimeGetSeconds(duration);//视频总时长
                self.isPrepareToPlay = YES;
                if (!self.playOrPauseBtn.selected) {
                    [self play];
                }
                
                [self playerTimeChange];
            }
            else if (self.player.currentItem.status == AVPlayerItemStatusFailed) {
    //            NSLog(@"播放失败");
                self.playerState = HZPlayerStateFailed;
            }
        } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
//            // 计算缓冲进度
            
        } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
//             当缓冲是空的时候
//            NSLog(@"缓冲中");
            
//            if (self.playerItem.isPlaybackBufferEmpty) {
//                [self playerBufferingBegin];
//                NSLog(@"缓冲为空，缓冲中");
//            } else {
                self.playerState = HZPlayerStateBuffering;
//            }
        } else {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    });
}

- (void)playerTimeChange{
    // 计算缓冲进度
    NSTimeInterval bufferInterval = [self bufferDuration];//缓冲时长
    if (isnan(bufferInterval)) {
        bufferInterval = 0;
    }
    CGFloat currentTime = CMTimeGetSeconds(self.playerItem.currentTime);//当前播放到的时间点
    
    CGFloat bufferPer = bufferInterval/ self.totalTime * 1.0f;
    CGFloat currentPer = currentTime/ self.totalTime * 1.0f;
    if (!self.slider.isdragging) {
        self.slider.bufferValue = bufferPer;
        self.slider.value = currentPer;
        
        self.bottomProgress.bufferValue = bufferPer;
        self.bottomProgress.value = currentPer;
        
        self.currentTimeLabel.text = [self getTime:currentTime];
        self.totalTimeLabel.text = [self getTime:self.totalTime];
    }
}

//计算缓冲进度
- (NSTimeInterval)bufferDuration{
    NSArray *loadedTimeRanges = [[self.player currentItem] loadedTimeRanges];
    CMTimeRange timeRange     = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds        = CMTimeGetSeconds(timeRange.start);
    float durationSeconds     = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result     = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
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

- (void)appDidEnterBackground:(NSNotification *)note{
//    NSLog(@"进入后台");
//    self.isBackground = YES;
    [self pause];
}

- (void)appDidEnterPlayground:(NSNotification *)note{
//    NSLog(@"进入前台");
//    self.isBackground = NO;
    [self.activity stop];
    if (!self.playOrPauseBtn.selected) {
        [self play];
    } else {
        [self pause];
    }
}

- (void)handleRouteChange:(NSNotification *)notification{

    NSDictionary *info = notification.userInfo;
    NSInteger routeChangeReason = [[info valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    
    switch (routeChangeReason) {
            
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            // 耳机插入
//            NSLog(@"耳机插入");
            break;
            
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
        {
            // 耳机拔掉
            // 拔掉耳机继续播放
//            NSLog(@"耳机拔出");
            if (!self.playOrPauseBtn.selected == YES) {
                [self play];
            } else {
            }
        }
            break;
            
        case AVAudioSessionRouteChangeReasonCategoryChange:
//            NSLog(@"AVAudioSessionRouteChangeReasonCategoryChange");
            break;
    }
}

//闹铃等中断
- (void)interruption:(NSNotification *)notification {
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground ||
        [UIApplication sharedApplication].applicationState == UIApplicationStateInactive) {
        return;
    }
    NSDictionary *interuptionDict = notification.userInfo;
    NSInteger interuptionType = [[interuptionDict valueForKey:AVAudioSessionInterruptionTypeKey] integerValue];
    NSNumber  *seccondReason  = [[notification userInfo] objectForKey:AVAudioSessionInterruptionOptionKey] ;
    switch (interuptionType) {
        case AVAudioSessionInterruptionTypeBegan:
        {
            //收到中断，暂停播放
//            NSLog(@"收到中断");
            [self pause];
            self.playOrPauseBtn.selected = YES;
            break;
        }
        case AVAudioSessionInterruptionTypeEnded:
            //系统中断结束
//            NSLog(@"结束中断");
            break;
    }
    switch ([seccondReason integerValue]) {
        case AVAudioSessionInterruptionOptionShouldResume:
            //恢复播放
//            NSLog(@"恢复中断 --");
            break;
        default:
            break;
    }
}

- (void)volumeDidChangeNotification:(NSNotification *)notification {
    float volume = [[[notification userInfo] objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
    NSLog(@"音量变化 %f",volume);
    [self.tipView updateProgress:volume withVolumeBrightnessType:HZVolumeBrightnessTypeVolume];
}

#pragma mark 定时器相关
- (void)addTimer{
    [self removeTimer];
    [[HZGCDTimerManager sharedManager] scheduledDispatchTimerWithName:HZPlayerToolBarHideTimer
                                                         timeInterval:6
                                                            delaySecs:6
                                                                queue:dispatch_get_main_queue()
                                                              repeats:YES
                                                               action:^{
                                                                   [self singleTapHideItems];
                                                               }];
    [[HZGCDTimerManager sharedManager] startTimer:HZPlayerToolBarHideTimer];
}

- (void)removeTimer{
    [[HZGCDTimerManager sharedManager] cancelTimerWithName:HZPlayerToolBarHideTimer];
}

#pragma mark HZSliderViewDelegate
// 滑块拖动开始
- (void)sliderTouchBegan:(float)value{
//    NSLog(@"拖动开始");
    [self removeTimer];
    if (self.totalTime > 0) {
        return;
    }
    self.slider.isdragging = YES;
}

// 滑块拖动中
- (void)sliderValueChanged:(float)value{
//    NSLog(@"滑块拖动开始");
//    [self suspendTimer];
    if (self.totalTime == 0) {
        self.slider.value = 0;
        return;
    }
    self.slider.isdragging = YES;
    NSString *currentTimeString = [self getTime:self.totalTime*value];
    self.currentTimeLabel.text = currentTimeString;
    self.bottomProgress.value = value;
}

// 滑块拖动结束
- (void)sliderTouchEnded:(float)value{
//    NSLog(@"拖动结束");
    [self addTimer];
    [self sliderChange:value];
}

// 滑杆点击
- (void)sliderTapped:(float)value{
//    NSLog(@"滑杆点击");
    [self addTimer];
    [self sliderChange:value];
}

- (void)sliderChange:(float)value{
    if (self.totalTime > 0) {
        self.slider.isdragging = YES;
//        [self.activity start];
        @weakify(self)
        NSString *currentTimeString = [self getTime:self.totalTime*value];
        self.currentTimeLabel.text = currentTimeString;
        self.bottomProgress.value = value;
        self.bottomProgress.bufferValue = value;
        self.slider.value = value;
        self.slider.bufferValue = value;
        [self seekToTime:self.totalTime*value completionHandler:^(BOOL finished) {
            @strongify(self)
            if (finished) {
                self.slider.isdragging = NO;
                if (!self.playOrPauseBtn.selected) {
//                    NSLog(@"seek 回调");
                    [self play];
                } else {
//                    [self.activity stop];
                }
            }
        }];
    } else {
        self.slider.isdragging = NO;
        self.slider.value = 0;
    }
}
@end
