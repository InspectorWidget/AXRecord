//
//  AppLogger.m
//  TrackingFramework
//
//  Created by Sylvain Malacria on 02/04/15.
//  Copyright (c) 2015 Sylvain Malacria. All rights reserved.
//

#import "AppLogger.h"

@implementation AppLogger{
    NSString* previousApp;
    CFAbsoluteTime previousTime;
}

-(id)init{
    self = [super init];
    if(self){
        [self registerNotificationListener];
        previousApp=nil;
    }
    return self;
}



-(void)registerNotificationListener{
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(receiveAppChangeNotification:)
     name:[NSString stringWithUTF8String:vnrAppChangeNotification]
     object:nil];
    
}

-(void)receiveAppChangeNotification:(NSNotification *) notification{
    NSDictionary* userInfo = notification.userInfo;
    //retrieve app
    NSString* appName =(NSString*)userInfo[@"name"] ;
    
    //retrieve version
    //NSString* version = [AppLogger getVersionOfApp:appName];
    NSString* version = (NSString*)userInfo[@"version"];
    
    
  //  NSLog(@"version %@",version);
    //retrieve language
    NSString* language = [[NSLocale preferredLanguages] objectAtIndex:0];

    //retrieve time
    CFAbsoluteTime time = [userInfo[@"time"] doubleValue] ;
    
    if(previousApp!=nil){
        [self writeAppChange:previousApp from:previousTime til:time];
    }
    previousApp = appName;
    previousTime = time;
   
    NSLog(@"changed app for %@",appName);
    
}





-(void)writeAppChange:(NSString*)app from:(CFAbsoluteTime)inTime til:(CFAbsoluteTime)outTime{
    
}



// uses applescript to retrieve version number
+(NSString*)getVersionOfApp:(NSString*)appName{
    NSAppleEventDescriptor *eventDescriptor;
    //NSAppleScript *script ;
    NSString* source ;
   // NSDictionary* errorDic ;
    source = [NSString stringWithFormat:@"tell application \"%@\"\n"
                        @"set zeversion to version\n"
                        @"return zeversion\n"
                        @"end tell", appName];
    
    //script = [[NSAppleScript alloc] initWithSource:source];
    eventDescriptor = [[[NSAppleScript alloc] initWithSource:source] executeAndReturnError:nil];
    NSString* frontUrl = [eventDescriptor stringValue];
   
    return frontUrl;
}









@end
