//
//  HZPlayerGestureControl.h
//  HZVideoPlayer
//
//  Created by huangzhenyu on 2018/7/20.
//  Copyright © 2018年 huangzhenyu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, HZPlayerGestureType) {
    HZPlayerGestureTypeUnknown = 0,
    HZPlayerGestureTypeSingleTap,
    HZPlayerGestureTypeDoubleTap,
    HZPlayerGestureTypePan,
    HZPlayerGestureTypePinch
};

typedef NS_ENUM(NSUInteger, HZPanDirection) {
    HZPanDirectionUnknown = 0,
    HZPanDirectionV,
    HZPanDirectionH,
};

typedef NS_ENUM(NSUInteger, HZPanLocation) {
    HZPanLocationUnknown = 0,
    HZPanLocationLeft,
    HZPanLocationRight,
};

typedef NS_ENUM(NSUInteger, HZPanMovingDirection) {
    HZPanMovingDirectionUnkown = 0,
    HZPanMovingDirectionTop,
    HZPanMovingDirectionLeft,
    HZPanMovingDirectionBottom,
    HZPanMovingDirectionRight,
};

/// This enumeration lists some of the gesture types that the player has by default.
typedef NS_OPTIONS(NSUInteger, HZPlayerDisableGestureTypes) {
    HZPlayerDisableGestureTypesNone         = 0,
    HZPlayerDisableGestureTypesSingleTap    = 1 << 0,
    HZPlayerDisableGestureTypesDoubleTap    = 1 << 1,
    HZPlayerDisableGestureTypesPan          = 1 << 2,
    HZPlayerDisableGestureTypesPinch        = 1 << 3,
    HZPlayerDisableGestureTypesAll          = 1 << 4
};

@interface HZPlayerGestureControl : NSObject

@property (nonatomic, copy, nullable) BOOL(^triggerCondition)(HZPlayerGestureControl *control, HZPlayerGestureType type, UIGestureRecognizer *gesture, UITouch *touch);
@property (nonatomic, copy, nullable) void(^singleTapped)(HZPlayerGestureControl *control);
@property (nonatomic, copy, nullable) void(^doubleTapped)(HZPlayerGestureControl *control);
@property (nonatomic, copy, nullable) void(^beganPan)(HZPlayerGestureControl *control, HZPanDirection direction, HZPanLocation location);
@property (nonatomic, copy, nullable) void(^changedPan)(HZPlayerGestureControl *control, HZPanDirection direction, HZPanLocation location, CGPoint velocity);
@property (nonatomic, copy, nullable) void(^endedPan)(HZPlayerGestureControl *control, HZPanDirection direction, HZPanLocation location);
@property (nonatomic, copy, nullable) void(^pinched)(HZPlayerGestureControl *control, float scale);

@property (nonatomic, readonly) HZPanDirection panDirection;
@property (nonatomic, readonly) HZPanLocation panLocation;
@property (nonatomic, readonly) HZPanMovingDirection panMovingDirection;
@property (nonatomic) HZPlayerDisableGestureTypes disableTypes;

- (void)addGestureToView:(UIView *)view;
- (void)removeGestureToView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
