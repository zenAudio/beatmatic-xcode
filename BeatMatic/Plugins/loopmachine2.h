//
//  loopmachine2.h
//  BeatMatic
//
//  Created by Martin Percossi on 10.09.12.
//
//

#ifndef __BeatMatic__loopmachine2__
#define __BeatMatic__loopmachine2__

#include "juce.h"

class AudioEngineImpl;

class LoopMachine : public AudioSource {
public:
    static const int FADE_TIME_MS=15;
    static const int MAX_NUM_LOOPS = 16;
    static const int LOOP_INACTIVE = -1;
    static const int NO_SUCH_GROUP = -2;
    static const int RINGBUF_SIZE = 128;
    static const int MAX_NUM_GROUPS = 16;
    static const int RINGBUF_SIZE_M1 = RINGBUF_SIZE - 1;
    static const int NUM_OUTPUT_CHANNELS = 2; // stereo output.
    
public:
    LoopMachine(AudioEngineImpl& engine);
    virtual ~LoopMachine() {}
    
    void init();
    
    void setPreset(const char* const presetFilename);
    void toggleLoop(String loopName, int loopIx);
    void toggleLoop(int groupIx, int loopIx);
    int groupIx(String groupName);
    
    void prepareToPlay(int /*samplesPerBlockExpected*/, double sampleRate);
    void releaseResources();
    void getNextAudioBlock(const AudioSourceChannelInfo& bufferToFill);
    
private:
    void printState(String name, int state[]);
    void printRingBuffer();
    
    void addLoop(String groupName, File loopFile);
    
    void drainRingBuffer();
    
    void processFade(int groupIx, int loopIx, float startGain, float endGain, int destOffset, int numSamples,
                     const AudioSourceChannelInfo& bufferToFill);
   
    void processFadeIn(int groupIx, int loopIx, float frameStartTicks,
                       float frameEndTicks, float fadeStartTicks, float fadeEndTicks,
                       const AudioSourceChannelInfo& bufferToFill);
    void processFadeOut(int groupIx, int loopIx, float frameStartTicks,
                        float frameEndTicks, float fadeStartTicks, float fadeEndTicks,
                        const AudioSourceChannelInfo& bufferToFill);
    void processBlock(int groupIx, int loopIx, int destOffset, int numSamples,
                      const AudioSourceChannelInfo& bufferToFill);    
private:
    int expectedBufferSize;
    Array<Array<AudioFormatReaderSource *> *> groupIxToAudioSource;
    int userState[MAX_NUM_GROUPS];              // the loops playing as seen by the user, these react to changes first!
    int audioState[MAX_NUM_GROUPS];             // the actual loops playing in the audio thread, these are triggered only on tick frames.
    int prevAudioState[MAX_NUM_GROUPS];
    HashMap<String, int> groupNameToIx;
    
    AudioSourceChannelInfo frameBuffer;
    
    int ringbuf[RINGBUF_SIZE][2];
    Atomic<int> reserveIx;  // multiple producers (i.e. toggleLoop can be called from multiple threads) => need atomic.
    Atomic<int> commitIx;   // need atomic in any case, since gui and audio threads are separate
    int drainIx;            // only one consumer, the audio thread => no atomic.
    
    WavAudioFormat wavFormat;
    AudioEngineImpl& audioEngine;
};

#endif /* defined(__BeatMatic__loopmachine2__) */
