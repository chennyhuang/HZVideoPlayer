//
//  HZGCDTimerManager.m
//  HZVideoPlayer
//
//  Created by huangzhenyu on 2018/7/23.
//  Copyright © 2018年 huangzhenyu. All rights reserved.
//


#import "HZGCDTimerManager.h"

@interface HZGCDTimer ()
/**响应*/
@property (nonatomic, copy) dispatch_block_t    action;
/**线程*/
@property (nonatomic, strong) dispatch_queue_t  serialQueue;
/**timer_t*/
@property (nonatomic, strong) dispatch_source_t timer_t;
/**定时器名字*/
@property (nonatomic, strong) NSString          *timerName;
/**响应数组*/
@property (nonatomic, strong) NSArray           *actionBlockArray;
/**是否重复*/
@property (nonatomic, assign) BOOL              repeat;
/**是否正在运行*/
@property (nonatomic, assign) BOOL              isRuning;
/**延迟时间*/
@property (nonatomic, assign) float             delaySecs;
/**执行时间*/
@property (nonatomic, assign) NSTimeInterval    timeInterval;

@end

@implementation HZGCDTimer

- (instancetype)initDispatchTimerWithName:(NSString *)timerName
                             timeInterval:(double)interval
                                delaySecs:(float)delaySecs
                                    queue:(dispatch_queue_t)queue
                                  repeats:(BOOL)repeats
                                   action:(dispatch_block_t)action{
    if (self = [super init]) {
        self.timeInterval = interval;
        self.delaySecs    = delaySecs;
        self.repeat       = repeats;
        self.action       = action;
        self.timerName    = timerName;
        self.isRuning     = NO;
        
        NSString *privateQueueName = [NSString stringWithFormat:@"CLGCDTimer.%p", self];
        self.serialQueue           = dispatch_queue_create([privateQueueName cStringUsingEncoding:NSASCIIStringEncoding], DISPATCH_QUEUE_SERIAL);
        self.timer_t               = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.serialQueue);
        dispatch_set_target_queue(self.serialQueue, queue);

        NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:action, nil];
        self.actionBlockArray = array;
    }
    return self;
}
- (void)addActionBlock:(dispatch_block_t)action{
    NSMutableArray *array = [self.actionBlockArray mutableCopy];
    [array removeAllObjects];
    [array addObject:action];
}

@end

@interface HZGCDTimerManager ()

/**CLGCDTimer字典*/
@property (nonatomic, strong) NSMutableDictionary *timerObjectCache;

@end

@implementation HZGCDTimerManager

#pragma mark - 初始化
+ (instancetype)sharedManager {
    static HZGCDTimerManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[HZGCDTimerManager alloc] init];
    });
    return manager;
}

#pragma mark - 添加定时器
- (void)adddDispatchTimerWithName:(NSString *)timerName
                     timeInterval:(NSTimeInterval)interval
                        delaySecs:(float)delaySecs
                            queue:(dispatch_queue_t)queue
                          repeats:(BOOL)repeats
                           action:(dispatch_block_t)action {
    HZGCDTimer *GCDTimer = self.timerObjectCache[timerName];
    if (!GCDTimer) {
        GCDTimer = [[HZGCDTimer alloc] initDispatchTimerWithName:timerName
                                                    timeInterval:interval
                                                       delaySecs:delaySecs
                                                           queue:queue
                                                         repeats:repeats
                                                          action:action];
        self.timerObjectCache[timerName] = GCDTimer;
    } else {
        [GCDTimer addActionBlock:action];
        GCDTimer.timeInterval = interval;
        GCDTimer.delaySecs    = delaySecs;
        GCDTimer.serialQueue  = queue;
        GCDTimer.repeat       = repeats;
    }
}
#pragma mark - 创建定时器
- (void)scheduledDispatchTimerWithName:(NSString *)timerName
                          timeInterval:(NSTimeInterval)interval
                             delaySecs:(float)delaySecs
                                 queue:(dispatch_queue_t)queue
                               repeats:(BOOL)repeats
                                action:(dispatch_block_t)action {
    HZGCDTimer *GCDTimer = self.timerObjectCache[timerName];
    if (GCDTimer) {
        return;
    }
    [self adddDispatchTimerWithName:timerName
                       timeInterval:interval
                          delaySecs:delaySecs
                              queue:queue
                            repeats:repeats
                             action:action];
}
#pragma mark - 开始定时器
- (void)startTimer:(NSString *)timerName {
    HZGCDTimer *GCDTimer = self.timerObjectCache[timerName];
    if (!GCDTimer.isRuning && GCDTimer) {
        dispatch_source_set_timer(GCDTimer.timer_t, dispatch_time(DISPATCH_TIME_NOW, GCDTimer.delaySecs * NSEC_PER_SEC),GCDTimer.timeInterval * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
        __weak typeof(self) weakSelf = self;
        dispatch_source_set_event_handler(GCDTimer.timer_t, ^{
            GCDTimer.action();
            if (!GCDTimer.repeat) {
                [weakSelf cancelTimerWithName:timerName];
            }
        });
        [self resumeTimer:timerName];
    }
}
#pragma mark - 执行一次定时器响应
- (void)responseOnceTimer:(NSString *)timerName {
    HZGCDTimer *GCDTimer = self.timerObjectCache[timerName];
    GCDTimer.isRuning    = YES;
    [GCDTimer.actionBlockArray enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        dispatch_block_t action = obj;
        action();
    }];
    GCDTimer.isRuning = NO;
}
#pragma mark - 取消定时器
- (void)cancelTimerWithName:(NSString *)timerName {
    HZGCDTimer *GCDTimer = self.timerObjectCache[timerName];
    if (!GCDTimer.isRuning && GCDTimer) {
        [self resumeTimer:timerName];
    }
    if (GCDTimer) {
        dispatch_source_cancel(GCDTimer.timer_t);
        [self.timerObjectCache removeObjectForKey:timerName];
    }
}
#pragma mark - 暂停定时器
- (void)suspendTimer:(NSString *)timerName {
    HZGCDTimer *GCDTimer = self.timerObjectCache[timerName];
    if (GCDTimer.isRuning && GCDTimer) {
        dispatch_suspend(GCDTimer.timer_t);
        GCDTimer.isRuning = NO;
    }
}
#pragma mark - 恢复定时器
- (void)resumeTimer:(NSString *)timerName {
    HZGCDTimer *GCDTimer = self.timerObjectCache[timerName];
    if (!GCDTimer.isRuning && GCDTimer) {
        dispatch_resume(GCDTimer.timer_t);
        GCDTimer.isRuning = YES;
    }
}
#pragma mark - 懒加载
- (NSMutableDictionary *)timerObjectCache {
    if (!_timerObjectCache) {
        _timerObjectCache = [[NSMutableDictionary alloc] init];
    }
    return _timerObjectCache;
}
@end



