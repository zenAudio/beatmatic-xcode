//
//  moogfiltereffect.cpp
//  BeatMatic
//
//  Created by Martin Percossi on 10/2/12.
//
//

#include "moogfiltereffect.h"

//#include <math>

/*
 //Init
 cutoff = cutoff freq in Hz
 fs = sampling frequency //(e.g. 44100Hz)
 res = resonance [0 - 1] //(minimum - maximum)
 
 f = 2 * cutoff / fs; //[0 - 1]
 k = 3.6*f - 1.6*f*f -1; //(Empirical tunning)
 p = (k+1)*0.5;
 scale = e^((1-p)*1.386249;
 r = res*scale;
 y4 = output;
 
 y1=y2=y3=y4=oldx=oldy1=oldy2=oldy3=0;
 
 //Loop
 //--Inverted feed back for corner peaking
 x = input - r*y4;
 
 //Four cascaded onepole filters (bilinear transform)
 y1=x*p + oldx*p - k*y1;
 y2=y1*p+oldy1*p - k*y2;
 y3=y2*p+oldy2*p - k*y3;
 y4=y3*p+oldy3*p - k*y4;
 
 //Clipper band limited sigmoid
 y4 = y4 - (y4^3)/6;
 
 oldx = x;
 oldy1 = y1;
 oldy2 = y2;
 oldy3 = y3;
*/

MoogFilterEffect::MoogFilterEffect() {
}

void MoogFilterEffect::setParams(float frequency, float resonance) {
}

void MoogFilterEffect::prepareToPlay(int samplesPerBlockExpected, double sampleRate) {
}

void MoogFilterEffect::releaseResources() {	
}

void MoogFilterEffect::getNextAudioBlock(const AudioSourceChannelInfo& bufferToFill) {
	auto& buf = *bufferToFill.buffer;
	
	
}
