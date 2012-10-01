//
//  filtereffect.cpp
//  BeatMatic
//
//  Created by Martin Percossi on 10/1/12.
//
//

#include "filtereffect.h"

FilterEffect::FilterEffect(AudioSource* inputSource, bool deleteInputWhenDeleted): impl(inputSource, deleteInputWhenDeleted), src(inputSource), sampleRate(0) {
}

FilterEffect::~FilterEffect() {
}

void FilterEffect::setParams(const Parameters& p) {
	params = p;
	IIRFilter filt;
	filt.makeLowPass(sampleRate, params.cutoff);
	impl.setFilterParameters(filt);
}

const FilterEffect::Parameters& FilterEffect::getParams() const {
	return params;
}

void FilterEffect::prepareToPlay (int samplesPerBlockExpected, double sampleRate) {
	this->sampleRate = sampleRate;
	impl.prepareToPlay(samplesPerBlockExpected, sampleRate);
}

void FilterEffect::releaseResources() {
	impl.releaseResources();
}

void FilterEffect::getNextAudioBlock (const AudioSourceChannelInfo& bufferToFill) {
	if (enabled)
		impl.getNextAudioBlock(bufferToFill);
	else
		src->getNextAudioBlock(bufferToFill);
}

void FilterEffect::setEnabled(bool enabled) {
	this->enabled = enabled;;
//	std::cout << "MPD: NATIVE: CPP: FilterEffect::setEnabled: " << enabled << std::endl;
}

bool FilterEffect::isEnabled() const {
	return enabled;
}