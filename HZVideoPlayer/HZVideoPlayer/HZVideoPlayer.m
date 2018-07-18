//
//  HZVideoPlayer.m
//  HZVideoPlayer
//
//  Created by huangzhenyu on 2018/7/17.
//  Copyright © 2018年 huangzhenyu. All rights reserved.
//

#import "HZVideoPlayer.h"
#import "HZPlayerControlView.h"

@interface HZVideoPlayer()
@property (nonatomic,assign) CGRect selfOriginRect;//自身初始frame
@property (nonatomic,assign) CGRect containerOriginRect;//containerView初始frame
@property (nonatomic,assign) UIStatusBarStyle originStatusBarStyle;//记录状态栏初始style
@property (nonatomic,assign) UIStatusBarStyle currentStatusBarStyle;//播放器展示后的状态栏style
@property (nonatomic,strong) UIWindow *keyWindow;
@property (nonatomic,strong) UIView *statusView;
@property (nonatomic,strong) UIView *containerView;
@end

@implementation HZVideoPlayer

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initUI];
    }
    return self;
}

- (void)initUI{
    self.originStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    self.currentStatusBarStyle = UIStatusBarStyleLightContent;
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.statusView];
    [self addSubview:self.coverImageView];
    [self addSubview:self.containerView];
    self.statusView.backgroundColor = [UIColor blackColor];
    self.containerView.backgroundColor = [UIColor brownColor];
    //设置播放器默认样式
    self.playerStyle = HZVideoPlayerStyleTop;
}

- (void)initFrame{
    CGFloat playerW = self.frame.size.width;
    CGFloat playerH = self.frame.size.height;
    
    CGFloat statusViewH = 0;
    if (self.playerStyle == HZVideoPlayerStyleTop) {
        statusViewH = kStatusBar_Height;
    } else {
        statusViewH = 0;
    }
    self.frame = CGRectMake(0, 0, playerW, playerH + statusViewH);
    self.selfOriginRect = self.frame;
    self.statusView.frame = CGRectMake(0, 0, playerW, statusViewH);
    self.coverImageView.frame = CGRectMake(0, statusViewH, playerW, playerH);
    self.containerView.frame = CGRectMake(0, statusViewH, playerW, playerH);
    self.containerOriginRect = self.containerView.frame;
}

- (void)didMoveToSuperview{
    [super didMoveToSuperview];
    [self initFrame];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    [label addGestureRecognizer:tap];
    label.userInteractionEnabled = YES;
    label.text = @"返回";
    label.backgroundColor = [UIColor redColor];
    label.textColor = [UIColor whiteColor];
    [self.containerView addSubview:label];
    
    UIButton *landScapeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [landScapeBtn setTitle:@"横屏" forState:UIControlStateNormal];
    [landScapeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    landScapeBtn.frame = CGRectMake(0, 100, 100, 50);
    landScapeBtn.backgroundColor = [UIColor yellowColor];
    [landScapeBtn addTarget:self action:@selector(landClick) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:landScapeBtn];
    
    NSLog(@"didMoveToSuperview--  %@",NSStringFromCGRect(self.frame));
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeviceOrientationChange) name:UIDeviceOrientationDidChangeNotification object:nil];
}

#pragma mark getter setter
- (UIWindow *)keyWindow{
    return [UIApplication sharedApplication].keyWindow;
}

- (UIView *)containerView{
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
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
        _coverImageView.backgroundColor = [UIColor blackColor];
    }
    return _coverImageView;
}

#pragma mark private methods
- (void)tap{
//    [self manualPortrait];
    NSLog(@"tap");
}

- (void)landClick{
//    [self manualLandscape];
    NSLog(@"landClick");
}

#pragma mark orientation
////手动强制竖屏
//- (void)manualPortrait{
//    NSLog(@"手动竖屏");
////    self.keyWindow.windowLevel = UIWindowLevelNormal;
//    [UIView animateWithDuration:kRotateAnimationDuration delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
//        self.containerView.transform = CGAffineTransformIdentity;
//        if (iPhoneX) {
//            self.containerView.frame = CGRectMake(0, kStatusBar_Height, self.playerW, self.playerH);
//        } else {
//            self.containerView.frame = CGRectMake(0, 0, self.playerW, self.playerH);
//        }
//        [self setNeedsLayout];
//        [self layoutIfNeeded];
//    } completion:^(BOOL finished) {
//    }];
//}
//
////手动强制横屏
//- (void)manualLandscape{
//    NSLog(@"手动横屏");
////    self.keyWindow.windowLevel = UIWindowLevelStatusBar+10.0f;//隐藏状态栏
//    [UIView animateWithDuration:kRotateAnimationDuration delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
//        self.containerView.transform = CGAffineTransformMakeRotation(M_PI/2);
//        if (iPhoneX) {
//            self.containerView.frame = CGRectMake(0, kStatusBar_Height, kAPPWidth, KAppHeight - kStatusBar_Height);
//        } else {
//            NSLog(@"横屏");
//            NSLog(@"w -- %f h -- %f",kAPPWidth,KAppHeight);
//            self.containerView.frame = CGRectMake(0, 0, kAPPWidth, KAppHeight);
//        }
//        [self setNeedsLayout];
//        [self layoutIfNeeded];
//    } completion:^(BOOL finished) {
//        
//    }];
//}

-(void)onDeviceOrientationChange
{
    CGFloat statusViewH = 0;
    if (self.playerStyle == HZVideoPlayerStyleTop) {
        statusViewH = kStatusBar_Height;
    } else {
        statusViewH = 0;
    }
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(orientation)) {
        self.keyWindow.windowLevel = UIWindowLevelStatusBar+10.0f;//隐藏状态栏
        [UIView animateWithDuration:kRotateAnimationDuration delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.containerView.transform = (orientation==UIDeviceOrientationLandscapeRight)?CGAffineTransformMakeRotation(M_PI*1.5):CGAffineTransformMakeRotation(M_PI/2);
            if (iPhoneX) {
                self.containerView.frame = CGRectMake(0, statusViewH, kAPPWidth, KAppHeight - statusViewH);
                self.frame = CGRectMake(0, 0, kAPPWidth, KAppHeight);
            } else {
                self.containerView.frame = CGRectMake(0, 0, kAPPWidth, KAppHeight);
                self.frame = CGRectMake(0, 0, kAPPWidth, KAppHeight);
            }
            [self setNeedsLayout];
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            
        }];
        
    } else if (orientation==UIDeviceOrientationPortrait){
        self.keyWindow.windowLevel = UIWindowLevelNormal;//展示状态栏
        [[UIApplication sharedApplication] setStatusBarStyle:self.originStatusBarStyle];
        [UIView animateWithDuration:kRotateAnimationDuration delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.containerView.transform = (orientation==UIDeviceOrientationPortrait)?CGAffineTransformIdentity:CGAffineTransformMakeRotation(M_PI);
            if (iPhoneX) {
                self.containerView.frame = self.containerOriginRect;
                self.frame = self.selfOriginRect;
            } else {
                self.containerView.frame = self.containerOriginRect;
                self.frame = self.selfOriginRect;
            }
            
            [self setNeedsLayout];
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
        }];
    }
}

@end
