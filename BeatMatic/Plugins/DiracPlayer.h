//
//  DiracPlayer.h
//  BeatMatic
//
//  Created by Martin Percossi on 04.09.12.
//
//

#import <Cordova/CDVPlugin.h>
#import <DiracFxAudioPlayer.h>

//@interface DiracPlayerDelegate : UIViewController {
//    NSString *sampleName;
//    DiracPlayer *player;
//}
//
//
//@end
//
@interface DiracPlayer : CDVPlugin {
    NSMutableDictionary *sampleNameToPlayer;
    NSMutableDictionary *playerToSampleName;
    NSMutableDictionary *playerToCallbackId;
    
//    DiracFxAudioPlayer *player;
}

/*
 
 This is the functionality I need to replicate.
 - (id) initWithContentsOfURL: (NSURL*)inUrl channels:(int)channels error:(NSError **)error;
 - (void) setDelegate:(id)delegate;
 - (id) delegate;
 - (void) changeDuration:(float)duration;
 - (void) changePitch:(float)pitch;
 - (NSInteger) numberOfLoops;
 - (void) setNumberOfLoops:(NSInteger)loops;
 - (BOOL) prepareToPlay;
 - (NSUInteger) numberOfChannels;
 - (NSTimeInterval) fileDuration;
 - (NSTimeInterval) currentTime;
 - (void) setCurrentTime:(NSTimeInterval)time;
 - (void) play;
 - (NSURL*) url;
 - (void) setVolume:(float)volume;
 - (float) volume;
 - (BOOL) playing;
 - (void) pause;
 - (void) stop;
 */

- (void) diracInit: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) play: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) stop: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) load: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
//- (void) unload: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) changePitch: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) changeDuration: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) diracPlayerDidFinishPlaying:(DiracAudioPlayerBase *)player successfully:(BOOL)flag;

@end
