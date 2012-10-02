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

#include "audiotransport.h"
#include "Dirac.h"

class AudioEngineImpl;

extern long DiracDataProviderCb(float **chdata, long numFrames, void *userData);

enum LoopType {
	ONE_SHOT,
	LOOP
};

struct LoopInfo {
	AudioFormatReaderSource* reader;
	float gain;
	int length;
	LoopType type;
	String callbackId;
};

class LoopMachine : public AudioSource, public ChangeBroadcaster {
public:
    static const int RINGBUF_SIZE = 128;
    static const int FADE_TIME_MS=50;
    static const int MAX_NUM_LOOPS = 16;
    static const int LOOP_INACTIVE = -1;
    static const int NO_SUCH_GROUP = -2;
    static const int MAX_NUM_GROUPS = 16;
    static const int RINGBUF_SIZE_M1 = RINGBUF_SIZE - 1;
    static const int NUM_OUTPUT_CHANNELS = 2; // stereo output.
    static const int DIRAC_AUDIO_BUF_SIZE = 16384;
	
	friend class AudioEngineImpl;
    
public:
    LoopMachine(AudioEngineImpl& engine);
    virtual ~LoopMachine() {}
    
    void init();
    
    void setPreset(const char* const presetFilename);
    void toggleLoop(String loopName, int loopIx);
    void toggleLoop(int groupIx, int loopIx);
    int groupIx(String groupName);
	
	void setOneShotFinishedPlayingCallback(int groupIx, int loopIx, String callbackId);

    void prepareToPlay(int /*samplesPerBlockExpected*/, double sampleRate);
    void releaseResources();
    
    void getNextAudioBlockOld(const AudioSourceChannelInfo& bufferToFill);
    void getNextAudioBlock(const AudioSourceChannelInfo& bufferToFill);
    void getNextAudioBlockFixedBpm(const AudioSourceChannelInfo& bufferToFill);
    
private:
	void setReaderPos(int groupIx, int state, float fadeStartTicks, float frameStartTicks);
    void printState(String name, int state[]);
    void printRingBuffer();
    
	void addLoop(String groupName, File loopFile, float gain, LoopType type, int length);
    
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
	String oneShotFinishedPlayingCallbackId;
    void * dirac;
    AudioSampleBuffer diracInputBuffer;
    AudioSampleBuffer diracOutputBuffer;
    AudioSampleBuffer diracMonoBuffer;  // for LE version
    int diracOffset;
    int latency;
    
    float prevBpm;
        
    AudioTransport fixedBpmTransport;
    
    int expectedBufferSize;
	Array<Array<LoopInfo *> *> groupIxToLoopInfo;
    int userState[MAX_NUM_GROUPS];              // the loops playing as seen by the user, these react to changes first!
    int audioState[MAX_NUM_GROUPS];             // the actual loops playing in the audio thread, these are triggered only on tick frames.
    int prevAudioState[MAX_NUM_GROUPS];
    HashMap<String, int> groupNameToIx;
    
    bool wasPlaying;
    
    AudioSourceChannelInfo frameBuffer;
	
	// Ring buffer for messages from audio thread to UI. 1P 1C.
	int endringbuf[RINGBUF_SIZE][2];
	int endReserveIx;
	volatile int endCommitIx;
	int endDrainIx;
    
	// Ring buffer for messages from UI to audio thread.
    int ringbuf[RINGBUF_SIZE][2];
    Atomic<int> reserveIx;  // multiple producers (i.e. toggleLoop can be called from multiple threads) => need atomic.
    Atomic<int> commitIx;   // need atomic in any case, since gui and audio threads are separate
    int drainIx;            // only one consumer, the audio thread => no atomic.
    
    WavAudioFormat wavFormat;
	CoreAudioFormat cafFormat;
    AudioEngineImpl& audioEngine;
};

#endif /* defined(__BeatMatic__loopmachine2__) */
