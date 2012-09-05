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

- (void) play: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    NSLog(@"MPD: NATIVE: DiracPlayer: playing");
    if (player != nil) {
        [player play];
    } else {
        NSLog(@"MPD: ERROR: DiracPlayer: player is null.");
    }
}

- (void) stop: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    NSLog(@"MPD: NATIVE: DiracPlayer: stop.");
    if (player != nil) {
        [player stop];
    } else {
        NSLog(@"MPD: ERROR: DiracPlayer: player is null.");
    }
}

- (void) load: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    CDVPluginResult* pluginResult;
    NSString* callbackID = [arguments pop];
    [callbackID retain];
    
    NSString *assetPath = [arguments objectAtIndex:0];
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
        player = [[DiracFxAudioPlayer alloc] initWithContentsOfURL:url channels:1 error:&error];
        [player setNumberOfLoops:-1];   // play looped
        //        [player play];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString: CONTENT_LOAD_REQUESTED];
        [self writeJavascript: [pluginResult toSuccessCallbackString:callbackID]];
    }
    else
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: ERROR_NOT_FOUND];
        [self writeJavascript: [pluginResult toErrorCallbackString:callbackID]];
    }
    
    [path release];
    [basePath release];
    [assetPath release];
    [callbackID release];
}

- (void) changePitch: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    CDVPluginResult* pluginResult;
    NSString* callbackID = [arguments pop];
    [callbackID retain];
    
    NSNumber *pitch = [arguments objectAtIndex:0];
    [pitch retain];
    
    NSLog(@"MPD: NATIVE: DiracPlayer: changePitch: %@", pitch);
    
    if (player != nil) {
        [player changePitch:powf(2.f, ((float) [pitch intValue]) / 12.f)];
    } else {
        NSLog(@"MPD: ERROR: DiracPlayer: player is null.");
    }
    
    [pitch release];
}

- (void) changeDuration: (NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    CDVPluginResult* pluginResult;
    NSString* callbackID = [arguments pop];
    [callbackID retain];
    
    NSNumber *duration = [arguments objectAtIndex:0];
    [duration retain];
    
    NSLog(@"MPD: NATIVE: DiracPlayer: changeDuration: %@", duration);
    
    if (player != nil) {
        [player changeDuration:[duration floatValue]];
    } else {
        NSLog(@"MPD: ERROR: DiracPlayer: player is null.");
    }
    
    [duration release];
}


@end
