//
//  AudioEngine.m
//  BeatMatic
//
//  Created by Martin Percossi on 08.09.12.
//
//

#import "AudioEngine.h"
#import "AudioEngineImpl.h"
#import "objctrampoline.h"

@implementation AudioEngine {
    AudioEngineImpl engine;
}

- (void) initialise: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    cursorCallbackId = nil;
    
	NSLog(@"MPD: NATIVE: AudioEngine::initialize: Initializing audio engine.");
    engine.init(self);
    
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
    
//    NSLog(@"MPD: SELF: %x", (int) self);
//    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(cursorCb:) userInfo: nil repeats:YES];
    
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
    engine.getTransport().play();
}

- (void) stop: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
	NSLog(@"MPD: NATIVE: AudioEngine::stop");
    engine.getTransport().stop();
} 

// TODO: we need to set up a path through which the C++ sequencer code, from the sequencer thread,
// can invoke the callback below. That means we need to learn how to have a C++ object call a
// method on an Objective-C object!
- (void) setCursorCallback: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    cursorCallbackId = [arguments pop];
    [cursorCallbackId retain];  // do we need this?
    
	NSLog(@"MPD: NATIVE: Obj-c: Setting cursor callback.");
    engine.setCursorUpdateCallback([cursorCallbackId UTF8String]);
    
    [cursorCallbackId release];
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

- (void) setBpm: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    NSString* callbackId = [arguments pop];
    [callbackId retain];
    
    NSNumber *bpm = [arguments pop];
    [bpm retain];
    
    engine.getTransport().setBpm([bpm floatValue]);
    
    [bpm release];
    [callbackId release];
}

- (void) recordAudioStart:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options {
    [arguments pop];    // don't need the callback id.
    
    NSString *filename = [arguments pop];
    [filename retain];
    
    NSLog(@"MPD: NATIVE: AudioEngine::: recording audio to %@", filename);
    engine.recordAudioStart([filename UTF8String]);
    
    [filename release];
}

- (void) recordAudioStop:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options {
    NSString* callbackId = [arguments pop];
    [callbackId retain];
    
    NSLog(@"MPD: NATIVE: AudioEngine::: recording audio STOP, callback id: %@",callbackId);
    engine.recordAudioStop([callbackId UTF8String]);
    
    [callbackId release];
}

- (void) playSample:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options {
    NSString* callbackId = [arguments pop];
    [callbackId retain];
    
    NSString *filename = [arguments pop];
    [filename retain];
    
    NSLog(@"MPD: NATIVE: AudioEngine::: playing audio recording %@", filename);
    engine.playSample([filename UTF8String], [callbackId UTF8String]);
   
    [filename release];
    [callbackId release];
}

- (void) stopSample:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options {
    [arguments pop];
    
    NSLog(@"MPD: NATIVE: AudioEngine::: stopping audio sample playback.");
    engine.stopSample();
}


- (void) getBpm: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
}

- (void) invokePhoneGapCallback:(NSString *)callbackId withResponse:(NSString*)jsonResponse {
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:jsonResponse];
    [pluginResult retain];
    [pluginResult setKeepCallback:[NSNumber numberWithBool:true]];
    [self writeJavascript: [pluginResult toSuccessCallbackString:callbackId]];
    [pluginResult release];
}

- (void) cursorCb {
    NSLog(@"HALLO");
}

void InvokePhoneGapCallback(void *objcSelf, const char* const callbackId, const char* const jsonMsg) {
    [(id) objcSelf invokePhoneGapCallback:[[NSString alloc] initWithUTF8String: callbackId] withResponse: [[NSString alloc] initWithUTF8String:jsonMsg]];
}


@end
