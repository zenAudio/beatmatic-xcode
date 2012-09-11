//
//  mixer.cpp
//  BeatMatic
//
//  Created by Martin Percossi on 10.09.12.
//
//

#include "mixer.h"
#include "AudioEngineImpl.h"

Mixer::Mixer(AudioEngineImpl& engine) : audioEngine(engine), loopMachine(engine), drumMachine(engine) {
}

void Mixer::init() {
    drumMachine.init();
    loopMachine.init();
    
    addInputSource(&drumMachine, true);
    addInputSource(&loopMachine, true);
    
    
    
    player.setSource(this);
    
    audioEngine.getAudioMgr().addAudioCallback(&player);
}

DrumMachine& Mixer::getDrumMachine() {
    return drumMachine;
}

LoopMachine& Mixer::getLoopMachine() {
    return loopMachine;
}

// AudioSource implementation.
void Mixer::prepareToPlay(int samplesPerBlockExpected, double sampleRate) {
    audioEngine.sampleRate = sampleRate;
    MixerAudioSource::prepareToPlay(samplesPerBlockExpected, sampleRate);
}

void Mixer::releaseResources() {
    MixerAudioSource::releaseResources();
}

void Mixer::getNextAudioBlock(const AudioSourceChannelInfo& bufferToFill) {
    if (audioEngine.playing) {
        audioEngine.frameStartSamples = audioEngine.frameEndSamples;
        audioEngine.frameEndSamples += bufferToFill.numSamples;
    }
    
    MixerAudioSource::getNextAudioBlock(bufferToFill);
}
