//
//  MoviePlayer.h
//  DYMovidePlayer
//
//  Created by yangjunhai on 14-8-25.
//  Copyright (c) 2014年 soooner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MediaPlayer.h>
#import "DYMoviePlayerAudioSessionCategory.h"
#import "DYMoviePlayerVideoGravity.h"
#import "DYMoviePlayerDelegate.h"

@class DYMoviePlayerView;

@interface DYMoviePlayer : NSObject
 
@property (nonatomic, strong, readonly) AVPlayer *player;  //播放器

@property (nonatomic, copy) NSURL *URL;                 //播放地址

@property (nonatomic, readonly, getter = isPlaying) BOOL playing; //是否是播放

@property (nonatomic, assign) BOOL autostartWhenReady;   //是否自动开始

@property (nonatomic, assign) NSTimeInterval currentPlaybackTime;  //当前播放时间

@property (nonatomic, readonly)NSTimeInterval duration;           //总时长

@property (nonatomic, readonly)NSTimeInterval playableDuration;   //可播放时长

@property (nonatomic, assign) NSTimeInterval initialPlaybackTime;  //初始化时从某个时间开始

@property (nonatomic, weak) id<DYMoviePlayerDelegate> delegate;
 
@property (nonatomic, assign) DYMoviePlayerVideoGravity videoGravity;

@property (nonatomic, strong) DYMoviePlayerView *view;


//设置音频的模式
+ (void)setAudioSessionCategory:(DYMoviePlayerAudioSessionCategory)audioSessionCategory;

//初始化
- (id)initWithURL:(NSURL *)URL;
- (id)initWithURL:(NSURL *)URL initialPlaybackTime:(NSTimeInterval)initialPlaybackTime;

//设置初始化参数
- (void)setURL:(NSURL *)URL initialPlaybackTime:(NSTimeInterval)initialPlaybackTime;

//播放控制
- (void)play;
- (void)pause;
- (void)togglePlaybackState;

- (void)shutdown;

@end
