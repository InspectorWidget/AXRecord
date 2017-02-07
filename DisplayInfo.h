//
//  DisplayInfo.h
//  AXRecord
//
//  Created by Christian Frisson on 06/02/17.
//  Copyright © 2016 Christian Frisson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DisplayInfo : NSObject

@property CGDirectDisplayID displayID;
@property NSNumber* screenNumber;
@property CGSize screenSize; // width and height of a display in millimeters.
@property double screenRotation; // rotation angle of a display in degrees
@property BOOL active;
@property BOOL main;
@property CGRect displayBounds; // bounds of the display, expressed as a rectangle in the global display coordinate space (relative to the upper-left corner of the main display).
@property long pixelsHigh;// display height in pixel units.
@property long pixelsWide;// display width in pixel units.

-(id)initWithDisplayID:(CGDirectDisplayID)displayID
  screenNumber:(NSNumber*)screenNumber
  screenSize:(CGSize)screenSize
  screenRotation:(double)screenRotation
  active:(BOOL)active
  main:(BOOL)main
  displayBounds:(CGRect)displayBounds
  pixelsHigh:(long)pixelsHigh
  pixelsWide:(long)pixelsWide
  ;

-(NSNumber *)displayIDNumber;

@end
