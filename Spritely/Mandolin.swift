//
//  Mandolin.swift
//  Spritely
//
//  Created by Simon Gladman on 08/03/2015.
//  Copyright (c) 2015 Simon Gladman. All rights reserved.
//

import Foundation

class Mandolin: AKInstrument
{
    private let mandolin:AKMandolin
    
    init(noteFrequency: Double)
    {
        mandolin = AKMandolin()
        
        super.init()
        
        let frequency = AKInstrumentProperty(value: Float(noteFrequency),  minimum: 0, maximum: 1000)
        let amplitude = AKInstrumentProperty(value: 0.04, minimum: 0,   maximum: 0.25)
        
        addProperty(frequency)
        addProperty(amplitude)

        mandolin.frequency = frequency
        mandolin.amplitude = amplitude
        mandolin.bodySize = 0.7.ak
        connect(mandolin)
        
        connect(AKAudioOutput(audioSource: mandolin))
    }
    
    func setFrequency(value: Float)
    {
         mandolin.frequency.value = value
    }
    
    func setAmplitude(value: Float)
    {
        mandolin.amplitude.value = value
    }
}
