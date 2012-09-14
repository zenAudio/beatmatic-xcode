//
//  mixer.cpp
//  BeatMatic
//
//  Created by Martin Percossi on 10.09.12.
//
//

#include "mixer.h"
#include "AudioEngineImpl.h"
#include "audioplayer.h"

Mixer::Mixer(AudioEngineImpl& engine) : audioEngine(engine), loopMachine(engine), drumMachine(engine), samplePlayer(nullptr)
{
}

void Mixer::init() {
    drumMachine.init();
    loopMachine.init();
    
    addInputSource(&loopMachine, true);
    addInputSource(&drumMachine, true);
    
    player.setSource(this);
    
    audioEngine.getAudioMgr().addAudioCallback(&player);
}

DrumMachine& Mixer::getDrumMachine() {
    return drumMachine;
}

LoopMachine& Mixer::getLoopMachine() {
    return loopMachine;
}

AudioPlayer* Mixer::getAudioPlayer() {
    return samplePlayer;
}

void Mixer::playSample(File filename) {
    if (samplePlayer != nullptr) {
        removeInputSource(samplePlayer);
    }
    WavAudioFormat wavFormat;
    auto audioReader = wavFormat.createReaderFor(new FileInputStream(filename), true);
    if (audioReader) {
        samplePlayer = new AudioPlayer(audioReader, true);
        samplePlayer->setLooping(false);
        samplePlayer->prepareToPlay(samplePerBlockExpected, sampleRate);
        samplePlayer->addChangeListener(&audioEngine);
        samplePlayer->addChangeListener(this);
        addInputSource(samplePlayer, true);
    } else {
        std::cout << "MPD: NATIVE: CPP: Mixer::playSample: samplePlayer null for " << filename.getFullPathName() << std::endl;
    }
}

void Mixer::changeListenerCallback(ChangeBroadcaster* source) {
    std::cout << "MPD: NATIVE: CPP: Mixer::changeListenerCallback: done playing." << std::endl;
}

void Mixer::stopSample() {
    if (samplePlayer != nullptr) {
        removeInputSource(samplePlayer);
        samplePlayer = nullptr;
    }
}

// AudioSource implementation.
void Mixer::prepareToPlay(int samplesPerBlockExpected, double sampleRate) {
    audioEngine.getTransport().setSampleRate(sampleRate);
    this->sampleRate = sampleRate;
    this->samplePerBlockExpected = samplesPerBlockExpected;
    MixerAudioSource::prepareToPlay(samplesPerBlockExpected, sampleRate);
}

void Mixer::releaseResources() {
    MixerAudioSource::releaseResources();
}

void Mixer::getNextAudioBlock(const AudioSourceChannelInfo& bufferToFill) {
    if (audioEngine.getTransport().isPlaying()) {
        audioEngine.getTransport().updateTransport(bufferToFill.numSamples);
    }
    
    MixerAudioSource::getNextAudioBlock(bufferToFill);
}
