
#import <AVFoundation/AVFoundation.h>

#import "DYMoviePlayerLayerView.h"

@implementation DYMoviePlayerLayerView

////////////////////////////////////////////////////////////////////////
#pragma mark - Class Methods
////////////////////////////////////////////////////////////////////////

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

@end