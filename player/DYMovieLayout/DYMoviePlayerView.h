//
//  DYMoviePlayerView.h
//  DYMovidePlayer
//
//  Created by yangjunhai on 14-8-25.
//  Copyright (c) 2014年 soooner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class DYMoviePlayer; 

@interface DYMoviePlayerView : UIView 

@property (nonatomic, readonly) AVPlayerLayer *playerLayer; 

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
