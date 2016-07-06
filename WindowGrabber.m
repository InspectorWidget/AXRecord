//
//  WindowGrabber.m
//  AXAll
//
//  Created by Sylvain Malacria on 11/03/16.
//  Copyright © 2016 Sylvain Malacria. All rights reserved.
//

#import "WindowGrabber.h"
#import "VnrWindowInfo.h"

@implementation WindowGrabber

+(NSArray*)getWindowList
{
    NSMutableArray *windows = (NSMutableArray *)CFBridgingRelease(CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly | kCGWindowListExcludeDesktopElements, kCGNullWindowID));
    NSMutableArray *vnrWindows = [NSMutableArray new];
    for (NSDictionary *window in windows) {
        int layer = [[window objectForKey:@"kCGWindowLayer"] intValue];
        
        if(layer==0){
            BOOL onScreen = [[window objectForKey:@"kCGWindowIsOnscreen"] boolValue];
            NSDictionary* bounds = [window objectForKey:@"kCGWindowBounds"];
            int x = [[bounds objectForKey:@"X"] intValue];
            int y = [[bounds objectForKey:@"Y"] intValue];
            int w = [[bounds objectForKey:@"Width"] intValue];
            int h = [[bounds objectForKey:@"Height"] intValue];
            NSString *owner = [window objectForKey:@"kCGWindowOwnerName"];
            NSString *name = [window objectForKey:@"kCGWindowName"];
            pid_t ownerPID = [[window objectForKey:@"kCGWindowOwnerPID"] intValue];
            CGWindowID windowID = [[window objectForKey:@"kCGWindowNumber"] intValue];

            VnrWindowInfo* winfo = [[VnrWindowInfo alloc] initWithFrame:CGRectMake(x,y,w,h) title:name owner:owner ownerPID:ownerPID andWindowID:windowID];
            [winfo setIsOnScreen:onScreen];
            [vnrWindows addObject:winfo];
        }
    }
        
 
    return  [vnrWindows copy];

}





@end
