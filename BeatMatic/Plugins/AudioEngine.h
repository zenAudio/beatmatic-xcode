//
//  AudioEngine.h
//  BeatMatic
//
//  Created by Martin Percossi on 08.09.12.
//
//

#import <Cordova/CDVPlugin.h>
#import "objctrampoline.h"

@interface AudioEngine : CDVPlugin {
    NSString* cursorCallbackId;
    NSTimer * timer;
}

// Initialization/Test
- (void) initialise: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) playTestTone: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

// Transport
- (void) play: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) stop: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) setCursorCallback: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) setBpm: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) getBpm: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

// Drum Machine
- (void) setDrumPattern: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) auditionDrum: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

// Looper
- (void) toggleLoop: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

// Recorder
- (void) recordAudioStart: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) recordAudioStop: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) playSample: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) stopSample: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) setAudioInputLevelCallback: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

// FX
- (void) setMasterFilter: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) setMasterVerb: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) setMasterCrusher:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options;

// Trampoline (objctrampoline.h)
- (void) invokePhoneGapCallback:(NSString *)callbackId withResponse:(NSString*)jsonResponse;
//- (void) cursorCb;

@end
