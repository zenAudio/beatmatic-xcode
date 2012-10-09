//
//  AudioEngineImpl.cpp
//  BeatMatic
//
//  Created by Martin Percossi on 09.09.12.
//
//

#include "AudioEngineImpl.h"

#include <iostream>
#include "objctrampoline.h"
#include "audioplayer.h"

////////////////////
//////////////////////

#define JSON_BUFFER 256 

const float AudioInputMeter::LAMBDA = 0.9995;

//[MiscUserDefs] You can add your own user definitions and misc code here...
AudioInputMeter::AudioInputMeter(AudioEngineImpl& audioEngine) : callbackId(String::empty), audioEngine(audioEngine),
    pos(0), lastFire(0)
{
    level = 0;
    
    addChangeListener(this);
    
//    startTimer (1000 / 25); // use a timer to keep repainting this component
}

void AudioInputMeter::setPhoneGapCallbackId(const char* const callbackId) {
//    std::cout << "MPD: NATIVE: CPP: AudioInputMeter::setPhoneGapCallbackId: " << ((callbackId!=nullptr)?callbackId:"null") << std::endl;
    this->callbackId = callbackId != nullptr ? callbackId : String::empty;
}

AudioInputMeter::~AudioInputMeter() {}
void AudioInputMeter::audioDeviceAboutToStart(AudioIODevice*) {}
void AudioInputMeter::audioDeviceStopped() {}

void AudioInputMeter::changeListenerCallback(ChangeBroadcaster* source) {
//    std::cout << "MPD: NATIVE: CPP: AudioInputMeter::changeListenerCallback: called" << std::endl;
    if (callbackId != String::empty) {
        float l = level;
//        std::cout << "MPD: NATIVE: CPP: AudioInputMeter::changeListenerCallback: level: " << l << std::endl;
        l = 10*std::log10f(l); // + 40.0;
        if (l < -40)
            l = -40;
        l = (l + 40)/40.0*100.0;
//        std::cout << "MPD: NATIVE: CPP: AudioInputMeter::changeListenerCallback: level: " << l << std::endl;
        std::sprintf(buf, "%f", l);
        InvokePhoneGapCallback(audioEngine.getGuiFacade(), callbackId.toUTF8(), buf);
    }
}

void AudioInputMeter::audioDeviceIOCallback(const float** inputChannelData, int numInputChannels,
                                            float** outputChannelData, int numOutputChannels, int numSamples)
{
    for (int i = 0; i < numSamples; i++) {
        float v = 0;
        for (int chan = 0; chan < numInputChannels; chan++) {
            v += inputChannelData[chan][i];
        }
        v /= (float) numInputChannels;
        level = (1 - LAMBDA)*v*v + LAMBDA*level;
    }
    
//    std::cout << "MPD: NATIVE: CPP: AudioInputMeter::audioDeviceIOCallback: " << level << std::endl;
    
    // We need to clear the output buffers, in case they're full of junk..
    for (int i = 0; i < numOutputChannels; ++i)
        if (outputChannelData[i] != 0)
            zeromem (outputChannelData[i], sizeof (float) * numSamples);
    
    float newPos = pos + numSamples;
    if (newPos - lastFire > 2000) {
        this->sendChangeMessage();
        lastFire = newPos;
    }
    pos = newPos;
}


AudioEngineImpl::AudioEngineImpl() : mixer(*this), audioRecorder(*this),
cursorUpdateCb(String::empty), playSampleCb(String::empty), inputMeter(*this),shakeCb(String::empty)
{
	addChangeListener(this);
}

AudioInputMeter& AudioEngineImpl::getInputMeter() {
    return inputMeter;
}

void AudioEngineImpl::init(void * objcSelf) {
//    std::cout << "MPD: NATIVE: CPP: AudioEngineImpl::init: starting: " << Time::currentTimeMillis() << std::endl;
    transport.addChangeListener(this);
	mixer.getLoopMachine().addChangeListener(this);
//    std::cout << "MPD: NATIVE: CPP: AudioEngineImpl::init: audio engine listening to messages: " << Time::currentTimeMillis() << std::endl;
    audioMgr.initialise(1 /* mono input */, 2 /* stereo output */, nullptr, true, String::empty, nullptr);
//    std::cout << "MPD: NATIVE: CPP: AudioEngineImpl::init: audio manager initialized: " << Time::currentTimeMillis() << std::endl;
    audioMgr.addAudioCallback(&audioRecorder);
    audioMgr.addAudioCallback(&inputMeter);
//    std::cout << "MPD: NATIVE: CPP: AudioEngineImpl::init: added input and recorder audio callback: " << Time::currentTimeMillis() << std::endl;
    mixer.init();
//    std::cout << "MPD: NATIVE: CPP: AudioEngineImpl::init: initialized mixer: " << Time::currentTimeMillis() << std::endl;
    this->objcSelf = objcSelf;
//    std::cout << "MPD: NATIVE: CPP: AudioEngineImpl::init: ending: " << Time::currentTimeMillis() << std::endl;
}

void AudioEngineImpl::changeListenerCallback(ChangeBroadcaster* source) {
    static char buffer[JSON_BUFFER];

    if (source == &transport && cursorUpdateCb == String::empty)
		return;
	
//	std::cout << "MPD: NATIVE: CPP: AudioEngineImpl::changeListenerCallback: invoked" << std::endl;
	
    if (source == &transport) {
        if (transport.isPlaying()) {
            
            // we're stopped, so send back zero.
            float fticks = transport.getFrameStartTicks();
            int ticks = ((int) fticks) % 4;
            int beats = (((int) fticks) / 4) % 4;
            int bars = ((int) fticks) / 16;
            
            std::memset(buffer, JSON_BUFFER, 0);
            std::sprintf(buffer, "{\"bars\": %d, \"beats\": %d, \"ticks\": %d}", bars + 1, beats + 1, ticks + 1);
            
            InvokePhoneGapCallback(objcSelf, cursorUpdateCb.toUTF8(), buffer);
        } else {
//            std::cout << "MPD: NATIVE: CPP: AudioEngineImpl::changeListenerCallback: invoked while stopped" << std::endl;
            InvokePhoneGapCallback(objcSelf, cursorUpdateCb.toUTF8(), "{\"bars\": 1, \"beats\": 1, \"ticks\": 1}");
        }
    } else if (source == mixer.getAudioPlayer()) {
//		std::cout << "MPD: NATIVE: CPP: AudioEngineImpl::changeListenerCallback: finished playing sample." << std::endl;
		InvokePhoneGapCallback(objcSelf, playSampleCb.toUTF8(), "success");
    } else if (source == &mixer.getLoopMachine()) {
		// need to interpret the messages.
		
		auto& lm = mixer.getLoopMachine();
//		std::cout << "MPD: NATIVE: CPP: AudioEngineImpl::changeListenerCallback: invoked from loop machine. " << std::endl; 
		
		int limit = lm.endCommitIx;
		while (lm.endDrainIx <= limit) {
			int groupIx = lm.endringbuf[lm.endDrainIx][0];
			int loopIx = lm.endringbuf[lm.endDrainIx][1];
			
			auto callbackId = (*lm.groupIxToLoopInfo[groupIx])[loopIx]->callbackId;
//			std::cout << "MPD: NATIVE: CPP: AudioEngineImpl::changeListenerCallback: invoked from loop machine: " << groupIx << ", " << loopIx << ", callback: " << callbackId << std::endl;
			if (callbackId != String::empty) {
				InvokePhoneGapCallback(objcSelf, callbackId.toUTF8(), "");
			}
			
			//audioState[groupIx] = loopIx;
			lm.endDrainIx++;
		}
	} else if (source == this && shakeCb != String::empty) {
		// then this was caused by shake() method below!
		InvokePhoneGapCallback(objcSelf, shakeCb.toUTF8(), "");
	}
}

Mixer& AudioEngineImpl::getMixer() {
    return mixer;
}

void AudioEngineImpl::playTestTone() {
    std::cout << "MPD: CPP: AudioEngineImpl::playTestTone" << std::endl;
    audioMgr.playTestSound();
}

void AudioEngineImpl::setDrumPreset(const char * const presetFilename) {
    mixer.getDrumMachine().setDrumPreset(presetFilename);
//    std::cout << "MPD: NATIVE: CPP: AudioEngineImpl::setDrumPreset: done: " << Time::currentTimeMillis() << std::endl;
}

void AudioEngineImpl::setLooperPreset(const char * const presetFilename) {
    mixer.getLoopMachine().setPreset(presetFilename);
//    std::cout << "MPD: NATIVE: CPP: AudioEngineImpl::setLooperPreset: done: " << Time::currentTimeMillis() << std::endl;
}

void AudioEngineImpl::auditionDrum(juce::String soundName) {
//    std::cout << "MPD: CPP: AudioEngineImpl::auditionDrum: auditioning " << soundName << std::endl;
    mixer.getDrumMachine().audition(soundName);
}

void AudioEngineImpl::setDrumPattern(const char *const patternJson) {
//    std::cout << "MPD: CPP: AudioEngineImpl::setDrumPattern: pattern is " << patternJson << std::endl;
    mixer.getDrumMachine().setDrumPattern(patternJson);
}

void AudioEngineImpl::toggleLoop(const char* const group, int ix) {
//    std::cout << "MPD: CPP: AudioEngineImpl::toggleLoop:" << group << ", " << ix << std::endl;
    auto& lm = mixer.getLoopMachine();
    lm.toggleLoop(lm.groupIx(String(group)), ix);
}

AudioDeviceManager& AudioEngineImpl::getAudioMgr() {
    return audioMgr;
}

AudioTransport& AudioEngineImpl::getTransport() {
    return transport;
}

void AudioEngineImpl::recordAudioStart(const char* const filename) {
//    std::cout << "MPD: CPP: AudioEngineImpl::recordAudioStart:" << filename << std::endl;
    
    audioRecorder.startRecording(File(String(filename)));
}

void AudioEngineImpl::recordAudioStop(const char* const callbackId) {
    audioRecorder.stopRecording(callbackId);
}

void * AudioEngineImpl::getGuiFacade() const {
    return objcSelf;
}

void AudioEngineImpl::playSample(const char *const filename, const char * const callbackId) {
//    std::cout << "MPD: NATIVE: CPP: AudioEngineImpl::playSample: " << filename << std::endl;
    mixer.playSample(File(filename));
    playSampleCb = callbackId;
}

void AudioEngineImpl::stopSample() {
//    std::cout << "MPD: NATIVE: CPP: AudioEngineImpl::stopSample" << std::endl;
    mixer.stopSample();
}

void AudioEngineImpl::setCursorUpdateCallback(const char* const callbackId) {
//    std::cout << "MPD: NATIVE: CPP: AudioEngineImpl::setCursorUpdateCallback: setting timer updates to " << CURSOR_UPDATE_INTERVAL_MS << " millis" << std::endl;
    cursorUpdateCb = callbackId != nullptr ? callbackId : String::empty;
//    std::cout << "MPD: NATIVE: CPP: AudioEngineImpl::setCursorUpdateCallback: " << (callbackId?callbackId:"null") << std::endl;
}

void AudioEngineImpl::shake() {
	sendChangeMessage();
}

void AudioEngineImpl::setShakeCallback(String callback) {
	shakeCb = callback;
}
