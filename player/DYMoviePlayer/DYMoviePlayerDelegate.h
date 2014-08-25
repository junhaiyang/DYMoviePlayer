@class DYMoviePlayer;


@protocol DYMoviePlayerDelegate <NSObject>

@optional

- (void)moviePlayer:(DYMoviePlayer *)moviePlayer didStartPlaybackOfURL:(NSURL *)URL;
- (void)moviePlayer:(DYMoviePlayer *)moviePlayer didFailToLoadURL:(NSURL *)URL;
- (void)moviePlayer:(DYMoviePlayer *)moviePlayer didFinishPlaybackOfURL:(NSURL *)URL;
- (void)moviePlayerDidPausePlayback:(DYMoviePlayer *)moviePlayer;
- (void)moviePlayerDidResumePlayback:(DYMoviePlayer *)moviePlayer;

- (void)moviePlayer:(DYMoviePlayer *)moviePlayer didChangeStatus:(AVPlayerStatus)playerStatus;
- (void)moviePlayer:(DYMoviePlayer *)moviePlayer didChangePlaybackRate:(float)rate;
- (void)moviePlayer:(DYMoviePlayer *)moviePlayer didUpdateCurrentTime:(NSTimeInterval)currentTime;
  
@end