//
//  AKStereoSoundFileLooper.h
//  AudioKit
//
//  Auto-generated on 1/3/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKStereoAudio.h"
#import "AKParameter+Operation.h"

/** Read sampled sound from a table using cubic interpolation.

 Read sampled sound (stereo) from a table, with optional sustain and release looping, using cubic interpolation.
 */

@interface AKStereoSoundFileLooper : AKStereoAudio

// Type Helpers

/// Loop does not repeat
+ (AKConstant *)loopPlaysOnce;

/// Loop repeats indefinitely
+ (AKConstant *)loopRepeats;

/// Loop first plays forward, then plays backwards, and then repeats
+ (AKConstant *)loopPlaysForwardAndThenBackwards;

/// Instantiates the stereo sound file looper with all values
/// @param soundFile The sound file function table. [Default Value: ]
/// @param frequencyRatio The frequency ratio. Updated at Control-rate. [Default Value: 1]
/// @param amplitude The amplitude of the output [Default Value: 1]
/// @param loopMode Can be no-looping, normal forward looping, or forward and backward looping. [Default Value: AKSoundFileLooperModeNormal]
- (instancetype)initWithSoundFile:(AKFunctionTable *)soundFile
                   frequencyRatio:(AKParameter *)frequencyRatio
                        amplitude:(AKParameter *)amplitude
                         loopMode:(AKConstant *)loopMode;

/// Instantiates the stereo sound file looper with default values
/// @param soundFile The sound file function table.
- (instancetype)initWithSoundFile:(AKFunctionTable *)soundFile;

/// Instantiates the stereo sound file looper with default values
/// @param soundFile The sound file function table.
+ (instancetype)looperWithSoundFile:(AKFunctionTable *)soundFile;

/// The frequency ratio. [Default Value: 1]
@property AKParameter *frequencyRatio;

/// Set an optional frequency ratio
/// @param frequencyRatio The frequency ratio. Updated at Control-rate. [Default Value: 1]
- (void)setOptionalFrequencyRatio:(AKParameter *)frequencyRatio;

/// The amplitude of the output [Default Value: 1]
@property AKParameter *amplitude;

/// Set an optional amplitude
/// @param amplitude The amplitude of the output [Default Value: 1]
- (void)setOptionalAmplitude:(AKParameter *)amplitude;

/// Can be no-looping, normal forward looping, or forward and backward looping. [Default Value: AKSoundFileLooperModeNormal]
@property AKConstant *loopMode;

/// Set an optional loop mode
/// @param loopMode Can be no-looping, normal forward looping, or forward and backward looping. [Default Value: AKSoundFileLooperModeNormal]
- (void)setOptionalLoopMode:(AKConstant *)loopMode;



@end
