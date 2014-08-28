 
#import "DYMoviePlayer.h"

#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MediaPlayer.h>
#import "DYMoviePlayerView.h"

static char playerItemStatusContext;
static char playerItemDurationContext;
static char playerCurrentItemContext;
static char playerRateContext;
 


@interface DYMoviePlayer () {
    // flags for methods implemented in the delegate
    struct {
        unsigned int didStartPlayback:1;
        unsigned int didFailToLoad:1;
        unsigned int didFinishPlayback:1;
        unsigned int didPausePlayback:1;
        unsigned int didResumePlayback:1;
        
        unsigned int didChangeStatus:1;
        unsigned int didChangePlaybackRate:1;
        unsigned int didChangeControlStyle:1;
        unsigned int didUpdateCurrentTime:1;
	} _delegateFlags;
    
    BOOL _seekToInitialPlaybackTimeBeforePlay;
    
    float received_history;
}

@property (nonatomic, strong, readwrite) AVPlayer *player;  // re-defined as read/write
@property (nonatomic, strong) AVAsset *asset;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, readonly) CMTime CMDuration;
@property (nonatomic, strong) id playerTimeObserver;

@property (nonatomic, assign) NSTimeInterval timeToSkip;


@property (nonatomic, strong) NSTimer *playableDurationTimer;
@property (nonatomic, strong) NSTimer *speedTimer;

@end

@implementation DYMoviePlayer

@synthesize player = _player;
@synthesize control;
@synthesize autostartWhenReady=_autostartWhenReady;
@synthesize initialPlaybackTime= _initialPlaybackTime;
@synthesize delegate=_delegate;
@synthesize URL = _URL;

////////////////////////////////////////////////////////////////////////
#pragma mark - Class Methods
////////////////////////////////////////////////////////////////////////

+ (void)setAudioSessionCategory:(DYMoviePlayerAudioSessionCategory)audioSessionCategory {
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setCategory:DYAVAudioSessionCategoryFromDYMoviePlayerAudioSessionCategory(audioSessionCategory)
                                           error:&error];
    
    if (error != nil) {
        NSLog(@"There was an error setting the AudioCategory to AVAudioSessionCategoryPlayback");
    }
}

+ (void)initialize {
    if (self == [DYMoviePlayer class]) {
        [self setAudioSessionCategory:DYMoviePlayerAudioSessionCategoryPlayback];
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithURL:(NSURL *)URL initialPlaybackTime:(NSTimeInterval)initialPlaybackTime {
    if ((self = [super init])) {
        _autostartWhenReady = NO;
        _initialPlaybackTime = initialPlaybackTime;
        
        // calling setter here on purpose
        self.URL = URL;
    }
    return self;
}

- (id)initWithURL:(NSURL *)URL {
    return [self initWithURL:URL initialPlaybackTime:0.];
}

- (id)init {
    return [self initWithURL:nil];
}
- (void)shutdown{
    AVPlayer *player = control.playerLayer.player;
    
    [self.playableDurationTimer invalidate];
    self.playableDurationTimer = nil;
    
    [self.speedTimer invalidate];
    self.speedTimer = nil;
    
    _delegate = nil;
    
    [self stopObservingPlayerTimeChanges];
    [player pause];
    control.player = nil;
    control = nil;
    
    [player removeObserver:self forKeyPath:@"rate"];
    [player removeObserver:self forKeyPath:@"currentItem"];
    
    if(_playerItem){
        [_playerItem removeObserver:self forKeyPath:@"status"];
        [_playerItem removeObserver:self forKeyPath:@"duration"];
        
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:_playerItem];
    }
    
    _player = nil;
    _playerItem = nil;
    _asset = nil;
    
    
    
    _playerItem = nil;
    
    _player = nil;
    
    _asset = nil;
    
    _playerTimeObserver = nil;
    
 
}
- (void)dealloc {
    NSLog(@"---DYMoviePlayer--dealloc----");
    
    
    AVPlayer *player = control.playerLayer.player;
    
    [self.playableDurationTimer invalidate];
    self.playableDurationTimer = nil;
    
    [self.speedTimer invalidate];
    self.speedTimer = nil;
    
    _delegate = nil;
    
    [self stopObservingPlayerTimeChanges];
    [player pause];
    
    control.player = nil;
    control = nil;
    
    [player removeObserver:self forKeyPath:@"rate"];
    [player removeObserver:self forKeyPath:@"currentItem"];
    
    if(_playerItem){
        [_playerItem removeObserver:self forKeyPath:@"status"];
        [_playerItem removeObserver:self forKeyPath:@"duration"];
        
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:_playerItem];
    }
    [player replaceCurrentItemWithPlayerItem:nil];
    
    _player = nil;
    _playerItem = nil;
    _asset = nil;
    
    
}


////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject KVO
////////////////////////////////////////////////////////////////////////

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == &playerItemStatusContext) {
        AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        
        switch (status) {
            case AVPlayerStatusUnknown: {
                NSLog(@"------AVPlayerStatusUnknown------");
                [self stopObservingPlayerTimeChanges]; 
                // TODO: Disable buttons & scrubber
                break;
            }
                
            case AVPlayerStatusReadyToPlay: {
                NSLog(@"------AVPlayerStatusReadyToPlay------");
                // TODO: Enable buttons & scrubber
                    if (self.autostartWhenReady) {
                        _autostartWhenReady = NO;
                        [self play]; 
                    }
                
                break;
            }
                
            case AVPlayerStatusFailed: {
                NSLog(@"------AVPlayerStatusFailed------");
                
                NSString *errorMsg = [self.player.currentItem.error localizedFailureReason];
                if(errorMsg==nil||errorMsg.length==0)
                    errorMsg =[self.player.currentItem.error localizedDescription];
                NSLog(@"%@",errorMsg);
                
                [self stopObservingPlayerTimeChanges];
                [self.control updateWithCurrentTime:self.currentPlaybackTime duration:self.duration];
                // TODO: Disable buttons & scrubber
                break;
            }
        }
        
        [self.control updateWithPlaybackStatus:self.playing];
        
        if (_delegateFlags.didChangeStatus) {
            [self.delegate moviePlayer:self didChangeStatus:status];
        }
    }
    
    else if (context == &playerItemDurationContext) {
        [self.control updateWithCurrentTime:self.currentPlaybackTime duration:self.duration];
    }
    
    else if (context == &playerCurrentItemContext) {
        AVPlayerItem *newPlayerItem = [change objectForKey:NSKeyValueChangeNewKey];
        
        if (newPlayerItem == (id)[NSNull null]) {
            [self stopObservingPlayerTimeChanges];
            // TODO: Disable buttons & scrubber
        } else {
            [self.control updateWithPlaybackStatus:self.playing];
            [self startObservingPlayerTimeChanges];
        }
    }
    
    else if (context == &playerRateContext) {
        [self.control updateWithPlaybackStatus:self.playing];
        
        if (_delegateFlags.didChangePlaybackRate) {
            [self.delegate moviePlayer:self didChangePlaybackRate:self.player.rate];
        }
    }
    
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Notifications
////////////////////////////////////////////////////////////////////////

- (void)playerItemDidPlayToEndTime:(NSNotification *)notification {
    [self.player pause];
    
    _seekToInitialPlaybackTimeBeforePlay = YES;
    if (_delegateFlags.didFinishPlayback) {
        [self.delegate moviePlayer:self didFinishPlaybackOfURL:self.URL];
    }
    [self.control moviePlayerDidEndToPlay];
    
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////

- (CMTime)CMDuration {
    CMTime duration = kCMTimeInvalid;
    
    // Peferred in HTTP Live Streaming
    if ([self.playerItem respondsToSelector:@selector(duration)] && // 4.3
        self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
        
        if (CMTIME_IS_VALID(self.playerItem.duration)) {
            duration = self.playerItem.duration;
        }
    }
    
    // when playing over AirPlay the previous duration always returns 1, so we check again
    if ((!CMTIME_IS_VALID(duration) || duration.value/duration.timescale < 2) && CMTIME_IS_VALID(self.player.currentItem.asset.duration)) {
        duration = self.player.currentItem.asset.duration;
    }
    
    return duration;
}

- (void)doneLoadingAsset:(AVAsset *)asset withKeys:(NSArray *)keys {
    if (!asset.playable) {
        if (_delegateFlags.didFailToLoad) {
            [self.delegate moviePlayer:self didFailToLoadURL:self.URL];
        }
        
        return;
    }
    
    // Check if all keys are OK
    for (NSString *key in keys) {
        NSError *error = nil;
        AVKeyValueStatus status = [asset statusOfValueForKey:key error:&error];
        
        if (status == AVKeyValueStatusFailed || status == AVKeyValueStatusCancelled) {
            if (_delegateFlags.didFailToLoad) {
                [self.delegate moviePlayer:self didFailToLoadURL:self.URL];
            }
            
            return;
        }
    }
    
    // Remove observer from old playerItem and create new one
    if (self.playerItem) {
        [self.playerItem removeObserver:self forKeyPath:@"status"];
        [self.playerItem removeObserver:self forKeyPath:@"duration"];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:self.playerItem];
    }
    
    [self setPlayerItem:[AVPlayerItem playerItemWithAsset:asset]];
    
    
    // Observe status, ok -> play
    [self.playerItem addObserver:self
                      forKeyPath:@"status"
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:&playerItemStatusContext];
    
    // Durationchange
    [self.playerItem addObserver:self
                      forKeyPath:@"duration"
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:&playerItemDurationContext];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidPlayToEndTime:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:self.playerItem];
    
    _seekToInitialPlaybackTimeBeforePlay = YES;
    
    // Create the player
    if (!self.player) {
        [self setPlayer:[AVPlayer playerWithPlayerItem:self.playerItem]];
        
        // Observe currentItem, catch the -replaceCurrentItemWithPlayerItem:
        [self.player addObserver:self
                      forKeyPath:@"currentItem"
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:&playerCurrentItemContext];
        
        // Observe rate, play/pause-button?
        [self.player addObserver:self
                      forKeyPath:@"rate"
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:&playerRateContext];
        
    }
    
    // New playerItem?
    if (self.player.currentItem != self.playerItem) {
        [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
        [self.control updateWithPlaybackStatus:self.playing];
    }
}
- (void)startObservingPlayerTimeChanges {
    if (self.playerTimeObserver == nil) {
        __weak DYMoviePlayer *weakSelf = self;
        
        self.playerTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(.5, NSEC_PER_SEC)
                                                                            queue:dispatch_get_main_queue()
                                                                       usingBlock:^(CMTime time) {
                                                                           
                                                                           if (weakSelf != nil && [weakSelf isKindOfClass:[DYMoviePlayer class]]) {
                                                                               if (CMTIME_IS_VALID(weakSelf.player.currentTime) && CMTIME_IS_VALID(weakSelf.CMDuration)) {
                                                                                   [weakSelf.control updateWithCurrentTime:weakSelf.currentPlaybackTime
                                                                                                                 duration:weakSelf.duration];
                                                                                   
                                                                                   [weakSelf moviePlayerDidUpdateCurrentPlaybackTime:weakSelf.currentPlaybackTime];
                                                                                   
                                                                                   if([weakSelf.delegate respondsToSelector:@selector(moviePlayer:didUpdateCurrentTime:)]){
                                                                                       [weakSelf.delegate moviePlayer:weakSelf didUpdateCurrentTime:weakSelf.currentPlaybackTime];
                                                                                   }
                                                                               }
                                                                           }
                                                                       }];
    }
}
- (void)moviePlayerDidUpdateCurrentPlaybackTime:(NSTimeInterval)currentPlaybackTime {
    // do nothing here
}

- (void)stopObservingPlayerTimeChanges {
    if (self.playerTimeObserver != nil) {
        [self.player removeTimeObserver:self.playerTimeObserver];
        self.playerTimeObserver = nil;
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - NGMoviePlayer Properties
////////////////////////////////////////////////////////////////////////
- (AVPlayer *)player {
    return self.control.playerLayer.player;
}

- (void)setPlayer:(AVPlayer *)player {
    if (player != self.control.playerLayer.player) {
        self.control.playerLayer.player = player;
//        self.view.delegate = self;
    }
}

- (void)setURL:(NSURL *)URL {
    if (_URL != URL) {
        _URL = URL;
        
        if (URL != nil) {
            NSArray *keys = [NSArray arrayWithObjects:@"tracks", @"playable", nil];
            
            [self setAsset:[AVURLAsset URLAssetWithURL:URL options:nil]];
            [self.asset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self doneLoadingAsset:self.asset withKeys:keys];
                });
            }];
            //开始准备中
            [self.control moviePlayerDidStartToPrepare];
        }
    }
}

- (void)setURL:(NSURL *)URL initialPlaybackTime:(NSTimeInterval)initialPlaybackTime {
    self.initialPlaybackTime = initialPlaybackTime;
    self.URL = URL;
}
////////////////////////////////////////////////////////////////////////
#pragma mark - NGMoviePlayer Video Playback
////////////////////////////////////////////////////////////////////////
 


-(void)setControl:(id<DYMoviePlayerViewDelegate>)_control{
    control = _control;
    control.player =self;
}
- (void)play {
    if (self.player.status == AVPlayerStatusReadyToPlay) {
        if (_seekToInitialPlaybackTimeBeforePlay && _initialPlaybackTime >= 0.) {
            CMTime time = CMTimeMakeWithSeconds(_initialPlaybackTime, NSEC_PER_SEC);
            
            [self.player seekToTime:time];
            
            [self.control moviePlayerDidStartToPlay];
            
            if (_delegateFlags.didStartPlayback) {
                [self.delegate moviePlayer:self didStartPlaybackOfURL:self.URL];
            }
            
            _seekToInitialPlaybackTimeBeforePlay = NO;
        } else {
            
            if (_delegateFlags.didResumePlayback) {
                [self.delegate moviePlayerDidResumePlayback:self];
            }
            
            [self.control moviePlayerDidResumePlayback];
            
        }
        
        [self.player play];
    } else {
        [self.control moviePlayerDidStartToPrepare];
        _autostartWhenReady = YES;
    }
    
    [self.playableDurationTimer invalidate];
    self.playableDurationTimer = [NSTimer scheduledTimerWithTimeInterval:1.
                                                                  target:self
                                                                selector:@selector(updatePlayableDurationTimerFired:)
                                                                userInfo:nil
                                                                 repeats:YES];
    [self.speedTimer invalidate];
    self.speedTimer = [NSTimer scheduledTimerWithTimeInterval:1.
                                                                  target:self
                                                                selector:@selector(updateSpeedTimerFired:)
                                                                userInfo:nil
                                                                 repeats:YES];
    
}

- (void)pause {
    [self.player pause];
    
    [self.playableDurationTimer invalidate];
    self.playableDurationTimer = nil;
    
    [self.control moviePlayerDidPausePlayback];
    
    if (_delegateFlags.didPausePlayback) {
        [self.delegate moviePlayerDidPausePlayback:self];
    }
}

- (void)togglePlaybackState {
    if (self.playing) {
        [self pause];
    } else {
        [self play];
    }
}

- (void)updatePlayableDurationTimerFired:(NSTimer *)timer {
    [self.control updatePlayableDurationTimerFired:self.playableDuration];
}
- (void)updateSpeedTimerFired:(NSTimer *)timer {
    [self.control updateSpeedTimerFired:[self getBiteSpeed]];
}
 
- (void)setDelegate:(id<DYMoviePlayerDelegate>)delegate {
    if (delegate != _delegate) {
        _delegate = delegate;
        
        _delegateFlags.didStartPlayback = [delegate respondsToSelector:@selector(moviePlayer:didStartPlaybackOfURL:)];
        _delegateFlags.didFailToLoad = [delegate respondsToSelector:@selector(moviePlayer:didFailToLoadURL:)];
        _delegateFlags.didFinishPlayback = [delegate respondsToSelector:@selector(moviePlayer:didFinishPlaybackOfURL:)];
        _delegateFlags.didPausePlayback = [delegate respondsToSelector:@selector(moviePlayerDidPausePlayback:)];
        _delegateFlags.didResumePlayback = [delegate respondsToSelector:@selector(moviePlayerDidResumePlayback:)];
        
        
        _delegateFlags.didChangeStatus = [delegate respondsToSelector:@selector(moviePlayer:didChangeStatus:)];
        _delegateFlags.didChangePlaybackRate = [delegate respondsToSelector:@selector(moviePlayer:didChangePlaybackRate:)];
        _delegateFlags.didUpdateCurrentTime = [delegate respondsToSelector:@selector(moviePlayer:didUpdateCurrentTime:)];
    }
}

- (BOOL)isPlaying {
    return self.player != nil && self.player.rate != 0.f;
}

- (BOOL)isPlayingLivestream {
    return self.URL != nil && (isnan(self.duration) || self.duration <= 0.);
}

- (void)setVideoGravity:(DYMoviePlayerVideoGravity)videoGravity {
    self.control.playerLayer.videoGravity = DYAVLayerVideoGravityFromDYMoviePlayerVideoGravity(videoGravity);
    self.control.playerLayer.bounds = self.control.playerLayer.bounds;
}

- (DYMoviePlayerVideoGravity)videoGravity {
    return DYMoviePlayerVideoGravityFromAVLayerVideoGravity(self.control.playerLayer.videoGravity);
}
-(void)seek:(NSTimeInterval)currentTime  completionHandler:(void (^)(BOOL finished))completionHandler{
    
    currentTime = MAX(currentTime,0.);
    currentTime = MIN(currentTime,self.duration);
    
    CMTime time = CMTimeMakeWithSeconds(currentTime, NSEC_PER_SEC);
    
    [self.player seekToTime:time completionHandler:^(BOOL finished) {
        NSLog(@"------completionHandler start play,need stop loading-------");
        if(completionHandler){
            completionHandler(finished);
        }
    }];
}
- (void)setCurrentPlaybackTime:(NSTimeInterval)currentTime {
    currentTime = MAX(currentTime,0.);
    currentTime = MIN(currentTime,self.duration);
    
    CMTime time = CMTimeMakeWithSeconds(currentTime, NSEC_PER_SEC);
    [self.player seekToTime:time];
    
    
    [self.control updateWithCurrentTime:currentTime duration:self.duration];
}

- (NSTimeInterval)currentPlaybackTime {
    return CMTimeGetSeconds(self.player.currentTime);
}

- (NSTimeInterval)duration {
    return CMTimeGetSeconds(self.CMDuration);
}

-(CGFloat)getBiteSpeed{
    
    CGFloat reciveTotal = 0.0f;
    CGFloat recivebits = 0.0f;
    
    NSArray *events = self.player.currentItem.accessLog.events;
    for (AVPlayerItemAccessLogEvent *event in events) {
        reciveTotal += event.numberOfBytesTransferred;
    }
    
    if(received_history == reciveTotal){
        return 0.0f;
    }
    
    recivebits = reciveTotal-received_history;
    if(recivebits<0)
        recivebits =0;
    
    received_history = reciveTotal;
    return recivebits / 1024.0f;
    
}

- (NSTimeInterval)playableDuration {
    NSArray *loadedTimeRanges = [self.player.currentItem loadedTimeRanges];
    
    if (loadedTimeRanges.count > 0) {
        CMTimeRange timeRange = [[loadedTimeRanges objectAtIndex:0] CMTimeRangeValue];
        Float64 startSeconds = CMTimeGetSeconds(timeRange.start);
        Float64 durationSeconds = CMTimeGetSeconds(timeRange.duration);
        
        return (NSTimeInterval)(startSeconds + durationSeconds);
    } else {
        return 0.;
    }
}
 

@end
