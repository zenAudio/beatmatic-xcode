//
//  recorder.h
//  BeatMatic
//
//  Created by Martin Percossi on 12.09.12.
//
//

#ifndef __BeatMatic__recorder__
#define __BeatMatic__recorder__

#include "juce.h"

class AudioEngineImpl;

//==============================================================================
/** A simple class that acts as an AudioIODeviceCallback and writes the
 incoming audio data to a WAV file.
 */
class AudioRecorder  : public AudioIODeviceCallback
{
public:
    AudioRecorder(AudioEngineImpl&);
    ~AudioRecorder();
    void startRecording(const File& file);
    void stopRecording(String callbackId);
    void stop();
    bool isRecording() const;
    void audioDeviceAboutToStart(AudioIODevice* device);
    void audioDeviceStopped();
    void audioDeviceIOCallback(const float** inputChannelData, int /*numInputChannels*/,
                               float** outputChannelData, int numOutputChannels,
                               int numSamples);
private:
    AudioEngineImpl& audioEngine;
    String callbackId;
    TimeSliceThread backgroundThread; // the thread that will write our audio data to disk
    ScopedPointer<AudioFormatWriter::ThreadedWriter> threadedWriter; // the FIFO used to buffer the incoming data
    double sampleRate;
    File outputFile;
    
    CriticalSection writerLock;
    AudioFormatWriter::ThreadedWriter* volatile activeWriter;
};


#endif /* defined(__BeatMatic__recorder__) */
