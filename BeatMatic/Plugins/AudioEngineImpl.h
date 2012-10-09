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
#include "audiotransport.h"
#include "recorder.h"

struct AudioEngineException : public std::exception
{
    String s;
    AudioEngineException(String ss) : s(ss) {}
    const char* what() const throw() { return s.toUTF8(); }
};

class AudioEngineImpl;

//==============================================================================
/* This component scrolls a continuous waveform showing the audio that's currently
 coming into the audio input.
 */
class AudioInputMeter  : public AudioIODeviceCallback, public ChangeListener, public ChangeBroadcaster
{
public:
    static const float LAMBDA;
public:
    //==============================================================================
    AudioInputMeter(AudioEngineImpl& audioEngine);
    ~AudioInputMeter();
    
    void setPhoneGapCallbackId(const char* const callbackId);
    
//    void timerCallback();
    void changeListenerCallback(ChangeBroadcaster* source);
   
    void audioDeviceAboutToStart (AudioIODevice* device);
    void audioDeviceStopped();
    void audioDeviceIOCallback (const float** inputChannelData, int numInputChannels,
                                float** outputChannelData, int numOutputChannels, int numSamples);
private:
    volatile float level;
    String callbackId;
    char buf[64];
    int pos;
    int lastFire;
    
    AudioEngineImpl& audioEngine;

    AudioInputMeter(const AudioInputMeter&);
    AudioInputMeter& operator= (const AudioInputMeter&);
};

class AudioEngineImpl : public ChangeBroadcaster, public ChangeListener {
public:
    const static int CURSOR_UPDATE_INTERVAL_MS = 10;
    
public:
    
    AudioEngineImpl();
    void init(void *objSelf);
    
    void playTestTone();
    
    void setDrumPreset(const char* const presetFilename);
    void setLooperPreset(const char* const presetFilename);
    void toggleLoop(const char* const group, int ix);
    void auditionDrum(String soundName);
    void setDrumPattern(const char* const patternJson);
    void recordAudioStart(const char* const filename);
    void recordAudioStop(const char* const callbackId);
    void setCursorUpdateCallback(const char* const callbackId);
    void playSample(const char* const filename, const char* const callbackId);
    void stopSample();
	
	void shake();
	void setShakeCallback(String callback);
   
    // Utility
    AudioDeviceManager& getAudioMgr();
    AudioTransport& getTransport();
    void * getGuiFacade() const;
    Mixer& getMixer();
    AudioInputMeter& getInputMeter();
    
    int useTimeSlice();
    void changeListenerCallback(ChangeBroadcaster* source);

private:	
    AudioDeviceManager audioMgr;
    Mixer mixer;
    AudioTransport transport;
    AudioRecorder audioRecorder;
    AudioInputMeter inputMeter;
	    
    // these are needed to communicate with the GUI
    String cursorUpdateCb;
    String playSampleCb;
	String shakeCb;
    
    void * objcSelf;
    
    friend class Mixer;
};

#endif /* defined(__BeatMatic__AudioEngineImpl__) */
