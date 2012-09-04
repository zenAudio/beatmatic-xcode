#import <AudioToolbox/AudioServices.h>
#import <Cordova/CDV.h>

@interface SoundPlug : CDVPlugin {
}

- (void) play:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

@end
