//
//  limitereffect.h
//  BeatMatic
//
//  Created by Martin Percossi on 9/15/12.
//
//

#ifndef __BeatMatic__limitereffect__
#define __BeatMatic__limitereffect__

#include "juce.h"
#include "audioringbuffer.h"

class LimiterEffect : public AudioSource {
public:
    
    static const int NUM_OUTPUT_CHANNELS = 2;
    
    struct Parameters {
        Parameters() {
            threshold = 0.6;
            slope = 0.9;
            sampleRate = 44100;
            lookAhead = 10;
            rmsDecay = 0.001;
            attack = 0.1;
            release = 0.1;
        }
        double  threshold;  // threshold (percents)
        double  slope;      // slope angle (percents)
        int     sampleRate;         // sample rate (smp/sec)
        double  lookAhead;        // lookahead  (ms)
        double  rmsDecay;       // window time (ms)
        double  attack;       // attack time  (ms)
        double  release;       // release time (ms)
    };
    
public:
    
    LimiterEffect(AudioSource* inputSource, bool deleteInputWhenDeleted);
    ~LimiterEffect();
    
    void setParams(const Parameters& newSettings);
    const Parameters& getParams() const;
    
    void prepareToPlay (int samplesPerBlockExpected, double sampleRate);
    void releaseResources();
    void getNextAudioBlock (const AudioSourceChannelInfo& bufferToFill);
    
private:
    AudioSource* src;
    Parameters parms;
    float meanSquare;
    bool deleteInputWhenDeleted;
    AudioRingBuffer buf;
    int n;
};

#endif /* defined(__BeatMatic__limitereffect__) */
