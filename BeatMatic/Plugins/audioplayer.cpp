//
//  audioplayer.cpp
//  BeatMatic
//
//  Created by Martin Percossi on 13.09.12.
//
//

#include "audioplayer.h"

AudioPlayer::AudioPlayer(AudioFormatReader* const reader_, const bool deleteReaderWhenThisIsDeleted)
    : reader (reader_, deleteReaderWhenThisIsDeleted), nextPlayPos (0), looping (false), justFinished(true)
{
    jassert (reader != nullptr);
}

AudioPlayer::~AudioPlayer() {}

int64 AudioPlayer::getTotalLength() const                   { return reader->lengthInSamples; }
void AudioPlayer::setNextReadPosition (int64 newPosition)   { nextPlayPos = newPosition; }
void AudioPlayer::setLooping (bool shouldLoop)              { looping = shouldLoop; }

int64 AudioPlayer::getNextReadPosition() const
{
    return looping ? nextPlayPos % reader->lengthInSamples
    : nextPlayPos;
}

void AudioPlayer::prepareToPlay (int /*samplesPerBlockExpected*/, double /*sampleRate*/) {}
void AudioPlayer::releaseResources() {}

void AudioPlayer::getNextAudioBlock (const AudioSourceChannelInfo& info)
{
    if (info.numSamples > 0)
    {
        const int64 start = nextPlayPos;
        
        if (looping)
        {
            const int newStart = (int) (start % (int) reader->lengthInSamples);
            const int newEnd = (int) ((start + info.numSamples) % (int) reader->lengthInSamples);
            
            if (newEnd > newStart)
            {
                reader->read (info.buffer, info.startSample,
                              newEnd - newStart, newStart, true, true);
            }
            else
            {
                const int endSamps = (int) reader->lengthInSamples - newStart;
                
                reader->read (info.buffer, info.startSample,
                              endSamps, newStart, true, true);
                
                reader->read (info.buffer, info.startSample + endSamps,
                              newEnd, 0, true, true);
            }
            
            nextPlayPos = newEnd;
        }
        else
        {
            if (start > reader->lengthInSamples) {
                if (justFinished) {
                    std::cout << "MPD: NATIVE: CPP: AudioPlayer::getNextAudioBlock: finished playing sample." << std::endl;
                    sendChangeMessage();
                    justFinished = false;
                }
                info.clearActiveBufferRegion();
            } else {
                reader->read (info.buffer, info.startSample,
                              info.numSamples, start, true, true);
                nextPlayPos += info.numSamples;
            }
        }
    }
}
