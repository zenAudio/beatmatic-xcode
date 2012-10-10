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
	virtual void setParams(float frequency, float resonance);

//	const Parameters 
	
private:
	
	float cutoff;	// = cutoff freq in Hz
	float fs;		// = sampling frequency //(e.g. 44100Hz)
	float res;		// = resonance [0 - 1] //(minimum - maximum)

};

#endif /* defined(__BeatMatic__moogfiltereffect__) */
