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

#include <memory>
#include "drummachine.h"
#include "loopmachine2.h"
#include "limitereffect.h"
#include "crushereffect.h"

class AudioEngineImpl;
class AudioPlayer;

/**
This class is a Mixer-cum-transport. It is essentially a mixer,
but uses the fact that this is the first main audio source 
 player to set the transport in the audio engine at the beginning
 of every callback.
**/
class Mixer : public MixerAudioSource, public ChangeListener {
public:
    Mixer(AudioEngineImpl& engine);
    virtual ~Mixer() {}
    void init();
    
    DrumMachine& getDrumMachine();
    LoopMachine& getLoopMachine();
    AudioPlayer* getAudioPlayer();
    IIRFilterAudioSource* getMasterFilter();
    ReverbAudioSource* getMasterVerb();
    CrusherEffect* getMasterCrusher();
    
    void playSample(File filename);
    void stopSample();
    
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
    
    // change listener to listen to end of audio playback.
    void changeListenerCallback(ChangeBroadcaster* source);
    
private:
    int samplePerBlockExpected;
    double sampleRate;
    AudioSourcePlayer player;
    AudioEngineImpl& audioEngine;
    LoopMachine loopMachine;
    DrumMachine drumMachine;
    AudioPlayer* samplePlayer;
    ScopedPointer<CrusherEffect> masterCrusher;
    ScopedPointer<IIRFilterAudioSource> masterFilter;
    ScopedPointer<ReverbAudioSource> masterVerb;
    ScopedPointer<LimiterEffect> masterLimiter;
};

#endif /* defined(__BeatMatic__mixer__) */
