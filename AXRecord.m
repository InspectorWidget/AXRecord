//
//  AXRecord.m
//  AXRecord
//
//  Created by Christian Frisson on 26/01/17.
//  Copyright © 2017 Christian Frisson and Sylvain Malacria. All rights reserved.
//

#include "AXRecord.h"
#include "AXRecordController.h"

AXRecordController* controller;

int start_ax(char* filename, float elementTrackDelay, float windowTrackDelay){

    controller = [[AXRecordController alloc] initWithFilename:[NSString stringWithUTF8String:filename] andElementTrackDelay:elementTrackDelay andWindowTrackDelay:windowTrackDelay ];
    NSLog(@"elementTrackDelay %f",elementTrackDelay);
    NSLog(@"windowTrackDelay %f",windowTrackDelay);

    return 0;
}

int stop_ax(){
    [controller stop];
    controller = nil;
    return 0;
}
