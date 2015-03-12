//
//  Mandolin.swift
//  Spritely
//
//  Created by Simon Gladman on 08/03/2015.
//  Copyright (c) 2015 Simon Gladman. All rights reserved.
//

import Foundation

class BarInstrument: AKInstrument
{
    override init() {
        super.init()
        
        let note = BarNote()
        addNoteProperty(note.frequency)
        addNoteProperty(note.amplitude)

        // AKMarimba,AKVibes, AKMandolin
        
        let instrument = AKVibes() // AKVibes()
        instrument.frequency = note.frequency
        instrument.amplitude = note.amplitude
        connect(instrument)
        
        connect(AKAudioOutput(audioSource: instrument))
    }
}

class BarNote: AKNote {
    var frequency = AKNoteProperty(value: 0,    minimum: 0, maximum: 1000)
    var amplitude = AKNoteProperty(value: 0.04, minimum: 0, maximum: 0.25)
    
    override init() {
        super.init()
        addProperty(frequency)
        addProperty(amplitude)
    }
    
    convenience init(frequency: Float, amplitude: Float) {
        self.init()
        self.frequency.value = frequency
        self.amplitude.value = amplitude
    }
}
