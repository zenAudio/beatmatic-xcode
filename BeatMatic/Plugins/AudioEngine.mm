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
#import "GyroController.h"

@implementation AudioEngine {
    AudioEngineImpl engine;
}

//@synthesize gyroController;

- (void) initialise: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    cursorCallbackId = nil;
	
//	NSLog(@"MPD: NATIVE: AudioEngine::initializing gyro.");
	gyroController = [[GyroController alloc] init];
	[gyroController retain];
	[gyroController setAudioEngine: &engine objc: self];
	[gyroController toggleUpdates];
    
//	NSLog(@"MPD: NATIVE: AudioEngine::initialize: Reading drum preset.");
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
//    NSLog(@"MPD: NATIVE:AudioEngine::initialize drum machine preset from %@.", path);
    if ([[NSFileManager defaultManager] fileExistsAtPath : path])
    {
        engine.setDrumPreset([path UTF8String]);
    }
    [path release];
    
    path = [NSString stringWithFormat:@"%@/%@", basePath, looperPresetPath];
    [path retain];
//    NSLog(@"MPD: NATIVE:AudioEngine::initialize looper preset from %@.", path);
    if ([[NSFileManager defaultManager] fileExistsAtPath : path])
    {
        engine.setLooperPreset([path UTF8String]);
    }
    [path release];
    
//    NSLog(@"MPD: NATIVE: AudioEngine::initialize: Initializing audio engine.");
    engine.init(self);
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [pluginResult retain];
    [self writeJavascript: [pluginResult toSuccessCallbackString:callbackID]];
    [pluginResult release];
        
//    NSLog(@"MPD: SELF: %x", (int) self);
//    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(cursorCb:) userInfo: nil repeats:YES];
    
    [basePath release];
    [looperPresetPath release];
    [drumMachinePresetPath release];
    [callbackID release];
}

- (void) playTestTone: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
//	NSLog(@"MPD: NATIVE: Playing test tone");
    engine.playTestTone();
}

- (void) auditionDrum: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    NSString* callbackID = [arguments pop];
    [callbackID retain];
    
    NSString *drumSound = [arguments pop];
    [drumSound retain];
    
//	NSLog(@"MPD: NATIVE: Auditioning drum: %@", drumSound);
    engine.auditionDrum(String([drumSound UTF8String]));
    
    [drumSound release];
    [callbackID release];
}

- (void) setDrumPattern:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options {
    NSString* callbackId = [arguments pop];
    [callbackId retain];
    
    NSString *patternJson = [arguments pop];
    [patternJson retain];
    
//	NSLog(@"MPD: NATIVE: AudioEngine::setDrumPattern: setting drum pattern to: %@", patternJson);
    engine.setDrumPattern([patternJson UTF8String]);
    
    // the pattern is sent simply in the form of JSON for now.
    [patternJson release];
    [callbackId release];
}

- (void) play: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
//	NSLog(@"MPD: NATIVE: AudioEngine::play");
    engine.getTransport().play();
}

- (void) stop: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
//	NSLog(@"MPD: NATIVE: AudioEngine::stop");
    engine.getTransport().stop();
} 

// TODO: we need to set up a path through which the C++ sequencer code, from the sequencer thread,
// can invoke the callback below. That means we need to learn how to have a C++ object call a
// method on an Objective-C object!
- (void) setCursorCallback: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    cursorCallbackId = [arguments pop];
    [cursorCallbackId retain];  // do we need this?
    
//	NSLog(@"MPD: NATIVE: Obj-c: Setting cursor callback.");
    engine.setCursorUpdateCallback([cursorCallbackId UTF8String]);
    
    [cursorCallbackId release];
}

- (void) setShakeCallback: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    NSString *callbackId = [arguments pop];
    [callbackId retain];  // do we need this?

	[gyroController setShakeCallback:callbackId];
    
    [callbackId release];
}


// TODO: we need to set up a path through which the C++ sequencer code, from the sequencer thread,
// can invoke the callback below. That means we need to learn how to have a C++ object call a
// method on an Objective-C object!
- (void) turnOffCursorCallback: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
//	NSLog(@"MPD: NATIVE: Obj-c: Setting cursor callback OFF");
    engine.setCursorUpdateCallback(nullptr);
}

- (void) setAudioInputLevelCallback:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options {
    NSString* callbackId = [arguments pop];
    [callbackId retain];  // do we need this?
    
//	NSLog(@"MPD: NATIVE: Obj-c: Setting audio input level callback.");
    engine.getInputMeter().setPhoneGapCallbackId([callbackId UTF8String]);
    
    [callbackId release];
}

- (void) turnOffAudioInputLevelCallback:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options {
	//	NSLog(@"MPD: NATIVE: Obj-c: Setting audio input level callback.");
    engine.getInputMeter().setPhoneGapCallbackId(nullptr);
}


- (void) setLoop: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    NSString* callbackId = [arguments pop];
    [callbackId retain];
    
    NSString *patternJson = [arguments pop];
    [patternJson retain];
    
//	NSLog(@"MPD: NATIVE: AudioEngine::setDrumPattern: setting drum pattern to: %@", patternJson);
    engine.setDrumPattern([patternJson UTF8String]);
    
    // the pattern is sent simply in the form of JSON for now.
    [patternJson release];
    [callbackId release];
    
}

- (void) muteDrumVoice: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
	[arguments pop];
    
    NSString *voice = [arguments pop];
    [voice retain];
	
	NSNumber *state = [arguments pop];
	[state retain];
	
	auto& dm = engine.getMixer().getDrumMachine();
	
	bool onOff = [state intValue] != 0;
	
	if ([voice isEqualToString: @"basic beat"]) {
		dm.muteVoice("kick drum", onOff);
		dm.muteVoice("snare drum", onOff);
	} else {
		dm.muteVoice([voice UTF8String], onOff);
	}
    
	[state release];
    [voice release];
}

- (void) toggleLoopScene: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    NSString* callbackId = [arguments pop];
    [callbackId retain];
    
    NSString *group = [arguments pop];
    [group retain];
	
	auto& lm = engine.getMixer().getLoopMachine();
	lm.toggleLoopScene([group UTF8String]);
    
    [group release];
    [callbackId release];
}

- (void) toggleLoop: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    [arguments pop];
    
    NSString *group = [arguments pop];
    [group retain];
    
    NSNumber *oix = [arguments pop];
    [oix retain];
    int ix = [oix intValue];
    [oix release];
    
	//	NSLog(@"MPD: NATIVE: AudioEngine::toggleLoop: setting to: %@, %d", group, ix);
    engine.toggleLoop([group UTF8String], ix);
    
    [group release];
}

- (void) setBpm: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    NSString* callbackId = [arguments pop];
    [callbackId retain];
    
    NSNumber *bpm = [arguments pop];
	if (bpm != nil && bpm != (id) [NSNull null]) {
		[bpm retain];
		
		engine.getTransport().setBpm([bpm floatValue]);
		
		[bpm release];
	}
    [callbackId release];
}

- (void) recordAudioStart:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options {
    [arguments pop];    // don't need the callback id.
    
    NSString *filename = [arguments pop];
    [filename retain];
    
//    NSLog(@"MPD: NATIVE: AudioEngine::: recording audio to %@", filename);
    engine.recordAudioStart([filename UTF8String]);
    
    [filename release];
}

- (void) recordAudioStop:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options {
    NSString* callbackId = [arguments pop];
    [callbackId retain];
    
//    NSLog(@"MPD: NATIVE: AudioEngine::: recording audio STOP, callback id: %@",callbackId);
    engine.recordAudioStop([callbackId UTF8String]);
    
    [callbackId release];
}

- (void) playSample:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options {
    NSString* callbackId = [arguments pop];
    [callbackId retain];
    
    NSString *filename = [arguments pop];
    [filename retain];
    
//    NSLog(@"MPD: NATIVE: AudioEngine::: playing audio recording %@", filename);
    engine.playSample([filename UTF8String], [callbackId UTF8String]);
   
    [filename release];
    [callbackId release];
}

- (void) stopSample:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options {
    [arguments pop];
    
//    NSLog(@"MPD: NATIVE: AudioEngine::: stopping audio sample playback.");
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
//    NSLog(@"HALLO");
}

void InvokePhoneGapCallback(void *objcSelf, const char* const callbackId, const char* const jsonMsg) {
    NSString* json = [[NSString alloc] initWithUTF8String:jsonMsg];
    [json retain];
    NSString* callback = [[NSString alloc] initWithUTF8String: callbackId];
    [callback retain];
    [(id) objcSelf invokePhoneGapCallback: callback withResponse: json];
    [callback release];
    [json release];
}

- (void) setMasterFilter:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options {
    [arguments pop];
    
    NSString* opts = [arguments pop];
    [opts retain];
//    NSLog(@"MPD: NATIVE: Obj-C: setMasterFilter: %@", opts);
    var filtParms = JSON::parse(String([opts UTF8String]));
    String type = filtParms["type"];
    
    IIRFilter filter;
    
    var fopt = filtParms["options"];
    /*
    if (type.equalsIgnoreCase("inactive")) {
        filter.makeInactive();
    } else if (type.equalsIgnoreCase("lp")) {
        filter.makeLowPass(engine.getTransport().getSampleRate(), fopt["cutoff"]);
    } else if (type.equalsIgnoreCase("hp")) {
        filter.makeHighPass(engine.getTransport().getSampleRate(), fopt["cutoff"]);
    } else if (type.equalsIgnoreCase("bp")) {
        filter.makeBandPass(engine.getTransport().getSampleRate(), fopt["cutoff"],
                            fopt["Q"], fopt["gain"]);
    } else if (type.equalsIgnoreCase("ls")) {
        filter.makeLowShelf(engine.getTransport().getSampleRate(), fopt["cutoff"],
                            fopt["Q"], fopt["gain"]);
    } else if (type.equalsIgnoreCase("hs")) {
        filter.makeHighShelf(engine.getTransport().getSampleRate(), fopt["cutoff"],
                             fopt["Q"], fopt["gain"]);
    }
	*/
	FilterEffect::Parameters p;
	p.cutoff = fopt["cutoff"];
    engine.getMixer().getMasterFilter()->setParams(p);
    [opts release];
}

- (void) setMasterVerb:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options {
    [arguments pop];
    /*
    float 	roomSize
 	Room size, 0 to 1.0, where 1.0 is big, 0 is small.
    float 	damping
 	Damping, 0 to 1.0, where 0 is not damped, 1.0 is fully damped.
    float 	wetLevel
 	Wet level, 0 to 1.0.
    float 	dryLevel
 	Dry level, 0 to 1.0.
    float 	width
 	Reverb width, 0 to 1.0, where 1.0 is very wide.
    float 	freezeMode
    */
    
    NSString* opts = [arguments pop];
    [opts retain];
//    NSLog(@"MPD: NATIVE: Obj-C: setMasterVerb: %@", opts);
    
    var parms = JSON::parse(String([opts UTF8String]));
    
    auto& verb = *engine.getMixer().getMasterVerb();
    auto rparams = verb.getParameters();
    
    rparams.roomSize = parms.getProperty("roomSize", verb.getParameters().roomSize);
    rparams.damping = parms.getProperty("damping", verb.getParameters().damping);
    rparams.wetLevel = parms.getProperty("wetLevel", verb.getParameters().wetLevel);
    rparams.dryLevel = parms.getProperty("dryLevel", verb.getParameters().dryLevel);
    rparams.width = parms.getProperty("width", verb.getParameters().width);
    rparams.freezeMode = parms.getProperty("freezeMode", verb.getParameters().freezeMode);

    engine.getMixer().getMasterVerb()->setParameters(rparams);
    
    [opts release];
}

- (void) setMasterCrusher:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options {
    [arguments pop];
    
    NSString* optsObj = [arguments pop];
    [optsObj retain];
    
//    NSLog(@"MPD: NATIVE: Obj-c: AudioEngine::setMasterCrusher");
    auto& crusher = *engine.getMixer().getMasterCrusher();
    var opts = JSON::parse(String([optsObj UTF8String]));
    
    auto parms = crusher.getParams();
    parms.bits = opts["bits"];
    parms.rate = opts["rate"];
    
    crusher.setParams(parms);
    
    [optsObj release];
}

- (void) setMasterCrusherEnabled: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    [arguments pop];
	
	NSNumber* onOffObj = [arguments pop];
	[onOffObj retain];
	
	//    NSLog(@"MPD: NATIVE: Obj-c: AudioEngine::setMasterCrusher");
    auto& crusher = *engine.getMixer().getMasterCrusher();
	crusher.setEnabled([onOffObj intValue] == 0 ? false : true);
	
	[onOffObj release];
}

- (void) setMasterFilterEnabled: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
	[arguments pop];
	
	NSNumber* onOffObj = [arguments pop];
	[onOffObj retain];
	
	//    NSLog(@"MPD: NATIVE: Obj-c: AudioEngine::setMasterCrusher");
    auto& crusher = *engine.getMixer().getMasterFilter();
	crusher.setEnabled([onOffObj intValue] == 0 ? false : true);
	
	[onOffObj release];
}

- (void) setOneShotFinishedPlayingCallback: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    NSString* callbackId = [arguments pop];
    [callbackId retain];
    
    NSString *group = [arguments pop];
    [group retain];
    
    NSNumber *oix = [arguments pop];
    [oix retain];
    int ix = [oix intValue];
    [oix release];
    
//	NSLog(@"MPD: NATIVE: AudioEngine::setOneShotFinishedPlayingCallback: setting to: %@, %d", group, ix);
	LoopMachine& lm = engine.getMixer().getLoopMachine();
    lm.setOneShotFinishedPlayingCallback(lm.groupIx([group UTF8String]), ix, String([callbackId UTF8String]));
    
    [group release];
    [callbackId release];
}

@end
