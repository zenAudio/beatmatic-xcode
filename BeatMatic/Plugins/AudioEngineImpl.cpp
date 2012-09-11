//
//  AudioEngineImpl.cpp
//  BeatMatic
//
//  Created by Martin Percossi on 09.09.12.
//
//

#include "AudioEngineImpl.h"

#include <iostream>

////////////////////
//////////////////////


AudioEngineImpl::AudioEngineImpl() : mixer(*this) {
}

void AudioEngineImpl::init() {
    audioMgr.initialise(1 /* mono input */, 2 /* stereo output */, nullptr, true, String::empty, nullptr);
    
    mixer.init();
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

void AudioEngineImpl::play() {
    std::cout << "MPD: CPP: AudioEngineImpl::play" << std::endl;
    if (!playing) {
        frameStartSamples = 0;
        frameEndSamples = 0;
        playing = true;
    }
}

void AudioEngineImpl::stop() {
    std::cout << "MPD: CPP: AudioEngineImpl::stop" << std::endl;
    if (playing) {
        playing = false;
    }
}

void AudioEngineImpl::toggleLoop(const char* const group, int ix) {
    std::cout << "MPD: CPP: AudioEngineImpl::toggleLoop:" << group << ", " << ix << std::endl;
    auto& lm = mixer.getLoopMachine();
    lm.toggleLoop(lm.groupIx(String(group)), ix);
}

float AudioEngineImpl::getBpm() const {
    std::cout << "MPD: CPP: AudioEngineImpl::getBpm" << std::endl;
    return bpm;
}

void AudioEngineImpl::setBpm(float bpm) {
    std::cout << "MPD: CPP: AudioEngineImpl::setBpm:" << bpm << std::endl;
    this->bpm = bpm;
}

float AudioEngineImpl::samplesToTicks(float t_samples) const {
    float t_ticks = 4.f/60.f*bpm/sampleRate*t_samples;
    return t_ticks;
}

float AudioEngineImpl::ticksToSamples(float t_ticks) const {
    float t_samples = 60.f/4.0/bpm*sampleRate*t_ticks;
    return t_samples;
}

float AudioEngineImpl::millisToSamples(float t_millis) const {
    return t_millis / (float) 1000.0 * getSampleRate();
}

float AudioEngineImpl::samplesToMillis(float t_samples) const {
    return t_samples * (float) 1000.0 / getSampleRate();
}

float AudioEngineImpl::millisToTicks(float t_millis) const {
    return samplesToTicks(millisToSamples(t_millis));
}

float AudioEngineImpl::ticksToMillis(float t_ticks) const {
    return samplesToMillis(ticksToSamples(t_ticks));
}

bool AudioEngineImpl::isPlaying() const {
    return playing;
}
float AudioEngineImpl::getSampleRate() const {
    return sampleRate;
}
int AudioEngineImpl::getFrameStartSamples() const {
    return frameStartSamples;
}
int AudioEngineImpl::getFrameEndSamples() const {
    return frameEndSamples;
}
float AudioEngineImpl::getFrameStartTicks() const {
    return samplesToTicks(frameStartSamples);
}
float AudioEngineImpl::getFrameEndTicks() const {
    return samplesToTicks(frameEndSamples);
}

// Utility
AudioDeviceManager& AudioEngineImpl::getAudioMgr() {
    return audioMgr;
}


