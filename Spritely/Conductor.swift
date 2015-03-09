//
//  Conductor.swift
//  Spritely
//
//  Created by Aurelius Prochazka on 3/8/15.
//  Copyright (c) 2015 Simon Gladman. All rights reserved.
//

class Conductor {

    var barInstrument = BarInstrument()

    init() {
        AKOrchestra.addInstrument(barInstrument)
        AKOrchestra.start()
    }
    
    func play(frequency: Float, amplitude: Float) {
        let barNote = BarNote(frequency: frequency, amplitude: amplitude)
        barNote.duration.value = 3.0
        barInstrument.playNote(barNote)
    }
}
