

#import "DYMoviePlayerView.h"
#import "DYMoviePlayerLayerView.h"
#import "DYMoviePlayer.h" 

@interface DYMoviePlayerView () <UIGestureRecognizerDelegate,DYMoviePlayerDelegate> {
    BOOL _shouldHideControls;
} 

@property (nonatomic, strong,readwrite) DYMoviePlayerLayerView *playerLayerView;

@end

@implementation DYMoviePlayerView

@dynamic playerLayer; 
@synthesize player=_player;
@synthesize playerLayerView=_playerLayerView;

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

- (void)dealloc {
    NSLog(@"---DYMoviePlayerView--dealloc----");
    
    AVPlayerLayer *playerLayer = (AVPlayerLayer *)[_playerLayerView layer];
    
    [playerLayer removeFromSuperlayer];
    playerLayer = nil;
    
    [_playerLayerView removeFromSuperview];
    _playerLayerView = nil;
    
    
    _player =nil;
    
}
- (AVPlayerLayer *)playerLayer {
    return (AVPlayerLayer *)[self.playerLayerView layer];
}
 


////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////

- (void)setup {
    
    // Player Layer
    _playerLayerView = [[DYMoviePlayerLayerView alloc] initWithFrame:self.bounds];
    _playerLayerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:_playerLayerView];
    
    
    
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
