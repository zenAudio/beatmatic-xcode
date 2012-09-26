//
//  drummachine.h
//  BeatMatic
//
//  Created by Martin Percossi on 10.09.12.
//
//

#ifndef __BeatMatic__drummachine__
#define __BeatMatic__drummachine__

#include "juce.h"

class AudioEngineImpl;

// This is an audio source that streams the output of our sampler.
class DrumMachine  : public AudioSource
{
public:
    static const int MAX_DRUM_PATTERN_LENGTH = 64;
    static const int NUM_DRUM_HIT_TYPES = 3;
    static const int NUM_DRUM_VOICES = 6;
    
public:
    DrumMachine(AudioEngineImpl& engine);
    void init();
    
    void audition(String soundName);
    void setDrumPreset(const char * const presetFilename);
    void setDrumPattern(const char* const patternJson);
    int getDrumPatternIx(String drumSound);
    
    void prepareToPlay (int /*samplesPerBlockExpected*/, double sampleRate);
    void releaseResources();
    void getNextAudioBlock(const AudioSourceChannelInfo& bufferToFill);
    MidiMessageCollector& getMidiCollector();
    void noteOn(int note, float velocity);
    void noteOff(int note, float velocity);
    
private:
    void setDrumSound(String soundName, File soundFile);
    
private:
    AudioEngineImpl& audioEngine;
    
    MidiMessageCollector midiCollector;
    MidiKeyboardState keyboardState;
    Synthesiser synth;
    
    int pattern[NUM_DRUM_VOICES][MAX_DRUM_PATTERN_LENGTH];    // maximum four bars
    int patternLength;
    
    // hash map from sound name to midi note.
    HashMap<String, int> soundToNote;
    
    // the last note allocated to a sound
    int lastNote;
};

#endif /* defined(__BeatMatic__drummachine__) */
