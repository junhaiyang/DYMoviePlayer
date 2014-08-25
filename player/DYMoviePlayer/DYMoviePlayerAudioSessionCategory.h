 
//
#import <AVFoundation/AVFoundation.h>

typedef enum {
    DYMoviePlayerAudioSessionCategoryPlayback = 0,  // default
    DYMoviePlayerAudioSessionCategoryAmbient,
    DYMoviePlayerAudioSessionCategorySoloAmbient,
    DYMoviePlayerAudioSessionCategoryRecord,
    DYMoviePlayerAudioSessionCategoryPlayAndRecord,
    DYMoviePlayerAudioSessionCategoryAudioProcessing,
} DYMoviePlayerAudioSessionCategory;


NS_INLINE NSString* DYAVAudioSessionCategoryFromDYMoviePlayerAudioSessionCategory(DYMoviePlayerAudioSessionCategory audioSessionCategory) {
    switch (audioSessionCategory) {
        case DYMoviePlayerAudioSessionCategoryAmbient: {
            return AVAudioSessionCategoryAmbient;
        }
            
        case DYMoviePlayerAudioSessionCategorySoloAmbient: {
            return AVAudioSessionCategorySoloAmbient;
        }
            
        case DYMoviePlayerAudioSessionCategoryRecord: {
            return AVAudioSessionCategoryRecord;
        }
            
        case DYMoviePlayerAudioSessionCategoryPlayAndRecord: {
            return AVAudioSessionCategoryPlayAndRecord;
        }
            
        case DYMoviePlayerAudioSessionCategoryAudioProcessing: {
            return AVAudioSessionCategoryAudioProcessing;
        }
            
        default:
        case DYMoviePlayerAudioSessionCategoryPlayback: {
            return AVAudioSessionCategoryPlayback;
        }
    }
}