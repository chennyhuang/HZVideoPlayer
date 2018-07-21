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
// 播放器的几种状态
typedef NS_ENUM(NSInteger, HZPlayerState) {
    HZPlayerStateFailed,     // 播放失败
    HZPlayerStateBuffering,  // 缓冲中
    HZPlayerStatePlaying,    // 播放中
    HZPlayerStatePause,      //暂停中
    HZPlayerStateDone        //播放完成
};

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
/**播放或暂停按钮*/
@property (nonatomic, strong) UIButton *playOrPauseBtn;
/**播放的当前时间*/
@property (nonatomic, strong) UILabel *currentTimeLabel;
/**返回按钮*/
@property (nonatomic, strong) UIButton *backBtn;
/**底部播放进度*/
@property (nonatomic, strong) HZSliderView *bottomPgrogress;
/**滑杆*/
@property (nonatomic, strong) HZSliderView *slider;
/**视频总时间*/
@property (nonatomic, strong) UILabel *totalTimeLabel;
/**全屏按钮*/
@property (nonatomic, strong) UIButton *fullScreenBtn;
/**工具条和播放暂停按钮是否展示*/
@property (nonatomic,assign) BOOL isToolBarShow;
/**手势控制*/
@property (nonatomic,strong) HZPlayerGestureControl *gestureControl;
@property (nonatomic, assign) NSTimeInterval totalTime;//视频总时长
@property (nonatomic,assign) BOOL isPrepareToPlay;
@end

@implementation HZPlayerView
- (void)dealloc{
    [self removeObservers];
    [self resetPlayer];
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
    CGFloat toolBarH = 40;
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
    self.bottomPgrogress.frame = CGRectMake(0, viewH - 2, viewW, 2);
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
}

- (void)initUI{
    //属性初始化
    self.scalingMode = HZPlayerScalingModeAspectFit;
    self.playerOrientation = HZPlayerOrientationPortrait;
    self.autoPlay = YES;//默认自动播放
    
    [self addSubview:self.topToolView];
    [self addSubview:self.bottomToolView];
    [self addSubview:self.activity];
    [self addSubview:self.playOrPauseBtn];
    [self addSubview:self.bottomPgrogress];
    [self addSubview:self.backBtn];
    
    
    [self.bottomToolView addSubview:self.currentTimeLabel];
    [self.bottomToolView addSubview:self.totalTimeLabel];
    [self.bottomToolView addSubview:self.slider];
    [self.bottomToolView addSubview:self.fullScreenBtn];
    //启动默认隐藏工具条
    [self singleTapHideItems];
    //添加事件
    [self.gestureControl addGestureToView:self];
}

#pragma mark getter setter
- (void)setUrl:(NSURL *)url{
    _url = url;
    self.playerItem = [AVPlayerItem playerItemWithAsset:[AVAsset assetWithURL:_url]];
    //创建
    _player = [AVPlayer playerWithPlayerItem:_playerItem];
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    _playerLayer.backgroundColor = [UIColor blackColor].CGColor;
    //设置静音模式播放声音
    AVAudioSession * session  = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [session setActive:YES error:nil];
//    _playerLayer.videoGravity = _fillMode;
    //放到最下面，防止遮挡
    [self.layer insertSublayer:_playerLayer atIndex:0];

    [self addObservers];
}

- (void)setPlayerItem:(AVPlayerItem *)playerItem{
    if (_playerItem == playerItem) {
        return;
    }
    if (_playerItem) {
        [self removeObservers];
        [self resetPlayer];
    }
    _playerItem = playerItem;
}

- (void)setAutoPlay:(BOOL)autoPlay{
    _autoPlay = autoPlay;
    _autoPlay ?[self play]:[self pause];
}

- (void)setPlayerState:(HZPlayerState)playerState{
    _playerState = playerState;
    switch (playerState) {
        case HZPlayerStatePause:
            self.playOrPauseBtn.selected = YES;
            break;
        case HZPlayerStatePlaying:
            if (self.player) {
                [self.activity stop];
                self.playOrPauseBtn.selected = NO;
            }
            
            break;
        case HZPlayerStateBuffering:
            if (self.player) {
                [self.activity start];
                self.playOrPauseBtn.selected = YES;
            }
            break;
        case HZPlayerStateFailed:
            
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

- (HZSliderView *)bottomPgrogress {
    if (!_bottomPgrogress) {
        _bottomPgrogress = [[HZSliderView alloc] init];
        _bottomPgrogress.maximumTrackTintColor = [UIColor clearColor];
        _bottomPgrogress.minimumTrackTintColor = [UIColor redColor];
        _bottomPgrogress.bufferTrackTintColor  = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
        _bottomPgrogress.sliderHeight = 2;
        _bottomPgrogress.isHideSliderBlock = YES;
    }
    return _bottomPgrogress;
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
//            NSLog(@"doubleTapped");
        };
        
        _gestureControl.beganPan = ^(HZPlayerGestureControl * _Nonnull control, HZPanDirection direction, HZPanLocation location) {
            @strongify(self)
//            NSLog(@"beganPan");
        };
        
        _gestureControl.changedPan = ^(HZPlayerGestureControl * _Nonnull control, HZPanDirection direction, HZPanLocation location, CGPoint velocity) {
            @strongify(self)
//            NSLog(@"changedPan");
            
        };
        
        _gestureControl.endedPan = ^(HZPlayerGestureControl * _Nonnull control, HZPanDirection direction, HZPanLocation location) {
            @strongify(self)
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
    self.bottomPgrogress.hidden = YES;
    self.playOrPauseBtn.hidden = YES;
    self.isToolBarShow = NO;
}

- (void)rotateEndShowItems{
    self.bottomPgrogress.hidden = NO;
}

//暂停
- (void)pause{
    self.playerState = HZPlayerStatePause;
    [self.player pause];
}

//播放
- (void)play{
    if (self.isPrepareToPlay) {
        if (self.autoPlay) {
//            self.playerState = HZPlayerStatePlaying;
            NSLog(@"play -- ");
            if (!self.playerItem.isPlaybackLikelyToKeepUp) {
                [self bufferingSomeSecond];
            } else {
                self.playerState = HZPlayerStatePlaying;
                [self.player play];
            }
            
        } else {
            [self pause];
        }
        
    } else {
        self.playerState = HZPlayerStateBuffering;
    }
}

- (void)stop{
    [self removeObservers];
    [self resetPlayer];
    [self removeFromSuperview];
}


#pragma mark private methods
#pragma mark - 缓冲较差时候
//卡顿缓冲几秒
- (void)bufferingSomeSecond{
    if (!_player) {
        return;
    }
    // 需要先暂停一小会之后再播放，否则网络状况不好的时候时间在走，声音播放不出来
    [self.player pause];
    self.playerState = HZPlayerStateBuffering;
    NSLog(@"网络较差，3秒缓冲中 --- ");
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
        [self play];
    }
}

- (void)removeObservers{
    [_playerItem removeObserver:self forKeyPath:@"status"];
    [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [_playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:_player.currentItem];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillResignActiveNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
    [_player removeTimeObserver:_timeObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:_itemEndObserver name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
}

- (void)addObservers{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerDidEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:_playerItem];
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
                NSLog(@"播放中 --");
                self.playerState = HZPlayerStatePlaying;
                [self playerTimeChange];
            } else if (self.player.timeControlStatus == AVPlayerTimeControlStatusWaitingToPlayAtSpecifiedRate) {
                NSLog(@"AVPlayerTimeControlStatusWaitingToPlayAtSpecifiedRate");
                self.playerState = HZPlayerStateBuffering;
            } else {
                NSLog(@"pause -- ");
            }
            
        } else {
            if (self.player.rate == 1) {
                NSLog(@"播放中");
                self.playerState = HZPlayerStatePlaying;
                [self playerTimeChange];
            } else {
                NSLog(@"pause -- ");
            }
            
        }
    }];
    
    _itemEndObserver = [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        @strongify(self)
        if (!self) return;
        NSLog(@"播放完成 EndObserver ");
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
    self.bottomPgrogress.value = 0;
    self.bottomPgrogress.bufferValue = 0;
}

//视频播放完成
- (void)playerDidEnd:(id)sender{
    self.playerState = HZPlayerStateDone;
}

- (void)seekToTime:(NSTimeInterval)time completionHandler:(void (^ __nullable)(BOOL finished))completionHandler {
    CMTime seekTime = CMTimeMake(time, 1); //kCMTimeZero
//    [_playerItem cancelPendingSeeks];
    //如果需要精准定位，那么把toleranceBefore:和toleranceAfter:的参数都设置为kCMTimeZero即可
    [_player seekToTime:seekTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:completionHandler];
}

- (void)singleTapHideItems{
    self.isToolBarShow = NO;
    self.topToolView.hidden = YES;
    self.bottomToolView.hidden = YES;
    self.playOrPauseBtn.hidden = YES;
    self.backBtn.hidden = YES;
    self.bottomPgrogress.hidden = NO;
}

- (void)singleTapShowItems{
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
    self.bottomPgrogress.hidden = YES;
}

- (void)playPause:(UIButton *)button{
    button.selected?[self play]:[self pause];
}

- (void)backClick{
    if (self.rotateToPortrait) {
        self.rotateToPortrait();
    }
}

- (void)fullClick:(UIButton *)button{
    if (self.playerOrientation == HZPlayerOrientationPortrait) {
//        button.selected = YES;
        if (self.rotateToLandScape) {
            self.rotateToLandScape();
        }
    } else {
//        button.selected = NO;
        if (self.rotateToPortrait) {
            self.rotateToPortrait();
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([keyPath isEqualToString:@"status"]) {
            if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
                NSLog(@"准备播放");
                CMTime duration = self.playerItem.duration;
                self.totalTime = CMTimeGetSeconds(duration);//视频总时长
                self.isPrepareToPlay = YES;
                [self play];
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
            NSLog(@"缓冲中");
            
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
        
        self.bottomPgrogress.bufferValue = bufferPer;
        self.bottomPgrogress.value = currentPer;
        
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

#pragma mark HZSliderViewDelegate
// 滑块拖动开始
- (void)sliderTouchBegan:(float)value{
    if (self.totalTime > 0) {
        return;
    }
    self.slider.isdragging = YES;
}

// 滑块拖动中
- (void)sliderValueChanged:(float)value{
    if (self.totalTime == 0) {
        self.slider.value = 0;
        return;
    }
    self.slider.isdragging = YES;
    NSString *currentTimeString = [self getTime:self.totalTime*value];
    self.currentTimeLabel.text = currentTimeString;
    self.bottomPgrogress.value = value;
}

// 滑块拖动结束
- (void)sliderTouchEnded:(float)value{
    [self sliderChange:value];
}

// 滑杆点击
- (void)sliderTapped:(float)value{
    [self sliderChange:value];
}

- (void)sliderChange:(float)value{
    if (self.totalTime > 0) {
        self.slider.isdragging = YES;
        @weakify(self)
        NSString *currentTimeString = [self getTime:self.totalTime*value];
        self.currentTimeLabel.text = currentTimeString;
        self.bottomPgrogress.value = value;
        [self seekToTime:self.totalTime*value completionHandler:^(BOOL finished) {
            @strongify(self)
            if (finished) {
                self.slider.isdragging = NO;
                [self play];
            }
        }];
    } else {
        self.slider.isdragging = NO;
        self.slider.value = 0;
    }
}
@end
