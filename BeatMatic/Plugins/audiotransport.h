//
//  audiotransport.h
//  BeatMatic
//
//  Created by Martin Percossi on 12.09.12.
//
//

#ifndef __BeatMatic__audiotransport__
#define __BeatMatic__audiotransport__

#include <iostream>
#include "juce.h"

class AudioTransport : public ChangeBroadcaster {
public:
    AudioTransport();
    
    void updateTransport(int numSamplesInFrame);
    
    // Transport
    void play();
    void stop();
    
    void setTransport(int timeSamples);
    
    void setBpm(float bpm);
    float getBpm() const;
    
    bool isPlaying() const;
    
    float getSampleRate() const;
    void setSampleRate(float sampleRate);
    
    int getFrameStartSamples() const;
    int getFrameEndSamples() const;
    
    float getFrameStartTicks() const;
    float getFrameEndTicks() const;
    
    void setLatency(int latency);
    int getLatency() const;
    
    int getCurrPosTicks() const;
    int getCurrPosBeats() const;
    int getCurrPosBars() const;
    
    // Utility
    float samplesToTicks(float t_samples) const;
    float ticksToSamples(float t_ticks) const;
    float millisToSamples(float t_millis) const;
    float samplesToMillis(float t_samples) const;
    float millisToTicks(float t_millis) const;
    float ticksToMillis(float t_ticks) const;

private:
    volatile int t_frames;
    volatile int t_samples;
    
    volatile int latencySamples;
    
    volatile float sampleRate;
    volatile float bpm;
    volatile int frameStartSamples;
    volatile int frameEndSamples;
    volatile bool playing;
};

#endif /* defined(__BeatMatic__audiotransport__) */
