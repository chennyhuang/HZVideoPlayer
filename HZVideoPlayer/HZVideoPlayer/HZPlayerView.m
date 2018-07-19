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

// 播放器的几种状态
typedef NS_ENUM(NSInteger, HZPlayerState) {
    HZPlayerStateFailed,     // 播放失败
    HZPlayerStateBuffering,  // 缓冲中
    HZPlayerStatePlaying,    // 播放中
    HZPlayerStateStopped,    // 停止播放
};



@interface HZPlayerView() <HZSliderViewDelegate>
/**播放器*/
@property (nonatomic, strong) AVPlayer *player;
/**播放器item*/
@property (nonatomic, strong) AVPlayerItem *playerItem;
/**playerLayer*/
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
/**视频拉伸模式*/
@property (nonatomic, copy) NSString *fillMode;
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
@end

@implementation HZPlayerView
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
    CGFloat playPauseBtnWH = 70;
    self.playOrPauseBtn.frame = CGRectMake((viewW - playPauseBtnWH)*0.5, (viewH - playPauseBtnWH)*0.5, playPauseBtnWH, playPauseBtnWH);
    self.bottomPgrogress.frame = CGRectMake(0, viewH - 2, viewW, 2);
    CGFloat backBtnWH = toolBarH;
    self.backBtn.frame = CGRectMake(10, 0, backBtnWH, backBtnWH);
    //bottomToolView相关
    CGFloat leftSpace = 10;//最左侧间距
    CGFloat rightSpace = 20;//最右侧间距
    CGFloat timeLabelW = 70;
    self.currentTimeLabel.frame = CGRectMake(leftSpace, 0, timeLabelW, toolBarH);
    CGFloat fullBtnWH = toolBarH;
    self.fullScreenBtn.frame = CGRectMake(viewW - fullBtnWH - rightSpace, 0, fullBtnWH, fullBtnWH);
    self.totalTimeLabel.frame = CGRectMake(viewW - fullBtnWH - rightSpace - timeLabelW, 0, timeLabelW, toolBarH);
    self.slider.frame = CGRectMake(CGRectGetMaxX(self.currentTimeLabel.frame), (toolBarH - 4)*0.5, viewW - fullBtnWH - rightSpace - timeLabelW - leftSpace - timeLabelW, 4);
}

- (void)initUI{
    self.clipsToBounds = NO;
    self.videoFillMode = HZVideoFillModeResizeAspect;
    [self addSubview:self.topToolView];
    [self addSubview:self.bottomToolView];
    [self addSubview:self.playOrPauseBtn];
    [self addSubview:self.bottomPgrogress];
    
    [self.topToolView addSubview:self.backBtn];
    [self.bottomToolView addSubview:self.currentTimeLabel];
    [self.bottomToolView addSubview:self.totalTimeLabel];
    [self.bottomToolView addSubview:self.slider];
    [self.bottomToolView addSubview:self.fullScreenBtn];
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
    _playerLayer.videoGravity = _fillMode;
    //放到最下面，防止遮挡
    [self.layer insertSublayer:_playerLayer atIndex:0];

    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    [_player play];
}

// 视频拉伸方式
- (void)setVideoFillMode:(HZVideoFillMode)videoFillMode{
    _videoFillMode = videoFillMode;
    switch (videoFillMode){
        case HZVideoFillModeResize:
            //拉伸视频内容达到边框占满，但不按原比例拉伸
            _fillMode = AVLayerVideoGravityResize;
            break;
        case HZVideoFillModeResizeAspect:
            //按原视频比例显示，是竖屏的就显示出竖屏的，两边留黑
            _fillMode = AVLayerVideoGravityResizeAspect;
            break;
        case HZVideoFillModeResizeAspectFill:
            //原比例拉伸视频，直到两边屏幕都占满，但视频内容有部分会被剪切
            _fillMode = AVLayerVideoGravityResizeAspectFill;
            break;
    }
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
//        _bottomToolView.backgroundColor = [UIColor yellowColor];
    }
    return _bottomToolView;
}

- (UIButton *)backBtn {
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backBtn setImage:HZPlayerImage(@"HZPlayer_back") forState:UIControlStateNormal];
    }
    return _backBtn;
}

- (UIButton *)playOrPauseBtn {
    if (!_playOrPauseBtn) {
        _playOrPauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playOrPauseBtn setImage:HZPlayerImage(@"HZPlayer_play") forState:UIControlStateNormal];
        [_playOrPauseBtn setImage:HZPlayerImage(@"HZPlayer_pause") forState:UIControlStateSelected];
    }
    return _playOrPauseBtn;
}

- (UILabel *)currentTimeLabel {
    if (!_currentTimeLabel) {
        _currentTimeLabel = [[UILabel alloc] init];
        _currentTimeLabel.textColor = [UIColor whiteColor];
        _currentTimeLabel.font = [UIFont systemFontOfSize:14.0f];
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
        _bottomPgrogress.minimumTrackTintColor = [UIColor whiteColor];
        _bottomPgrogress.bufferTrackTintColor  = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
        _bottomPgrogress.sliderHeight = 1;
        _bottomPgrogress.isHideSliderBlock = NO;
        _bottomPgrogress.backgroundColor = [UIColor redColor];
    }
    return _bottomPgrogress;
}

- (UILabel *)totalTimeLabel {
    if (!_totalTimeLabel) {
        _totalTimeLabel = [[UILabel alloc] init];
        _totalTimeLabel.textColor = [UIColor whiteColor];
        _totalTimeLabel.font = [UIFont systemFontOfSize:14.0f];
        _totalTimeLabel.textAlignment = NSTextAlignmentCenter;
        _totalTimeLabel.text = @"00:00:00";
        _totalTimeLabel.backgroundColor = [UIColor redColor];
    }
    return _totalTimeLabel;
}

- (UIButton *)fullScreenBtn {
    if (!_fullScreenBtn) {
        _fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fullScreenBtn setImage:HZPlayerImage(@"HZPlayer_fullscreen") forState:UIControlStateNormal];
    }
    return _fullScreenBtn;
}

@end
