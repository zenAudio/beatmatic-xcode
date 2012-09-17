//
//  audioringbuffer.cpp
//  BeatMatic
//
//  Created by Martin Percossi on 9/15/12.
//
//

#include "audioringbuffer.h"
#include <cstdlib>

AudioRingBuffer::AudioRingBuffer(int numChannels, int numSamples) : numChannels(numChannels), numSamples(numSamples) {
    buf = (float**) std::malloc(numChannels*sizeof(float*));
    for (int chan = 0; chan < numChannels; chan++)
        buf[chan] = (float *)std::malloc(numSamples*sizeof(float));
    M = numSamples-1;
}

AudioRingBuffer::AudioRingBuffer() : AudioRingBuffer(2, 8192) {
}

AudioRingBuffer::~AudioRingBuffer() {
    std::free(buf);
}

int AudioRingBuffer::getStart() {
    return start;
}

int AudioRingBuffer::getEnd() {
    return end;
}

void AudioRingBuffer::sampleAdded() {
    end++;
}

void AudioRingBuffer::sampleRead() {
    start++;
}

int AudioRingBuffer::size() {
    if (end > start)
        return end - start;
    else
        return numSamples - start + end;
}

float AudioRingBuffer::getSample(int channel, int ix) {
    return buf[channel][ix & M];
}
void AudioRingBuffer::setSample(int channel, int ix, float value) {
    buf[channel][ix & M] = value;
}

