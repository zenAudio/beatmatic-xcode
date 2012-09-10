//
//  AudioEngineImpl.h
//  BeatMatic
//
//  Created by Martin Percossi on 09.09.12.
//
//

#ifndef __BeatMatic__AudioEngineImpl__
#define __BeatMatic__AudioEngineImpl__

#include <iostream>
#include "juce.h" 

// This is an audio source that streams the output of our sampler.
class DrumMachineAudioSource  : public AudioSource
{
public:
    //==============================================================================
    DrumMachineAudioSource(MidiKeyboardState& keyboardState_);
    
    void noteOn(int note, float velocity);
    void noteOff(int note, float velocity);
    
    void audition(String soundName);
    
    void setDrumSound(String soundName, File soundFile);
    void prepareToPlay (int /*samplesPerBlockExpected*/, double sampleRate);
    void releaseResources();
    void getNextAudioBlock (const AudioSourceChannelInfo& bufferToFill);
    MidiMessageCollector& getMidiCollector();
    
private:
    //==============================================================================
    // this collects real-time midi messages from the midi input device, and
    // turns them into blocks that we can process in our audio callback
    MidiMessageCollector midiCollector;
    
    // this represents the state of which keys on our on-screen keyboard are held
    // down. When the mouse is clicked on the keyboard component, this object also
    // generates midi messages for this, which we can pass on to our synth.
    MidiKeyboardState& keyboardState;
    
    // the synth itself!
    Synthesiser synth;
    
    // hash map from sound name to midi note.
    HashMap<String, int> soundToNote;
    
    // the last note allocated to a sound
    int lastNote;
};

struct AudioEngineException : public std::exception
{
    String s;
    AudioEngineException(String ss) : s(ss) {}
    const char* what() const throw() { return s.toUTF8(); }
};

class AudioEngineImpl;

class DrumMachineSequencer : public AudioSourcePlayer {
public:
    static const int MAX_DRUM_PATTERN_LENGTH = 64;
    static const int NUM_DRUM_VOICES = 3;
    
public:
    DrumMachineSequencer(AudioEngineImpl& engine);
    virtual ~DrumMachineSequencer();
    void audioDeviceIOCallback (const float** inputChannelData,
                                int totalNumInputChannels,
                                float** outputChannelData,
                                int totalNumOutputChannels,
                                int numSamples);
    void audioDeviceAboutToStart(AudioIODevice* device);
    void audioDeviceStopped();
private:
    int pattern[NUM_DRUM_VOICES][MAX_DRUM_PATTERN_LENGTH];    // maximum four bars
    int patternLength;
    
    AudioEngineImpl& audioEngine;
    
    friend class AudioEngineImpl;
};

class AudioEngineImpl {
public:
    AudioEngineImpl();
    void init();
    void playTestTone();
    void setDrumPreset(const char* const presetFilename);
    void auditionDrum(String soundName);
    void setDrumPattern(const char* const patternJson);
    void play();
    void stop();
    void setBpm(float bpm);
    float getBpm() const;
    
private:
    float samplesToTicks(float t_samples);
    float ticksToSamples(float t_ticks);
    int getDrumPatternIx(String drumSound);
                     
private:
    float sampleRate;
    float bpm;
    int frameStartSamples;
    int frameEndSamples;
    bool playing;
    
    
    AudioDeviceManager audioMgr;
    DrumMachineAudioSource drumMachine;
                    
    MidiKeyboardState keyboardState;
    DrumMachineSequencer drumSequencer;
    ScopedPointer<DrumMachineAudioSource> drumAudioSource;
    
    friend class DrumMachineSequencer;
};

#endif /* defined(__BeatMatic__AudioEngineImpl__) */
