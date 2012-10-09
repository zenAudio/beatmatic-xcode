#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

@interface GyroController : NSObject {
	CMMotionManager *motionManager;
	NSTimer *timer;
	bool on;
	float lastX, lastY, lastZ;
	NSThread* thread;
	NSString* shakeCallbackId;
}

-(void)toggleUpdates;
- (void) setAudioEngine:(void *)engine objc:(id) objcEngine_;
- (void) setShakeCallback: (NSString *)callbackId;

@end

