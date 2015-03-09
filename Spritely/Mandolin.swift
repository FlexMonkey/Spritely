//
//  Mandolin.swift
//  Spritely
//
//  Created by Simon Gladman on 08/03/2015.
//  Copyright (c) 2015 Simon Gladman. All rights reserved.
//

import Foundation

class Instrument: AKInstrument
{
    private let instrument:AKVibes
    
    init(noteFrequency: Double)
    {
        instrument = AKVibes()
        
        super.init()
        
        let frequency = AKInstrumentProperty(value: Float(noteFrequency),  minimum: 0, maximum: 1000)
        let amplitude = AKInstrumentProperty(value: 0.04, minimum: 0,   maximum: 0.25)
        
        addProperty(frequency)
        addProperty(amplitude)

        instrument.frequency = frequency
        instrument.amplitude = amplitude
        
        connect(instrument)
        
        connect(AKAudioOutput(audioSource: instrument))
    }
    
    func setFrequency(value: Float)
    {
         instrument.frequency.value = value
    }
    
    func setAmplitude(value: Float)
    {
        instrument.amplitude.value = value
    }
}
