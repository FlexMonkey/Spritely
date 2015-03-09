//
//  InstrumentsProvider.swift
//  Spritely
//
//  Created by Simon Gladman on 08/03/2015.
//  Copyright (c) 2015 Simon Gladman. All rights reserved.
//

struct InstrumentsProvider
{
    private static var instrumentIndex = 0
    
    private static var mandolins = [Instrument]()
    
    static func initialise()
    {
        for i in 0 ..< 64
        {
            let instrument = Instrument(noteFrequency: 0);
            AKOrchestra.addInstrument(instrument)
            
            InstrumentsProvider.mandolins.append(instrument)
        }
        
        AKOrchestra.start()
    }
    
    static func getAvailableInstrument() -> Instrument
    {
        return mandolins[instrumentIndex++]
    }
}
