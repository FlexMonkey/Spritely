//
//  AKFileInput.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/28/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's diskin2:
//  http://www.csounds.com/manual/html/diskin2.html
//

#import "AKFileInput.h"

@implementation AKFileInput
{
    NSString *_filename;
    BOOL isNormalized;
    float normalization;
}

- (instancetype)initWithFilename:(NSString *)fileName;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _filename = fileName;
        _speed = akp(1);
        _startTime = akp(0);
        isNormalized = NO;
        normalization = 1;
    }
    return self;
}

- (instancetype)initWithFilename:(NSString *)fileName
                           speed:(AKParameter *)speed
                       startTime:(AKConstant *)startTime
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _filename = fileName;
        _speed = speed;
        _startTime = startTime;
    }
    return self;
}

- (void)setOptionalSpeed:(AKParameter *)speed {
    _speed = speed;
}
- (void)setOptionalStartTime:(AKConstant *)startTime {
    _startTime = startTime;
}

- (void)normalizeTo:(float)maximumAmplitude {
    isNormalized = YES;
    normalization = maximumAmplitude;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];
    
    // Determine the maximum file amplitude
    if (isNormalized) [csdString appendFormat:@"ipeak filepeak \"%@\"\n", _filename];
    
    [csdString appendFormat:
     @"%@ diskin2 \"%@\", AKControl(%@), %@, 1\n",
     self, _filename, _speed, _startTime];
    
    // Normalize the output
    if (isNormalized) {
        [csdString appendFormat:@"%@ = %f * %@ / ipeak\n",
         self.leftOutput, normalization, self.leftOutput];
        [csdString appendFormat:@"%@ = %f * %@ / ipeak",
         self.rightOutput, normalization, self.rightOutput];
    }
    return csdString;
}


@end
