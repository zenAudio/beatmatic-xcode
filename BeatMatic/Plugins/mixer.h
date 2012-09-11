//
//  mixer.h
//  BeatMatic
//
//  Created by Martin Percossi on 10.09.12.
//
//

#ifndef __BeatMatic__mixer__
#define __BeatMatic__mixer__

#include "juce.h"

#include "drummachine.h"
#include "loopmachine2.h"

class AudioEngineImpl;

/**
This class is a Mixer-cum-transport. It is essentially a mixer,
but uses the fact that this is the first main audio source 
 player to set the transport in the audio engine at the beginning
 of every callback.
**/
class Mixer : public MixerAudioSource {
public:
    Mixer(AudioEngineImpl& engine);
    virtual ~Mixer() {}
    void init();
    
    DrumMachine& getDrumMachine();
    LoopMachine& getLoopMachine();
    
    // AudioSourcePlayer implementation -- we need to override MixerAudioSource to
    // do our transport operations.
    void audioDeviceIOCallback (const float** inputChannelData,
                                int totalNumInputChannels,
                                float** outputChannelData,
                                int totalNumOutputChannels,
                                int numSamples);
    void audioDeviceAboutToStart(AudioIODevice* device);
    void audioDeviceStopped();
    
    // AudioSource implementation.
    void prepareToPlay(int samplesPerBlockExpected, double sampleRate);
    void releaseResources();
    void getNextAudioBlock(const AudioSourceChannelInfo& bufferToFill);
    
private:
    AudioSourcePlayer player;
    
    AudioEngineImpl& audioEngine;
    LoopMachine loopMachine;
    DrumMachine drumMachine;
};

#endif /* defined(__BeatMatic__mixer__) */
