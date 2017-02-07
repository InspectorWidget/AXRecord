//
//  DisplayInfo.m
//  AXRecord
//
//  Created by Christian Frisson on 06/02/17.
//  Copyright © 2016 Christian Frisson. All rights reserved.
//

#import "DisplayInfo.h"


@implementation DisplayInfo

-(id)initWithDisplayID:(CGDirectDisplayID)displayID
  screenNumber:(NSNumber*)screenNumber
  screenSize:(CGSize)screenSize
  screenRotation:(double)screenRotation
  active:(BOOL)active
  main:(BOOL)main
  displayBounds:(CGRect)displayBounds
  pixelsHigh:(long)pixelsHigh
  pixelsWide:(long)pixelsWide
{
    self = [super init];
    if (self) {
        self.displayID = displayID;
        self.screenNumber = screenNumber;
        self.screenSize = screenSize;
        self.screenRotation = screenRotation;
        self.active = active;
        self.main = main;
        self.displayBounds = displayBounds;
        self.pixelsHigh = pixelsHigh;
        self.pixelsWide = pixelsWide;
    }
    return self;
}

-(NSNumber *)displayIDNumber
{
    return [NSNumber numberWithUnsignedInt:_displayID];
}

@end
