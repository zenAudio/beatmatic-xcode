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
}

- (void) diracInit: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) play: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) stop: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) load: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) changePitch: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) changeDuration: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) diracPlayerDidFinishPlaying:(DiracAudioPlayerBase *)player successfully:(BOOL)flag;

@end
