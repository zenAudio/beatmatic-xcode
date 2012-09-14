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


AudioEngineImpl::AudioEngineImpl() : mixer(*this), audioRecorder(*this),
    cursorUpdateCb(String::empty), playSampleCb(String::empty)
{
}

void AudioEngineImpl::init(void * objcSelf) {
    transport.addChangeListener(this);
    audioMgr.initialise(1 /* mono input */, 2 /* stereo output */, nullptr, true, String::empty, nullptr);
    audioMgr.addAudioCallback(&audioRecorder);
    mixer.init();
    this->objcSelf = objcSelf;
}

void AudioEngineImpl::changeListenerCallback(ChangeBroadcaster* source) {
    static char buffer[JSON_BUFFER];
    
    if (source == &transport) {
        if (cursorUpdateCb != String::empty && transport.isPlaying()) {
//            std::cout << "MPD: NATIVE: CPP: AudioEngineImpl::changeListenerCallback: invoked while playing!" << std::endl;
            
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
        if (playSampleCb != String::empty) {
            std::cout << "MPD: NATIVE: CPP: AudioEngineImpl::changeListenerCallback: finished playing sample." << std::endl;
            InvokePhoneGapCallback(objcSelf, playSampleCb.toUTF8(), "success");
        }
    }
}


void AudioEngineImpl::playTestTone() {
    std::cout << "MPD: CPP: AudioEngineImpl::playTestTone" << std::endl;
    audioMgr.playTestSound();
}

void AudioEngineImpl::setDrumPreset(const char * const presetFilename) {
    mixer.getDrumMachine().setDrumPreset(presetFilename);
}

void AudioEngineImpl::setLooperPreset(const char * const presetFilename) {
    mixer.getLoopMachine().setPreset(presetFilename);
}

void AudioEngineImpl::auditionDrum(juce::String soundName) {
    std::cout << "MPD: CPP: AudioEngineImpl::auditionDrum: auditioning " << soundName << std::endl;
    mixer.getDrumMachine().audition(soundName);
}

void AudioEngineImpl::setDrumPattern(const char *const patternJson) {
    std::cout << "MPD: CPP: AudioEngineImpl::setDrumPattern: pattern is " << patternJson << std::endl;
    mixer.getDrumMachine().setDrumPattern(patternJson);
}

void AudioEngineImpl::toggleLoop(const char* const group, int ix) {
    std::cout << "MPD: CPP: AudioEngineImpl::toggleLoop:" << group << ", " << ix << std::endl;
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
    std::cout << "MPD: CPP: AudioEngineImpl::recordAudioStart:" << filename << std::endl;
    
    audioRecorder.startRecording(File(filename));
}

void AudioEngineImpl::recordAudioStop(const char* const callbackId) {
    audioRecorder.stopRecording(callbackId);
}

void * AudioEngineImpl::getGuiFacade() const {
    return objcSelf;
}

void AudioEngineImpl::playSample(const char *const filename, const char * const callbackId) {
    std::cout << "MPD: NATIVE: CPP: AudioEngineImpl::playSample: " << filename << std::endl;
    mixer.playSample(File(filename));
    playSampleCb = callbackId;
}

void AudioEngineImpl::stopSample() {
    std::cout << "MPD: NATIVE: CPP: AudioEngineImpl::stopSample" << std::endl;
    mixer.stopSample();
}

void AudioEngineImpl::setCursorUpdateCallback(const char* const callbackId) {
    std::cout << "MPD: NATIVE: CPP: AudioEngineImpl::setCursorUpdateCallback: setting timer updates to " << CURSOR_UPDATE_INTERVAL_MS << " millis" << std::endl;
    cursorUpdateCb = String(callbackId);
    std::cout << "MPD: NATIVE: CPP: AudioEngineImpl::setCursorUpdateCallback: " << callbackId << std::endl;
}
