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
    
    private static var mandolins = [Mandolin]()
    
    static func initialise()
    {
        for i in 0 ..< 64
        {
            let mandolin = Mandolin(noteFrequency: 0);
            AKOrchestra.addInstrument(mandolin)
            
            InstrumentsProvider.mandolins.append(mandolin)
        }
        
        AKOrchestra.start()
    }
    
    static func getAvailableInstrument() -> Mandolin
    {
        return mandolins[instrumentIndex++]
    }
}
