//
//  AudioEngine.m
//  BeatMatic
//
//  Created by Martin Percossi on 08.09.12.
//
//

#import "AudioEngine.h"
#import "AudioEngineImpl.h"

@implementation AudioEngine {
    AudioEngineImpl engine;
}

- (void) initialise: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    cursorCallbackId = nil;
    
	NSLog(@"MPD: NATIVE: AudioEngine::initialize: Initializing audio engine.");
    engine.init();
    
	NSLog(@"MPD: NATIVE: AudioEngine::initialize: Reading drum preset.");
    NSString* callbackID = [arguments pop];
    [callbackID retain];
    
    NSString *drumMachinePresetPath = [arguments pop];
    [drumMachinePresetPath retain];
    
    NSString *looperPresetPath = [arguments pop];
    [looperPresetPath retain];
    
    NSString* basePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"www"];
    [basePath retain];
    
    NSString* path = [NSString stringWithFormat:@"%@/%@", basePath, drumMachinePresetPath];
    [path retain];
    NSLog(@"MPD: NATIVE:AudioEngine::initialize drum machine preset from %@.", path);
    if ([[NSFileManager defaultManager] fileExistsAtPath : path])
    {
        engine.setDrumPreset([path UTF8String]);
    }
    [path release];
    
    path = [NSString stringWithFormat:@"%@/%@", basePath, looperPresetPath];
    [path retain];
    NSLog(@"MPD: NATIVE:AudioEngine::initialize looper preset from %@.", path);
    if ([[NSFileManager defaultManager] fileExistsAtPath : path])
    {
        engine.setLooperPreset([path UTF8String]);
    }
    [path release];
    
    [basePath release];
    [looperPresetPath release];
    [drumMachinePresetPath release];
    [callbackID release];
}

- (void) playTestTone: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
	NSLog(@"MPD: NATIVE: Playing test tone");
    engine.playTestTone();
}

- (void) auditionDrum: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    NSString* callbackID = [arguments pop];
    [callbackID retain];
    
    NSString *drumSound = [arguments pop];
    [drumSound retain];
    
	NSLog(@"MPD: NATIVE: Auditioning drum: %@", drumSound);
    engine.auditionDrum(String([drumSound UTF8String]));
    
    [drumSound release];
    [callbackID release];
}

- (void) setDrumPattern:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options {
    NSString* callbackId = [arguments pop];
    [callbackId retain];
    
    NSString *patternJson = [arguments pop];
    [patternJson retain];
    
	NSLog(@"MPD: NATIVE: AudioEngine::setDrumPattern: setting drum pattern to: %@", patternJson);
    engine.setDrumPattern([patternJson UTF8String]);
    
    // the pattern is sent simply in the form of JSON for now.
    [patternJson release];
    [callbackId release];
}

- (void) play: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
	NSLog(@"MPD: NATIVE: AudioEngine::play");
    engine.play();
}

- (void) stop: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
	NSLog(@"MPD: NATIVE: AudioEngine::stop");
    engine.stop();
} 

// TODO: we need to set up a path through which the C++ sequencer code, from the sequencer thread,
// can invoke the callback below. That means we need to learn how to have a C++ object call a
// method on an Objective-C object!
- (void) setCursorCallback: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    cursorCallbackId = [arguments pop];
    [cursorCallbackId retain];  // do we need this?
}

- (void) setLoop: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    NSString* callbackId = [arguments pop];
    [callbackId retain];
    
    NSString *patternJson = [arguments pop];
    [patternJson retain];
    
	NSLog(@"MPD: NATIVE: AudioEngine::setDrumPattern: setting drum pattern to: %@", patternJson);
    engine.setDrumPattern([patternJson UTF8String]);
    
    // the pattern is sent simply in the form of JSON for now.
    [patternJson release];
    [callbackId release];
    
}

- (void) toggleLoop: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    NSString* callbackId = [arguments pop];
    [callbackId retain];
    
    NSString *group = [arguments pop];
    [group retain];
    
    NSNumber *oix = [arguments pop];
    [oix retain];
    int ix = [oix intValue];
    [oix release];
    
	NSLog(@"MPD: NATIVE: AudioEngine::toggleLoop: setting to: %@, %d", group, ix);
    engine.toggleLoop([group UTF8String], ix);
    
    [group release];
    [callbackId release];
    
}

@end
