//
//  HZPlayerGestureControl.m
//  HZVideoPlayer
//
//  Created by huangzhenyu on 2018/7/20.
//  Copyright © 2018年 huangzhenyu. All rights reserved.
//

#import "HZPlayerGestureControl.h"

@interface HZPlayerGestureControl ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UITapGestureRecognizer *singleTap;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTap;
@property (nonatomic, strong) UIPanGestureRecognizer *panGR;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGR;
@property (nonatomic) HZPanDirection panDirection;
@property (nonatomic) HZPanLocation panLocation;
@property (nonatomic) HZPanMovingDirection panMovingDirection;
@property (nonatomic, weak) UIView *targetView;

@end

@implementation HZPlayerGestureControl

- (void)addGestureToView:(UIView *)view {
    self.targetView = view;
    self.targetView.multipleTouchEnabled = YES;
    [self.singleTap requireGestureRecognizerToFail:self.doubleTap];
    [self.doubleTap requireGestureRecognizerToFail:self.panGR];
    [self.targetView addGestureRecognizer:self.singleTap];
    [self.targetView addGestureRecognizer:self.doubleTap];
    [self.targetView addGestureRecognizer:self.panGR];
    [self.targetView addGestureRecognizer:self.pinchGR];
}

- (void)removeGestureToView:(UIView *)view {
    [view removeGestureRecognizer:self.singleTap];
    [view removeGestureRecognizer:self.doubleTap];
    [view removeGestureRecognizer:self.panGR];
    [view removeGestureRecognizer:self.pinchGR];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    HZPlayerGestureType type = HZPlayerGestureTypeUnknown;
    if (gestureRecognizer == self.singleTap) type = HZPlayerGestureTypeSingleTap;
    else if (gestureRecognizer == self.doubleTap) type = HZPlayerGestureTypeDoubleTap;
    else if (gestureRecognizer == self.panGR) type = HZPlayerGestureTypePan;
    else if (gestureRecognizer == self.pinchGR) type = HZPlayerGestureTypePinch;
    CGPoint locationPoint = [touch locationInView:touch.view];
    if (locationPoint.x > _targetView.bounds.size.width / 2) {
        self.panLocation = HZPanLocationRight;
    } else {
        self.panLocation = HZPanLocationLeft;
    }
    
    HZPlayerDisableGestureTypes disableTypes = self.disableTypes;
    if (disableTypes & HZPlayerDisableGestureTypesAll) {
        disableTypes = HZPlayerDisableGestureTypesPan | HZPlayerDisableGestureTypesPinch | HZPlayerDisableGestureTypesDoubleTap | HZPlayerDisableGestureTypesSingleTap;
    }
    switch (type) {
        case HZPlayerGestureTypeUnknown: break;
        case HZPlayerGestureTypePan: {
            if (disableTypes & HZPlayerDisableGestureTypesPan) {
                return NO;
            }
        }
            break;
        case HZPlayerGestureTypePinch: {
            if (disableTypes & HZPlayerDisableGestureTypesPinch) {
                return NO;
            }
        }
            break;
        case HZPlayerGestureTypeDoubleTap: {
            if (disableTypes & HZPlayerDisableGestureTypesDoubleTap) {
                return NO;
            }
        }
            break;
        case HZPlayerGestureTypeSingleTap: {
            if (disableTypes & HZPlayerDisableGestureTypesSingleTap) {
                return NO;
            }
        }
            break;
    }
    
    if (self.triggerCondition) return self.triggerCondition(self, type, gestureRecognizer, touch);
    return YES;
}

// Whether to support multi-trigger, return YES, you can trigger a method with multiple gestures, return NO is mutually exclusive
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (otherGestureRecognizer != self.singleTap &&
        otherGestureRecognizer != self.doubleTap &&
        otherGestureRecognizer != self.panGR &&
        otherGestureRecognizer != self.pinchGR) return NO;
    if (gestureRecognizer.numberOfTouches >= 2) {
        return NO;
    }
    return YES;
}

- (UITapGestureRecognizer *)singleTap {
    if (!_singleTap){
        _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        _singleTap.delegate = self;
        _singleTap.delaysTouchesBegan = YES;
        _singleTap.delaysTouchesEnded = YES;
        _singleTap.numberOfTouchesRequired = 1;  
        _singleTap.numberOfTapsRequired = 1;
    }
    return _singleTap;
}

- (UITapGestureRecognizer *)doubleTap {
    if (!_doubleTap) {
        _doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        _doubleTap.delegate = self;
        _doubleTap.delaysTouchesBegan = YES;
        _singleTap.delaysTouchesEnded = YES;
        _doubleTap.numberOfTouchesRequired = 1; 
        _doubleTap.numberOfTapsRequired = 2;
    }
    return _doubleTap;
}

- (UIPanGestureRecognizer *)panGR {
    if (!_panGR) {
        _panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        _panGR.delegate = self;
        _panGR.delaysTouchesBegan = YES;
        _panGR.delaysTouchesEnded = YES;
        _panGR.maximumNumberOfTouches = 1;
        _panGR.cancelsTouchesInView = YES;
    }
    return _panGR;
}

- (UIPinchGestureRecognizer *)pinchGR {
    if (!_pinchGR) {
        _pinchGR = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
        _pinchGR.delegate = self;
        _pinchGR.delaysTouchesBegan = YES;
    }
    return _pinchGR;
}

- (void)handleSingleTap:(UITapGestureRecognizer *)tap {
    if (self.singleTapped) self.singleTapped(self);
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)tap {
    if (self.doubleTapped) self.doubleTapped(self);
}

- (void)handlePan:(UIPanGestureRecognizer *)pan {
    CGPoint translate = [pan translationInView:pan.view];
    CGPoint velocity = [pan velocityInView:pan.view];
    switch (pan.state) {
        case UIGestureRecognizerStateBegan: {
            self.panMovingDirection = HZPanMovingDirectionUnkown;
            CGFloat x = fabs(velocity.x);
            CGFloat y = fabs(velocity.y);
            if (x > y) {
                self.panDirection = HZPanDirectionH;
            } else {
                self.panDirection = HZPanDirectionV;
            }
            
            if (self.beganPan) self.beganPan(self, self.panDirection, self.panLocation);
        }
            break;
        case UIGestureRecognizerStateChanged: {
            switch (_panDirection) {
                case HZPanDirectionH: {
                    if (translate.x > 0) {
                        self.panMovingDirection = HZPanMovingDirectionRight;
                    } else if (translate.y < 0) {
                        self.panMovingDirection = HZPanMovingDirectionLeft;
                    }
                }
                    break;
                case HZPanDirectionV: {
                    if (translate.y > 0) {
                        self.panMovingDirection = HZPanMovingDirectionBottom;
                    } else {
                        self.panMovingDirection = HZPanMovingDirectionTop;
                    }
                }
                    break;
                case HZPanDirectionUnknown:
                    break;
            }
            if (self.changedPan) self.changedPan(self, self.panDirection, self.panLocation, velocity);
        }
            break;
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            if (self.endedPan) self.endedPan(self, self.panDirection, self.panLocation);
        }
            break;
        default:
            break;
    }
    [pan setTranslation:CGPointZero inView:pan.view];
}

- (void)handlePinch:(UIPinchGestureRecognizer *)pinch {
    switch (pinch.state) {
        case UIGestureRecognizerStateEnded: {
            if (self.pinched) self.pinched(self, pinch.scale);
        }
            break;
        default:
            break;
    }
}

@end
