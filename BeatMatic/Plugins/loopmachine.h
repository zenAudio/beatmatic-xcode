//
//  loopmachine.h
//  BeatMatic
//
//  Created by Martin Percossi on 10.09.12.
//
//

#ifndef __BeatMatic__SampleMachine__
#define __BeatMatic__SampleMachine__

#include "juce.h"

class AudioEngineImpl;

// This is an audio source that streams the output of our sampler.
class SampleMachine  : public AudioSource
{
public:
    static const int MAX_NUM_LOOPS = 16;
    static const int MAX_NUM_LOOP_VARIANTS = 16;
    
public:
    SampleMachine(AudioEngineImpl& engine);
    void init();
    virtual ~SampleMachine() {}
    
    void audition(String soundName);
    void setLooperPreset(const char* const presetFilename);
    
    void prepareToPlay (int /*samplesPerBlockExpected*/, double sampleRate);
    void releaseResources();
    void getNextAudioBlock (const AudioSourceChannelInfo& bufferToFill);
    void noteOn(int note, float velocity);
    void noteOff(int note, float velocity);

private:
    void addLoopVariant(String soundName, File soundFile);
    
private:
    AudioEngineImpl& audioEngine;
    MidiMessageCollector midiCollector;
    MidiKeyboardState keyboardState;
    Synthesiser synth;
    HashMap<String, Range<int>> loopTypeToRange;

};

#endif /* defined(__BeatMatic__SampleMachine__) */
