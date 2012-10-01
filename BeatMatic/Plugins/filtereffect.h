//
//  filtereffect.h
//  BeatMatic
//
//  Created by Martin Percossi on 10/1/12.
//
//

#ifndef __BeatMatic__filtereffect__
#define __BeatMatic__filtereffect__

#include "JuceHeader.h"

class FilterEffect : public AudioSource {
public:
	struct Parameters {
		float cutoff;
		float resonance;
	};
public:
	FilterEffect(AudioSource* inputSource, bool deleteInputWhenDeleted);
    ~FilterEffect();
    
    void setParams(const Parameters& newSettings);
    const Parameters& getParams() const;
    
    void prepareToPlay (int samplesPerBlockExpected, double sampleRate);
    void releaseResources();
    void getNextAudioBlock (const AudioSourceChannelInfo& bufferToFill);

	void setEnabled(bool enabled);
	bool isEnabled() const;
	
private:
	Parameters params;
	IIRFilterAudioSource impl;
	AudioSource* src;
	bool enabled;
	double sampleRate;	
};

#endif /* defined(__BeatMatic__filtereffect__) */
