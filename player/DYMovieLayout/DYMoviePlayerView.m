//
//  DYMoviePlayerView.m
//  DYMovidePlayer
//
//  Created by yangjunhai on 14-8-25.
//  Copyright (c) 2014年 soooner. All rights reserved.
//

#import "DYMoviePlayerView.h"
#import "DYMovieControllerView.h"
#import "DYMoviePlayerLayerView.h"
#import "DYMoviePlayerPlaceholderView.h"
#import "DYMoviePlayer.h"

static char playerLayerReadyForDisplayContext;

@interface DYMoviePlayerView () <UIGestureRecognizerDelegate,DYMoviePlayerDelegate> {
    BOOL _shouldHideControls;
}
@property (nonatomic,strong,readwrite) DYMoviePlayer *player;

@property (nonatomic, strong, readwrite) DYMovieControllerView *controlsView;
@property (nonatomic, strong, readwrite) DYMoviePlayerPlaceholderView *placeholderView;
@property (nonatomic, strong) DYMoviePlayerLayerView *playerLayerView;

@end

@implementation DYMoviePlayerView

@dynamic playerLayer;
@synthesize controlsView;
@synthesize placeholderView;


////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.clipsToBounds = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundColor = [UIColor clearColor];
        [self setup];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self setup];
    }
    
    return self;
}
-(void)setControlsView:(DYMovieControllerView *)_controlsView{
    controlsView=_controlsView;
    [self addSubview:controlsView];
}

- (void)dealloc {
    NSLog(@"---DYMoviePlayerView--dealloc----");
    
    AVPlayerLayer *playerLayer = (AVPlayerLayer *)[_playerLayerView layer];
    
    [playerLayer removeFromSuperlayer];
    [playerLayer removeObserver:self forKeyPath:@"readyForDisplay"];
    playerLayer = nil;
    
    [_playerLayerView removeFromSuperview];
    _playerLayerView = nil;
    
    [controlsView removeFromSuperview];
    controlsView = nil;
    
    [placeholderView removeFromSuperview];
    placeholderView = nil;
    
    _player =nil;
    
}
- (AVPlayerLayer *)playerLayer {
    return (AVPlayerLayer *)[self.playerLayerView layer];
}
////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject KVO
////////////////////////////////////////////////////////////////////////

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == &playerLayerReadyForDisplayContext) {
        BOOL readyForDisplay = [[change valueForKey:NSKeyValueChangeNewKey] boolValue];
        
        if (self.playerLayerView.layer.opacity == 0.f && readyForDisplay) {
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
            
#define kNGFadeDuration                     0.33
            animation.duration = kNGFadeDuration;
            animation.fromValue = [NSNumber numberWithFloat:0.];
            animation.toValue = [NSNumber numberWithFloat:1.];
            animation.removedOnCompletion = NO;
            
            self.playerLayerView.layer.opacity = 1.f;
            [self.playerLayerView.layer addAnimation:animation forKey:nil];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////

- (void)setup {
    
    // Player Layer
    _playerLayerView = [[DYMoviePlayerLayerView alloc] initWithFrame:self.bounds];
    _playerLayerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _playerLayerView.alpha = 0.f;
    [self addSubview:_playerLayerView];
    
    controlsView =[self loadDYMovieControllerView];
    controlsView.backgroundColor=[UIColor clearColor];
    [self addSubview:controlsView];
    
    placeholderView =[self loadDYMoviePlayerPlaceholderView];
    placeholderView.backgroundColor=[UIColor clearColor];
    [self addSubview:placeholderView];
    
    [self.playerLayer addObserver:self
                       forKeyPath:@"readyForDisplay"
                          options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                          context:&playerLayerReadyForDisplayContext];
    
}

//下面方法根据需要重载
-(DYMovieControllerView *)loadDYMovieControllerView{
    return [[DYMovieControllerView alloc] initWithFrame:self.bounds];
}
-(DYMoviePlayerPlaceholderView *)loadDYMoviePlayerPlaceholderView{
    return [[DYMoviePlayerPlaceholderView alloc] initWithFrame:self.bounds];
}
 
- (void)updateWithCurrentTime:(NSTimeInterval)currentTime duration:(NSTimeInterval)duration{
    NSLog(@"updateWithCurrentTime:duration:");
    
}

- (void)updateWithPlaybackStatus:(BOOL)isPlaying{
    NSLog(@"updateWithPlaybackStatus:");
}

- (void)moviePlayerDidStartToPrepare{
    NSLog(@"moviePlayerDidStartToPrepare:");
}

- (void)updatePlayableDurationTimerFired:(NSTimeInterval)playableDuration{
    NSLog(@"updatePlayableDurationTimerFired:");
}

- (void)updateSpeedTimerFired:(CGFloat)playableDuration{
    NSLog(@"updateSpeedTimerFired:");
}

- (void)moviePlayerDidStartToPlay{
    NSLog(@"moviePlayerDidStartToPlay:");
}

- (void)moviePlayerDidPausePlayback{
    NSLog(@"moviePlayerDidPausePlayback:");
}

- (void)moviePlayerDidResumePlayback{
    NSLog(@"moviePlayerDidResumePlayback:");
}

- (void)moviePlayerDidEndToPlay{
    NSLog(@"moviePlayerDidEndToPlay:");
}


@end
