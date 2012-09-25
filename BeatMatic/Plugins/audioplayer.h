//
//  audioplayer.h
//  BeatMatic
//
//  Created by Martin Percossi on 13.09.12.
//
//

#ifndef __BeatMatic__audioplayer__
#define __BeatMatic__audioplayer__

#include "juce.h"

class AudioPlayer : public PositionableAudioSource, public ChangeBroadcaster {
public:
    //==============================================================================
    /** Creates an AudioPlayer for a given reader.
     
     @param sourceReader                     the reader to use as the data source - this must
     not be null
     @param deleteReaderWhenThisIsDeleted    if true, the reader passed-in will be deleted
     when this object is deleted; if false it will be
     left up to the caller to manage its lifetime
     */
    AudioPlayer (AudioFormatReader* sourceReader,
                             bool deleteReaderWhenThisIsDeleted);
    
    /** Destructor. */
    ~AudioPlayer();
    
    //==============================================================================
    /** Toggles loop-mode.
     
     If set to true, it will continuously loop the input source. If false,
     it will just emit silence after the source has finished.
     
     @see isLooping
     */
    void setLooping (bool shouldLoop);
    
    /** Returns whether loop-mode is turned on or not. */
    bool isLooping() const                                      { return looping; }
    
    /** Returns the reader that's being used. */
    AudioFormatReader* getAudioFormatReader() const noexcept    { return reader; }
    
    //==============================================================================
    /** Implementation of the AudioSource method. */
    void prepareToPlay (int samplesPerBlockExpected, double sampleRate);
    
    /** Implementation of the AudioSource method. */
    void releaseResources();
    
    /** Implementation of the AudioSource method. */
    void getNextAudioBlock (const AudioSourceChannelInfo& bufferToFill);
    
    //==============================================================================
    /** Implements the PositionableAudioSource method. */
    void setNextReadPosition (int64 newPosition);
    
    /** Implements the PositionableAudioSource method. */
    int64 getNextReadPosition() const;
    
    /** Implements the PositionableAudioSource method. */
    int64 getTotalLength() const;
    
private:
    //==============================================================================
    OptionalScopedPointer<AudioFormatReader> reader;
    
    int64 volatile nextPlayPos;
    bool volatile looping;
    bool justFinished;
    
    void readBufferSection (int start, int length, AudioSampleBuffer& buffer, int startSample);
    
    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR (AudioPlayer);
    
};



#endif /* defined(__BeatMatic__audioplayer__) */
