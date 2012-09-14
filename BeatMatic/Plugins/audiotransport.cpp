//
//  audiotransport.cpp
//  BeatMatic
//
//  Created by Martin Percossi on 12.09.12.
//
//

#include "audiotransport.h"

AudioTransport::AudioTransport() : t_frames(0), t_samples(0), sampleRate(44100.0),
    bpm(120), frameStartSamples(0), frameEndSamples(0), playing(false), latencySamples(0)
{
}

void AudioTransport::updateTransport(int numSamplesInFrame) {
    frameStartSamples = frameEndSamples;
    frameEndSamples += numSamplesInFrame;
    
    int start = samplesToTicks(frameStartSamples);
    int end = samplesToTicks(frameEndSamples);
    if (end > start) {
        sendChangeMessage();
    }
}

void AudioTransport::setTransport(int timeSamples) {
    int diff = frameEndSamples-frameStartSamples;
    frameEndSamples = timeSamples;
    frameStartSamples = frameEndSamples-diff;
}

int AudioTransport::getCurrPosTicks() const {
    return (int) getFrameStartTicks();
}

int AudioTransport::getCurrPosBeats() const {
    return getCurrPosTicks() / 4;
}

int AudioTransport::getCurrPosBars() const {
    return getCurrPosBeats() / 4;
}

// Transport
void AudioTransport::play() {
    std::cout << "MPD: CPP: AudioTransport::play" << std::endl;
    if (!playing) {
        frameStartSamples = 0;
        frameEndSamples = 0;
        playing = true;
    }
}

void AudioTransport::stop() {
    std::cout << "MPD: CPP: AudioTransport::stop" << std::endl;
    if (playing) {
        playing = false;
    }
}

float AudioTransport::getBpm() const {
//    std::cout << "MPD: CPP: AudioTransport::getBpm" << std::endl;
    return bpm;
}

void AudioTransport::setBpm(float bpm) {
    std::cout << "MPD: CPP: AudioTransport::setBpm:" << bpm << std::endl;
    this->bpm = bpm;
}

void AudioTransport::setLatency(int latency) {
    latencySamples = latency;
}

int AudioTransport::getLatency() const {
    return latencySamples;
}

float AudioTransport::samplesToTicks(float t_samples) const {
    float t_ticks = 4.f/60.f*bpm/sampleRate*t_samples;
    return t_ticks;
}

float AudioTransport::ticksToSamples(float t_ticks) const {
    float t_samples = 60.f/4.0/bpm*sampleRate*t_ticks;
    return t_samples;
}

float AudioTransport::millisToSamples(float t_millis) const {
    return t_millis / (float) 1000.0 * getSampleRate();
}

float AudioTransport::samplesToMillis(float t_samples) const {
    return t_samples * (float) 1000.0 / getSampleRate();
}

float AudioTransport::millisToTicks(float t_millis) const {
    return samplesToTicks(millisToSamples(t_millis));
}

float AudioTransport::ticksToMillis(float t_ticks) const {
    return samplesToMillis(ticksToSamples(t_ticks));
}

bool AudioTransport::isPlaying() const {
    return playing;
}
float AudioTransport::getSampleRate() const {
    return sampleRate;
}
void AudioTransport::setSampleRate(float sampleRate) {
    this->sampleRate = sampleRate;
}
int AudioTransport::getFrameStartSamples() const {
    return frameStartSamples - latencySamples;
}
int AudioTransport::getFrameEndSamples() const {
    return frameEndSamples - latencySamples;
}
float AudioTransport::getFrameStartTicks() const {
    return samplesToTicks(getFrameStartSamples());
}
float AudioTransport::getFrameEndTicks() const {
    return samplesToTicks(getFrameEndSamples());
}

