//
//  crushereffect.cpp
//  BeatMatic
//
//  Created by Martin Percossi on 9/17/12.
//
//

#include "crushereffect.h"

CrusherEffect::CrusherEffect(AudioSource* inputSource, bool deleteInputWhenDeleted) : src(inputSource), deleteInputWhenDeleted(deleteInputWhenDeleted), m(1 << (parms.bits-1)), y(0), cnt(0)
{
}
CrusherEffect::~CrusherEffect() {
}

void CrusherEffect::setParams(const Parameters& newSettings) {
    parms = newSettings;
    m = 1 << (parms.bits - 1);
    y = 0;
    cnt = 0;
}

const CrusherEffect::Parameters& CrusherEffect::getParams() const {
    return parms;
}

void CrusherEffect::prepareToPlay (int samplesPerBlockExpected, double sampleRate) {
    src->prepareToPlay(samplesPerBlockExpected, sampleRate);
}
void CrusherEffect::releaseResources() {
    src->releaseResources();
}

void CrusherEffect::getNextAudioBlock(const AudioSourceChannelInfo& bufferToFill) {
    src->getNextAudioBlock(bufferToFill);
    
//    std::cout << "MPD: NATIVE: CPP: CrusherEffect::getNextAudioBlock: starting.." << std::endl;
    int i0 = bufferToFill.startSample;
    int N = bufferToFill.numSamples;
    int M = bufferToFill.buffer->getNumChannels();
    float** buf = bufferToFill.buffer->getArrayOfChannels();
//    std::cout << "MPD: NATIVE: CPP: CrusherEffect::getNextAudioBlock: entering loop." << std::endl;
    for (int i = 0; i < N; i++) {
        float v = 0;
        for (int chan = 0; chan < M; chan++)
            v += buf[chan][i0 + i];
        v *= 0.5;
        if (cnt >= 1) {
            cnt -= 1;
            y = (long int) (v*m) / (float)m;
        }
        for (int chan = 0; chan < M; chan++) {
            buf[chan][i0 + i] = y;
        }
        cnt += parms.rate;
//        std::cout << "MPD: NATIVE: CPP: CrusherEffect::getNextAudioBlock: " << y << std::endl;
    }
//    std::cout << "MPD: NATIVE: CPP: CrusherEffect::getNextAudioBlock: done." << std::endl;
     
}

