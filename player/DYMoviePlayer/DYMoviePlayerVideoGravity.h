 
#import <AVFoundation/AVFoundation.h>

typedef enum {
    DYMoviePlayerVideoGravityResizeAspect = 0,  // default
    DYMoviePlayerVideoGravityResizeAspectFill,
    DYMoviePlayerVideoGravityResize,
} DYMoviePlayerVideoGravity;


NS_INLINE NSString* DYAVLayerVideoGravityFromDYMoviePlayerVideoGravity(DYMoviePlayerVideoGravity gravity) {
    switch (gravity) {
        case DYMoviePlayerVideoGravityResizeAspectFill: {
            return AVLayerVideoGravityResizeAspectFill;
        }
            
        case DYMoviePlayerVideoGravityResize: {
            return AVLayerVideoGravityResize;
        }
            
        default:
        case DYMoviePlayerVideoGravityResizeAspect: {
            return AVLayerVideoGravityResizeAspect;
        }
    }
}

NS_INLINE DYMoviePlayerVideoGravity DYMoviePlayerVideoGravityFromAVLayerVideoGravity(NSString *gravity) {
    if ([gravity isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
        return DYMoviePlayerVideoGravityResizeAspectFill;
    }
    
    if ([gravity isEqualToString:AVLayerVideoGravityResize]) {
        return DYMoviePlayerVideoGravityResize;
    }
    
    // default
    return DYMoviePlayerVideoGravityResizeAspect;
}

NS_INLINE NSString* DYAVLayerVideoGravityNext(NSString *gravity) {
    if ([gravity isEqualToString:AVLayerVideoGravityResizeAspect]) {
        return AVLayerVideoGravityResizeAspectFill;
    }
    
    if ([gravity isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
        return AVLayerVideoGravityResize;
    }
    
    // default
    return AVLayerVideoGravityResizeAspect;
}