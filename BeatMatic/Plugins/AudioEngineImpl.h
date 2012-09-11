//
//  AudioEngineImpl.h
//  BeatMatic
//
//  Created by Martin Percossi on 09.09.12.
//
//

#ifndef __BeatMatic__AudioEngineImpl__
#define __BeatMatic__AudioEngineImpl__

#include "juce.h"
#include "mixer.h"

struct AudioEngineException : public std::exception
{
    String s;
    AudioEngineException(String ss) : s(ss) {}
    const char* what() const throw() { return s.toUTF8(); }
};

class AudioEngineImpl {
public:
    
    AudioEngineImpl();
    void init();
    
    void playTestTone();
    
    void setDrumPreset(const char* const presetFilename);
    void setLooperPreset(const char* const presetFilename);
    void toggleLoop(const char* const group, int ix);
    void auditionDrum(String soundName);
    void setDrumPattern(const char* const patternJson);
    
    // Transport
    void play();
    void stop();
    void setBpm(float bpm);
    float getBpm() const;
    bool isPlaying() const;
    float getSampleRate() const;
    int getFrameStartSamples() const;
    int getFrameEndSamples() const;
    float getFrameStartTicks() const;
    float getFrameEndTicks() const;
    
    // Utility
    AudioDeviceManager& getAudioMgr();
    float samplesToTicks(float t_samples) const;
    float ticksToSamples(float t_ticks) const;
    float millisToSamples(float t_millis) const;
    float samplesToMillis(float t_samples) const;
    float millisToTicks(float t_millis) const;
    float ticksToMillis(float t_ticks) const;
    
private:
    volatile float sampleRate;
    volatile float bpm;
    volatile int frameStartSamples;
    volatile int frameEndSamples;
    volatile bool playing;
    
    AudioDeviceManager audioMgr;
    Mixer mixer;
    
    friend class Mixer;
};

#endif /* defined(__BeatMatic__AudioEngineImpl__) */
