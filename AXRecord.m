//
//  AXRecord.m
//  AXRecord
//
//  Created by Christian Frisson on 26/01/17.
//  Copyright © 2017 Christian Frisson and Sylvain Malacria. All rights reserved.
//

#include "AXRecord.h"

#import <Cocoa/Cocoa.h>
#import "AXElementTracker.h"
#import "AppTracker.h"
#import "WindowTracker.h"
#import "XMLFileAccessMethods.h"

AXElementTracker* elementTracker;
WindowTracker* windowTracker;
AppTracker* appTracker;
XMLFileAccessMethods* xmlFileAccess;

int start_ax(char* filename, float elementTrackDelay, float windowTrackDelay){

    xmlFileAccess = [[XMLFileAccessMethods alloc] initWithFilename:[NSString stringWithUTF8String:filename]];
    elementTracker = [[AXElementTracker alloc] initWithDelay:elementTrackDelay andXMLFileAccess:xmlFileAccess];
    windowTracker = [[WindowTracker alloc] initWithDelay:windowTrackDelay andXMLFileAccess:xmlFileAccess];
    appTracker= [[AppTracker alloc] initWithXMLFileAccess:xmlFileAccess];

    NSLog(@"elementTrackDelay %f",elementTrackDelay);
    NSLog(@"windowTrackDelay %f",windowTrackDelay);

    return 0;
}

int stop_ax(){
    [appTracker stop];
    [windowTracker stop];
    [elementTracker stop];
    [xmlFileAccess close];

    appTracker = nil;
    windowTracker = nil;
    elementTracker = nil;
    xmlFileAccess = nil;

    return 0;
}
