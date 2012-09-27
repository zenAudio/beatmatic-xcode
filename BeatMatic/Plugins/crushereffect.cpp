//
//  crushereffect.cpp
//  BeatMatic
//
//  Created by Martin Percossi on 9/17/12.
//
//

#include "crushereffect.h"

namespace {
	int spow(int k) {
		int a = 1;
		for (int i = k; i > 0; a <<= 1, --i);
		return a;
	}
}

CrusherEffect::CrusherEffect(AudioSource* inputSource, bool deleteInputWhenDeleted) : src(inputSource), deleteInputWhenDeleted(deleteInputWhenDeleted), m(2), y(0), cnt(0)
{
//    std::cout << "MPD: NATIVE: CPP: CrusherEffect::CrusherEffect: m=" << m << std::endl;
}
CrusherEffect::~CrusherEffect() {
}

void CrusherEffect::setParams(const Parameters& newSettings) {
    parms = newSettings;
    m = 1 << (parms.bits - 1);
	decimation = spow(parms.bits);
    y = 0;
    cnt = 0;
//    std::cout << "MPD: NATIVE: CPP: CrusherEffect::setParams: m=" << m << std::endl;
}

const CrusherEffect::Parameters& CrusherEffect::getParams() const {
    return parms;
}

void CrusherEffect::prepareToPlay (int samplesPerBlockExpected, double sampleRate) {
	decimation = spow(parms.bits);
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
//    std::cout << "MPD: NATIVE: CPP: CrusherEffect::getNextAudioBlock: entering loop: " << i0 << "; N=" << N << ", " << M << ", parms.rate=" << parms.rate << "; m=" << m << std::endl;
	float max = 2147483647;
    for (int i = 0; i < N; i++) {
        float v = 0;
        for (int chan = 0; chan < M; chan++)
            v += buf[chan][i0 + i];
		v /= 2;
		
        if (cnt >= 1) {
            cnt -= 1;
			int w = (int) (v * max);
			w /= decimation;
			w *= decimation;
			y = (float) w / max;
        }
        for (int chan = 0; chan < M; chan++) {
            buf[chan][i0 + i] = y;
        }
        cnt += parms.rate;
//        std::cout << "MPD: NATIVE: CPP: CrusherEffect::getNextAudioBlock: y=" << y << "; cnt=" << cnt << "; v=" << v << std::endl;
    }
//    std::cout << "MPD: NATIVE: CPP: CrusherEffect::getNextAudioBlock: done; y=" << y << "; sum=" << sum << "; sum2=" << sum2 << "; m = " << m << std::endl;
    
}

