
#import <AVFoundation/AVFoundation.h>
#import "DYMoviePlayerAudioSessionCategory.h"
#import "DYMoviePlayerVideoGravity.h"

@class DYMoviePlayer;
@class DYMoviePlayerLayerView;

@protocol DYMoviePlayerViewDelegate;

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

@protocol DYMoviePlayerActionDelegate <NSObject>

@optional

@property (nonatomic, strong, readonly) AVPlayer *player;  //播放器

@property (nonatomic, strong) NSURL *URL;                 //播放地址

@property (nonatomic, readonly, getter = isPlaying) BOOL playing; //是否是播放

@property (nonatomic, assign) BOOL autostartWhenReady;   //是否自动开始

@property (nonatomic, assign) NSTimeInterval currentPlaybackTime;  //当前播放时间

@property (nonatomic, readonly)NSTimeInterval duration;           //总时长

@property (nonatomic, readonly)NSTimeInterval playableDuration;   //可播放时长

@property (nonatomic, assign) NSTimeInterval initialPlaybackTime;  //初始化时从某个时间开始

@property (nonatomic, weak) id<DYMoviePlayerDelegate> delegate;

@property (nonatomic, assign) DYMoviePlayerVideoGravity videoGravity;

@property (nonatomic, weak) id<DYMoviePlayerViewDelegate> control;


//初始化
- (id)initWithURL:(NSURL *)URL;
- (id)initWithURL:(NSURL *)URL initialPlaybackTime:(NSTimeInterval)initialPlaybackTime;

//设置初始化参数
- (void)setURL:(NSURL *)URL initialPlaybackTime:(NSTimeInterval)initialPlaybackTime;

//播放控制
- (void)play;
- (void)seek:(NSTimeInterval)currentTime  completionHandler:(void (^)(BOOL finished))completionHandler;
- (void)pause;
- (void)togglePlaybackState;

- (void)shutdown;

@end

@protocol DYMoviePlayerViewDelegate <NSObject>

@property (nonatomic, readonly) AVPlayerLayer *playerLayer;

@property (nonatomic, readonly) DYMoviePlayerLayerView *playerLayerView;

@property (nonatomic,weak) id<DYMoviePlayerActionDelegate> player;

- (void)updateWithCurrentTime:(NSTimeInterval)currentTime duration:(NSTimeInterval)duration; //已播放

- (void)updateWithPlaybackStatus:(BOOL)isPlaying;      //播放状态反馈

- (void)moviePlayerDidStartToPrepare;  // 开始准备中

- (void)updatePlayableDurationTimerFired:(NSTimeInterval)playableDuration;  //可播放时长反馈

- (void)updateSpeedTimerFired:(CGFloat)speed;  //网速反馈

- (void)moviePlayerDidStartToPlay;    //开始播放

- (void)moviePlayerDidPausePlayback;  //播放暂停

- (void)moviePlayerDidResumePlayback; //播放恢复

- (void)moviePlayerDidEndToPlay;     // 结束播放

@end