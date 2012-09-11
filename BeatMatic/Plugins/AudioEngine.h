//
//  AudioEngine.h
//  BeatMatic
//
//  Created by Martin Percossi on 08.09.12.
//
//

#import <Cordova/CDVPlugin.h>

@interface AudioEngine : CDVPlugin {
    NSString* cursorCallbackId;
}

// Initialization/Test
- (void) initialise: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) playTestTone: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

// Transport
- (void) play: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) stop: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) setCursorCallback: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

// Drum Machine
- (void) setDrumPattern: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) auditionDrum: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

// Looper
- (void) toggleLoop: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

@end
