//
//  crushereffect.h
//  BeatMatic
//
//  Created by Martin Percossi on 9/17/12.
//
//

#ifndef __BeatMatic__crushereffect__
#define __BeatMatic__crushereffect__

#include "juce.h"

class CrusherEffect : public AudioSource {
public:
    static const int NUM_OUTPUT_CHANNELS = 2;
    
    struct Parameters {
        Parameters() {
            rate = 0.5;
            bits = 2;
        }
        float rate;
        int bits;
    };

public:
    CrusherEffect(AudioSource* inputSource, bool deleteInputWhenDeleted);
    ~CrusherEffect();
    
    void setParams(const Parameters& newSettings);
    const Parameters& getParams() const;
    
    void prepareToPlay (int samplesPerBlockExpected, double sampleRate);
    void releaseResources();
    void getNextAudioBlock (const AudioSourceChannelInfo& bufferToFill);

private:
    float decimate(float i);
    
private:
    long int m;
    float y, cnt;
    
    bool deleteInputWhenDeleted;
    AudioSource* src;
    Parameters parms;
};

#endif /* defined(__BeatMatic__crushereffect__) */
