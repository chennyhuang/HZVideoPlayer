//
//  HZPlayerGestureControl.h
//  ZFPlayer
//
// Copyright (c) 2016年 任子丰 ( http://github.com/renzifeng )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, HZPlayerGestureType) {
    HZPlayerGestureTypeUnknown,
    HZPlayerGestureTypeSingleTap,
    HZPlayerGestureTypeDoubleTap,
    HZPlayerGestureTypePan,
    HZPlayerGestureTypePinch
};

typedef NS_ENUM(NSUInteger, HZPanDirection) {
    HZPanDirectionUnknown,
    HZPanDirectionV,
    HZPanDirectionH,
};

typedef NS_ENUM(NSUInteger, HZPanLocation) {
    HZPanLocationUnknown,
    HZPanLocationLeft,
    HZPanLocationRight,
};

typedef NS_ENUM(NSUInteger, HZPanMovingDirection) {
    HZPanMovingDirectionUnkown,
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
