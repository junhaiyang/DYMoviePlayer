//
//  PlayerViewController.m
//  DYMovidePlayer
//
//  Created by yangjunhai on 14-8-25.
//  Copyright (c) 2014年 soooner. All rights reserved.
//

#import "PlayerViewController.h"
#import "DYMoviePlayer.h"
#import "DYMovieControllerView.h"
#import "DYMoviePlayerView.h"

@interface PlayerViewController (){
    
    DYMoviePlayer *player;
    
    DYMovieControllerView *controllerView;
    
    DYMoviePlayerView *playerView;
}

@end

@implementation PlayerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
         
    }
    return self;
}

-(void)dealloc{
    NSLog(@"---PlayerViewController--dealloc----");

    [player shutdown];
    
    player = nil;
    
    [playerView removeFromSuperview];
    playerView = nil;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    player =[[DYMoviePlayer alloc] init];
    player.autostartWhenReady =  YES;
    
    playerView = [[DYMoviePlayerView alloc] initWithFrame:self.view.bounds];
    
    player.view = playerView;
//
    [player setURL:[NSURL URLWithString:@"http://movies.apple.com/media/us/iphone/2009/ads/apple-iphone3gs-ad-multi_people-us-20091123_640x360.mov"]];
    
    [self.view addSubview:playerView];
    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
