#import "GyroController.h"
#import "AudioEngineImpl.h"


@implementation GyroController {
	AudioEngineImpl* audioEngine;
}

//@synthesize image;

- (void) setAudioEngine: (void *)engine {
//	NSLog(@"Gyro: setting audio engine..");
	audioEngine = (AudioEngineImpl*)engine;
	motionManager = [[CMMotionManager alloc] init];
	[motionManager retain];
	lastX = lastY = lastZ = 0;
}

-(void)toggleUpdates {
	if (!on) {
//		NSLog(@"Initializing gyroscope.");
		[motionManager startDeviceMotionUpdates];
		
		// Seems like it works with this background thread nonsense.
		thread = [[NSThread alloc] initWithTarget:self selector:@selector(doGyroUpdate) object:nil];
		[thread retain];
		[thread start];
		
//		dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//		dispatch_source_t timerSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, backgroundQueue);
//		dispatch_source_set_timer(timerSource, dispatch_time(DISPATCH_TIME_NOW, 0), 0.050*NSEC_PER_SEC, 0*NSEC_PER_SEC);
//		dispatch_source_set_event_handler(timerSource, ^{
//			[self doGyroUpdate];
//		});
//		dispatch_resume(timerSource);
		
//		timer = [NSTimer scheduledTimerWithTimeInterval:1.0/20.0
//												 target:self
//											   selector:@selector(doGyroUpdate)
//											   userInfo:nil
//												repeats:YES];
//		[timer retain];
//		[[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];

	} else {
//		NSLog(@"Stopping. gyroscope.");
		[motionManager stopDeviceMotionUpdates];
		[motionManager release];
//		[timer invalidate];
	}
	on = !on;
}

-(void)doGyroUpdate {
	while (true) {
		float pitch = motionManager.deviceMotion.attitude.pitch;
		float PI = 3.1415297;
		float x = 2.0 * (pitch - 0.5*PI) / 1.5 / PI;
		if (x > 1)
			x = 1;
		if (x < 0)
			x = 0;
		
//		float y = 
		
		float newX = motionManager.deviceMotion.userAcceleration.x;
		float newY = motionManager.deviceMotion.userAcceleration.y;
		float newZ = motionManager.deviceMotion.userAcceleration.z;
		
		float dF = (newX - lastX)*(newX - lastX) + (newY - lastY)*(newY - lastY) + (newZ - lastZ)*(newZ - lastZ);
		dF = sqrt(dF);
		
//		NSLog(@"dF=%f", dF);
		
		auto& mixer = audioEngine->getMixer();
		
		auto filter = mixer.getMasterFilter();
		auto crusher = mixer.getMasterCrusher();
		
		if (filter == nullptr || crusher == nullptr)
			continue;
		
		if (dF > 1.5) {
			if (filter->isEnabled()) {
				filter->setEnabled(false);
	//			NSLog(@"Setting FILTER off from motion");
			}
			if (crusher->isEnabled()) {
				crusher->setEnabled(false);
	//			NSLog(@"Setting CRUSHER off from motion");
			}
		}
		
		if (mixer.getMasterCrusher()->isEnabled()) {
			// CRUSHER
			auto& effect = *mixer.getMasterCrusher();
			auto parms = effect.getParams();
			parms.rate = 0.02 + 0.98*x;
//			NSLog(@"Raw x-rotation rate: %f; Parms.rate: %f", x, parms.rate);
			effect.setParams(parms);
		}
		if (mixer.getMasterFilter()->isEnabled()) {
			// FILTER
			auto& effect = *mixer.getMasterFilter();
			auto parms = effect.getParams();
			parms.cutoff = 50 + (10000.0 - 50.0)*x;
//			NSLog(@"Raw x-rotation rate: %f; Parms.rate: %f", x, parms.cutoff);
			effect.setParams(parms);
		}
		
		lastX = newX;
		lastY = newY;
		lastZ = newZ;
		
		[NSThread sleepForTimeInterval:0.05];
	}
}

- (void)dealloc {
	[motionManager release];
//	self.image = nil;
    [super dealloc];
}

@end
