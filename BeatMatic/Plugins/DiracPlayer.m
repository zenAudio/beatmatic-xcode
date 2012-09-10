//
//  DiracPlayer.m
//  BeatMatic
//
//  Created by Martin Percossi on 04.09.12.
//
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <AudioToolbox/AudioToolbox.h>

#import "DiracPlayer.h"

@implementation DiracPlayer

NSString* ERROR_NOT_FOUND = @"file not found";
NSString* ERROR_EXISTING_REFERENCE = @"a reference to the audio ID already exists";
NSString* ERROR_MISSING_REFERENCE = @"a reference to the audio ID does not exist";
NSString* CONTENT_LOAD_REQUESTED = @"content has been requested";
NSString* PLAY_REQUESTED = @"PLAY REQUESTED";
NSString* STOP_REQUESTED = @"STOP REQUESTED";
NSString* UNLOAD_REQUESTED = @"UNLOAD REQUESTED";
NSString* RESTRICTED = @"ACTION RESTRICTED FOR FX AUDIO";

- (void)diracPlayerDidFinishPlaying:(DiracAudioPlayerBase *)player successfully:(BOOL)flag
{
	NSLog(@"MPD: NATIVE: Dirac player instance (0x%lx) is done playing: %@", (long)player,
          [playerToSampleName objectForKey:[NSNumber numberWithUnsignedInt:[player hash]]]);
    NSString* callbackId = [playerToCallbackId objectForKey:[NSNumber numberWithUnsignedInt:[player hash]]];
    CDVPluginResult* pluginResult;
    if (flag) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }
    [self writeJavascript: [pluginResult toSuccessCallbackString:callbackId]];
}

- (void) diracInit: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    NSLog(@"MPD: NATIVE: DiracPlayer: initializing.");
    sampleNameToPlayer = [[NSMutableDictionary alloc] init];
    playerToSampleName = [[NSMutableDictionary alloc] init];
    playerToCallbackId = [[NSMutableDictionary alloc] init];
}

- (void) play: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    NSLog(@"MPD: NATIVE: DiracPlayer: playing");
    
    NSString* callbackID = [arguments pop];
    [callbackID retain];

    NSString *sampleName = [arguments objectAtIndex:0];
    [sampleName retain];
        
    NSNumber *startMs = [arguments objectAtIndex:1];
    [startMs retain];
    double time = [startMs doubleValue] / 1000.0;
    
    NSLog(@"MPD: NATIVE: Asked for delay of: %4.2lf seconds", time);
    
    DiracFxAudioPlayer *player = [sampleNameToPlayer objectForKey:sampleName];
    if (player != nil) {
        [playerToCallbackId setObject:callbackID forKey:[NSNumber numberWithUnsignedInt:[player hash]]];
        [player setCurrentTime:time];
        [player play];
     } else {
        NSLog(@"MPD: ERROR: DiracPlayer: play: player is null for: %@", sampleName);
    }
    
    [startMs release];
    [sampleName release];
    [callbackID release];
}

- (void) stop: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    NSLog(@"MPD: NATIVE: DiracPlayer: stop.");
    
    NSString* callbackID = [arguments pop];
    [callbackID retain];

    NSString *sampleName = [arguments objectAtIndex:0];
    [sampleName retain];
    
    DiracFxAudioPlayer *player = [sampleNameToPlayer objectForKey:sampleName];
    if (player != nil) {
        [player stop];
    } else {
        NSLog(@"MPD: ERROR: DiracPlayer: stop: player is null for sample: %@", sampleName);
    }
    [sampleName release];
    [callbackID release];
}

- (void) load: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    CDVPluginResult* pluginResult;
    
    NSString* callbackID = [arguments pop];
    [callbackID retain];
    
    NSString *sampleName = [arguments objectAtIndex:0];
    [sampleName retain];
    
    NSString *assetPath = [arguments objectAtIndex:1];
    [assetPath retain];
    
    NSString* basePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"www"];
    [basePath retain];
    
    NSString* path = [NSString stringWithFormat:@"%@/%@", basePath, assetPath];
    [path retain];
    
    NSLog(@"MPD: NATIVE: DiracPlayer: loading %@.", path);
    
    if ([[NSFileManager defaultManager] fileExistsAtPath : path])
    {
        NSURL *url = [NSURL fileURLWithPath: path];
        NSLog(@"MPD: NATIVE: DiracPlayer: loading: url is: %@", url);
        NSError *error = nil;
        DiracFxAudioPlayer *player = [[DiracFxAudioPlayer alloc] initWithContentsOfURL:url channels:1 error:&error];
        [player setDelegate:self];
        [player setNumberOfLoops:1];   // play looped
        [sampleNameToPlayer setObject:player forKey:sampleName];
        [playerToSampleName setObject:sampleName forKey:[NSNumber numberWithUnsignedInt:[player hash]]];
    }
    else
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: ERROR_NOT_FOUND];
        [self writeJavascript: [pluginResult toErrorCallbackString:callbackID]];
    }
    
    [path release];
    [basePath release];
    [assetPath release];
    [sampleName release];
    [callbackID release];
}

- (void) changePitch: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    NSString* callbackID = [arguments pop];
    [callbackID retain];
    
    NSString *sampleName = [arguments objectAtIndex:0];
    [sampleName retain];
    
    DiracFxAudioPlayer *player = [sampleNameToPlayer objectForKey:sampleName];
    
    NSNumber *pitch = [arguments objectAtIndex:1];
    [pitch retain];
    
    NSLog(@"MPD: NATIVE: DiracPlayer: changePitch: %@", pitch);
    
    if (player != nil) {
        [player changePitch:powf(2.f, ((float) [pitch intValue]) / 12.f)];
    } else {
        NSLog(@"MPD: ERROR: DiracPlayer: changePitch: player is null for sample: %@", sampleName);
    }
    
    [pitch release];
    [sampleName release];
    [callbackID release];
}

- (void) changeDuration: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    NSString* callbackID = [arguments pop];
    [callbackID retain];
    
    NSString *sampleName = [arguments objectAtIndex:0];
    [sampleName retain];
    
    DiracFxAudioPlayer *player = [sampleNameToPlayer objectForKey:sampleName];
    
    NSNumber *duration = [arguments objectAtIndex:1];
    [duration retain];
    
    NSLog(@"MPD: NATIVE: DiracPlayer: changeDuration: %@", duration);
    
    if (player != nil) {
        [player changeDuration:[duration floatValue]];
    } else {
        NSLog(@"MPD: ERROR: DiracPlayer: changeDuration: player is null for sample: %@", sampleName);
    }
    
    [duration release];
    [sampleName release];
    [callbackID release];
}


@end
