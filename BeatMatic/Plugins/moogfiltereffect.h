//
//  moogfiltereffect.h
//  BeatMatic
//
//  Created by Martin Percossi on 10/2/12.
//
//

#ifndef __BeatMatic__moogfiltereffect__
#define __BeatMatic__moogfiltereffect__

#include "juce.h"

class MoogFilterEffect : public AudioSource {
public:
	
	struct Parameters {
		float cutoff;
		float resonance;
	};
	
public:
	MoogFilterEffect();
	virtual ~MoogFilterEffect() {}
	virtual void prepareToPlay(int samplesPerBlockExpected, double sampleRate);
    virtual void releaseResources();
    virtual void getNextAudioBlock(const AudioSourceChannelInfo& bufferToFill);
	
//	const Parameters 
	
private:
	
	float f, p, q;             //filter coefficients
	float b0, b1, b2, b3, b4;  //filter buffers (beware denormals!)
	float t1, t2;              //temporary buffers

};

#endif /* defined(__BeatMatic__moogfiltereffect__) */
