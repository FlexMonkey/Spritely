//
//  Conductor.swift
//  Spritely
//
//  Created by Aurelius Prochazka on 3/8/15.
//  Copyright (c) 2015 Simon Gladman. All rights reserved.
//

class Conductor {

    var marimbaInstrument = MarimbaInstrument()
    var vibesInstrument = VibesInstrument()
    var mandolinInstrument = MandolinInstrument()

    init()
    {
        AKOrchestra.addInstrument(marimbaInstrument)
        AKOrchestra.addInstrument(vibesInstrument)
        AKOrchestra.addInstrument(mandolinInstrument)
        AKOrchestra.start()
    }
    
    func play(#frequency: Float, amplitude: Float, instrument: Instruments)
    {
        let barNote = BarNote(frequency: frequency, amplitude: amplitude)
        barNote.duration.value = 3.0
        
        switch instrument
        {
        case .mandolin:
            mandolinInstrument.playNote(barNote)
        case .marimba:
            marimbaInstrument.playNote(barNote)
        case .vibes:
            vibesInstrument.playNote(barNote)
        }
    }
}

