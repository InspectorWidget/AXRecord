//
//  DisplaysGrabber.m
//  AXRecord
//
//  Created by Christian Frisson on 06/02/17.
//  Copyright © 2016 Christian Frisson. All rights reserved.
//

#import "WindowGrabber.h"
#import "DisplayInfo.h"

#import <AppKit/AppKit.h>
#import <IOKit/graphics/IOGraphicsLib.h>

@implementation DisplaysGrabber

+(NSArray*)getDisplaysList
{
    // http://fabiancanas.com/blog/detecting-displays
    // https://github.com/CdLbB/fb-rotate/blob/master/fb-rotate.c
    NSMutableArray *displaysList = [NSMutableArray new];
    CGDisplayCount onlineDisplays;
    CGDisplayCount activeDisplays;
    CGDisplayCount maxDisplays = 3;
    CGDirectDisplayID displayArray[] = {0,0,0};
    CGDisplayErr err = CGGetOnlineDisplayList (maxDisplays, displayArray, &onlineDisplays);
    if (err != kCGErrorSuccess){
           //NSLog(CGErrorToString(err));
           return displaysList;
    }

    NSArray *screens = [NSScreen screens];

    for (int i = 0; i < onlineDisplays; i++) {
        CGDirectDisplayID displayID = displayArray[i];
        BOOL active = CGDisplayIsActive(displayID);
        BOOL main = CGDisplayIsMain(displayID);
        CGSize screenSize = CGDisplayScreenSize(displayID); // width and height of a display in millimeters.
        CGRect displayBounds = CGDisplayBounds(displayID); // bounds of the display, expressed as a rectangle in the global display coordinate space (relative to the upper-left corner of the main display).
        long pixelsHigh = CGDisplayPixelsHigh(displayID);// display height in pixel units.
        long pixelsWide = CGDisplayPixelsWide(displayID);// display width in pixel units.
        //NSLog(@'pixelsHigh %l pixelsWide %l',pixelsHigh,pixelsWide);
        int screenNumber = CGDisplayUnitNumber(displayID); // a logical unit number for the specified display.
        double screenRotation = CGDisplayRotation(displayID);
        DisplayInfo* displayInfo = [[DisplayInfo alloc]
                initWithDisplayID:displayID
                screenNumber:[NSNumber numberWithUnsignedInt:i]
                screenSize:screenSize
                screenRotation:screenRotation
                active:active
                main:main
                displayBounds:displayBounds
                pixelsHigh:pixelsHigh
                pixelsWide:pixelsWide
        ];
        [displaysList addObject:displayInfo];

    }
     return  [displaysList copy];
}

@end
