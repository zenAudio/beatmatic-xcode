//
//  DiracAudioPlayerExampleViewController.m
//  DiracAudioPlayerExample
//
//  Created by Stephan on 20.03.11.
//  Copyright 2011 The DSP Dimension. All rights reserved.
//

#import "DiracAudioPlayerExampleViewController.h"


@implementation DiracAudioPlayerExampleViewController

// ---------------------------------------------------------------------------------------------------------------------------------------------

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/
// ---------------------------------------------------------------------------------------------------------------------------------------------

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/
- (void)diracPlayerDidFinishPlaying:(DiracAudioPlayerBase *)player successfully:(BOOL)flag
{
	NSLog(@"Dirac player instance (0x%lx) is done playing", (long)player);
}

// ---------------------------------------------------------------------------------------------------------------------------------------------

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];

	NSString *inputSound  = [[NSBundle mainBundle] pathForResource:  @"song" ofType: @"aif"];
	NSURL *inUrl = [NSURL fileURLWithPath:inputSound];
	
	NSError *error = nil;
	mDiracAudioPlayer = [[DiracAudioPlayer alloc] initWithContentsOfURL:inUrl channels:1 error:&error];		// LE only supports 1 channel!
	[mDiracAudioPlayer setDelegate:self];
	[mDiracAudioPlayer setNumberOfLoops:1];

	mUseVarispeed = NO;
}

// ---------------------------------------------------------------------------------------------------------------------------------------------

-(IBAction)uiDurationSliderMoved:(UISlider *)sender;
{
	[mDiracAudioPlayer stop];	// only required in LE!
	[mDiracAudioPlayer changeDuration:sender.value];
	uiDurationLabel.text = [NSString stringWithFormat:@"%3.2f", sender.value];

	if (mUseVarispeed) {
		float val = 1.f/sender.value;
		uiPitchSlider.value = (int)12.f*log2f(val);
		uiPitchLabel.text = [NSString stringWithFormat:@"%d", (int)uiPitchSlider.value];
		[mDiracAudioPlayer changePitch:val];
	}
	[mDiracAudioPlayer play];	// only required in LE!
	
}
// ---------------------------------------------------------------------------------------------------------------------------------------------

-(IBAction)uiPitchSliderMoved:(UISlider *)sender;
{
	[mDiracAudioPlayer stop];	// only required in LE!
	[mDiracAudioPlayer changePitch:powf(2.f, (int)sender.value / 12.f)];
	uiPitchLabel.text = [NSString stringWithFormat:@"%d", (int)sender.value];
	[mDiracAudioPlayer play];	// only required in LE!
}
// ---------------------------------------------------------------------------------------------------------------------------------------------

-(IBAction)uiStartButtonTapped:(UIButton *)sender;
{
	[mDiracAudioPlayer play];
}
// ---------------------------------------------------------------------------------------------------------------------------------------------

-(IBAction)uiStopButtonTapped:(UIButton *)sender;
{
	[mDiracAudioPlayer stop];
}
// ---------------------------------------------------------------------------------------------------------------------------------------------

-(IBAction)uiVarispeedSwitchTapped:(UISwitch *)sender;
{
	[mDiracAudioPlayer stop];	// only required in LE!
	if (sender.on) {
		mUseVarispeed = YES;

		uiPitchSlider.enabled=NO;

		float val = 1.f/uiDurationSlider.value;
		uiPitchSlider.value = (int)12.f*log2f(val);
		uiPitchLabel.text = [NSString stringWithFormat:@"%d", (int)uiPitchSlider.value];
		[mDiracAudioPlayer changePitch:val];		
		
	} else {
		mUseVarispeed = NO;
		uiPitchSlider.enabled=YES;
	}
	[mDiracAudioPlayer play];	// only required in LE!
}
// ---------------------------------------------------------------------------------------------------------------------------------------------

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/
// ---------------------------------------------------------------------------------------------------------------------------------------------

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}
// ---------------------------------------------------------------------------------------------------------------------------------------------

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

// ---------------------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
	[mDiracAudioPlayer release];
    [super dealloc];
}

// ---------------------------------------------------------------------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------------------------------------------------------------------




@end
