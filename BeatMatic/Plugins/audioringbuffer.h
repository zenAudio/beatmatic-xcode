//
//  audioringbuffer.h
//  BeatMatic
//
//  Created by Martin Percossi on 9/15/12.
//
//

#ifndef __BeatMatic__audioringbuffer__
#define __BeatMatic__audioringbuffer__

class AudioRingBuffer {
public:
    AudioRingBuffer(int numChannels, int numSamples);
    AudioRingBuffer();
    ~AudioRingBuffer();
    
    int getStart();
    int getEnd();
    int size();
    
    void sampleAdded();
    void sampleRead();
    
    float getSample(int channel, int ix);
    void setSample(int channel, int ix, float value);
    
private:
    int numChannels;
    int numSamples;
    int M;
    int start;
    int end;
    float **buf;
};

#endif /* defined(__BeatMatic__audioringbuffer__) */
