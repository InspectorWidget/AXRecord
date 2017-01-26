//
//  WindowTracker.m
//  TrackingFramework
//
//  Created by Sylvain Malacria on 10/07/15.
//  Copyright (c) 2015 Sylvain Malacria. All rights reserved.
//

#import "WindowTracker.h"
#import "WindowInfoEvent.h"
#import "WindowGrabber.h"
#import "VnrWindowInfo.h"
#include "platform.h"

@implementation WindowTracker{
    NSArray* windowsInfoArray;
  
}

-(id)initWithDelay:(float)delay andXMLFileAccess:(XMLFileAccessMethods*)xml{
    self = [super init];
    if(self){
        NSLog(@"init windowTracker");
        windowsInfoArray = [WindowGrabber getWindowList];
        self.xmlFileAccess = xml;
        if (!_timer) {
            _timer = [NSTimer scheduledTimerWithTimeInterval:delay target:self selector:@selector(processTimer) userInfo:nil repeats:YES];
        }
      
    }
    return self;
}



-(void)printWindows{
    int depth=0;
    
    NSMutableString* print = [NSMutableString new];
    [print appendString:@"\n"];
    for(VnrWindowInfo* window in windowsInfoArray){
        CGRect frame= window.frame;
        [print appendString:[NSString stringWithFormat:@"%d - %@ - fr:%@ \n",++depth,[window ownerName],NSStringFromRect(frame)]];

    }
    [print appendString:@"\n\n\n"];
    NSLog(@"%@",print);
}



+(NSArray*)getCurrentWindowsInfo{
    return [WindowGrabber getWindowList];
}

-(void)processTimer{
    [self updateMyWindows];
}

# pragma mark called periodically to check wether or not events should be fired
-(void)updateMyWindows{
    uint64 clock = os_gettime_ns();
    
    NSArray* newWindowsInfoArray = [WindowGrabber getWindowList];
    
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    
    if([newWindowsInfoArray count]<[windowsInfoArray count]){
        // here window(s) closed
        // find windows that are gone and send events
        NSArray* disposedWindowsEvents = [WindowTracker getDisposedWindowsBetween:newWindowsInfoArray and:windowsInfoArray atTime:time atClock:clock];
        for(WindowInfoEvent* event in disposedWindowsEvents){
            if([self.windowTrackerDelegate respondsToSelector:@selector(windowInfoEventHappened:)]){
                [self.windowTrackerDelegate windowInfoEventHappened:event];
            }
        }
        
    }
    else if([newWindowsInfoArray count]>[windowsInfoArray count]){
        // here window(s) opened
        // find windows that are gone and send events
        NSArray* openedWindowsEvents = [WindowTracker getOpenedWindowsBetween:newWindowsInfoArray and:windowsInfoArray atTime:time atClock:clock];
        for(WindowInfoEvent* event in openedWindowsEvents){
            if([self.windowTrackerDelegate respondsToSelector:@selector(windowInfoEventHappened:)]){
                [self.windowTrackerDelegate windowInfoEventHappened:event];
            }
        }
        
    }
    else {
        //  test if order of windows has changed
        // if yes, window(s)reordered
        NSArray* reorderedSnaps =[WindowTracker orderDiffersBetween:newWindowsInfoArray and:windowsInfoArray atTime:time atClock:clock];
        
        if([reorderedSnaps count]>0){
            for (WindowInfoEvent *event in reorderedSnaps){
                
                if([self.windowTrackerDelegate respondsToSelector:@selector(windowInfoEventHappened:)]){
                    
                    [self.windowTrackerDelegate windowInfoEventHappened:event];
                }
            }
        }
        else {
            
            // test if position of a window has changed
            // if yes, window is currently moving. Wait for stable position or write everything????
            WindowInfoEvent * movingWindow = [WindowTracker getIDofMovingWindowBetween:newWindowsInfoArray and:windowsInfoArray atTime:time atClock:clock];
            if(movingWindow){
                if([self.windowTrackerDelegate respondsToSelector:@selector(windowInfoEventHappened:)]){
                    [self.windowTrackerDelegate windowInfoEventHappened:movingWindow];
                    
                }
            }
            
            
            WindowInfoEvent * resizedWindow = [WindowTracker getIDofResizedWindowBetween:newWindowsInfoArray and:windowsInfoArray atTime:time atClock:clock];
            if(resizedWindow){
                if([self.windowTrackerDelegate respondsToSelector:@selector(windowInfoEventHappened:)]){
                    [self.windowTrackerDelegate windowInfoEventHappened:resizedWindow];
                }
            }
            
        }
        
        
        
        
    }
    
    windowsInfoArray = newWindowsInfoArray;
    
}






// Method that returns an array of AYWindowSnapshot that are contained in one array but not in the other
// if no winwow was found, return nil
+(NSArray*)getDisposedWindowsBetween:(NSArray*)newWindowsInfos
                                 and:(NSArray*)oldWindowsInfos
                              atTime:(NSTimeInterval)time
                             atClock:(uint64)clock
{
    NSMutableArray* result = [NSMutableArray array];
    for (int i=0; i<[oldWindowsInfos count];i++) {
        VnrWindowInfo *info1 = [oldWindowsInfos objectAtIndex:i];
        BOOL contains = NO;
        for (VnrWindowInfo *info2 in newWindowsInfos) {
            if([info1 windowID]==[info2 windowID]){
                contains = YES;
                break;
            }
        }
        if(!contains){
            WindowInfoEvent* event = [[WindowInfoEvent alloc] initWith:info1 atLayerNumber:i forEventType:vnrWindowDisappeared atTimestamp:time atClock:clock andAllWindows:newWindowsInfos];
            [result addObject:event];
        }
    }
    if([result count]>0){
        return result;
    }
    return nil;
}



// Method that returns an array of AYWindowSnapshot that are contained in one array but not in the other
// if no winwow was found, return nil
+(NSArray*)getOpenedWindowsBetween:(NSArray*)newWindowsInfos
                               and:(NSArray*)oldWindowsInfos
                            atTime:(NSTimeInterval)time
                           atClock:(uint64)clock
{
    NSMutableArray* result = [NSMutableArray array];
    for (int i=0; i<[oldWindowsInfos count];i++) {
        VnrWindowInfo *info1 = [newWindowsInfos objectAtIndex:i];
        BOOL contains = NO;
        for (VnrWindowInfo *info2 in oldWindowsInfos) {
            if([info1 windowID]==[info2 windowID]){
                contains = YES;
                break;
            }
        }
        if(!contains){
            WindowInfoEvent* event = [[WindowInfoEvent alloc] initWith:info1 atLayerNumber:i forEventType:vnrWindowAppeared atTimestamp:time atClock:clock andAllWindows:newWindowsInfos];
            [result addObject:event];
        }
    }
    if([result count]>0){
        return result;
    }
    return nil;
}






// Should be called only if same number of items
// and windows not reordered
// returns 0 if no window moving
// return the id of the moving window otherwise
+(WindowInfoEvent* )getIDofMovingWindowBetween:(NSArray*)newArray
                                           and:(NSArray*)previousArray
                                        atTime:(NSTimeInterval)time
                                       atClock:(uint64)clock
{
    NSInteger nbNew = [newArray count];
    for(int i=0; i <nbNew;i++){
        VnrWindowInfo* info1 =[newArray objectAtIndex:i];
        VnrWindowInfo* info2 =[previousArray objectAtIndex:i];

        CGPoint location1 =[info1 frame].origin;
        CGPoint location2 =[info2 frame].origin;
                if((location1.x!=location2.x)||(location1.y!=location2.y)){
            WindowInfoEvent* event = [[WindowInfoEvent alloc] initWith:[newArray objectAtIndex:i] atLayerNumber:i forEventType:vnrWindowMoved atTimestamp:time atClock:clock andAllWindows:newArray];
            return event ;
        }
    }
    
    return nil;
}

// Should be called only if same number of items
// and windows not reordered
// returns 0 if no window moving
// return the id of the moving window otherwise
+(WindowInfoEvent*)getIDofResizedWindowBetween:(NSArray*)newArray
                                           and:(NSArray*)previousArray
                                        atTime:(NSTimeInterval)time
                                       atClock:(uint64)clock
{
    NSInteger nbNew = [newArray count];
    for(int i=0; i <nbNew;i++){
        CGSize size1 =[((VnrWindowInfo *)[newArray objectAtIndex:i]) frame].size;
        CGSize size2 =[((VnrWindowInfo *)[previousArray objectAtIndex:i]) frame].size;
        
        if((size1.height!=size2.height)||(size1.width!=size2.width)){
            WindowInfoEvent* event = [[WindowInfoEvent alloc] initWith:[newArray objectAtIndex:i] atLayerNumber:i forEventType:vnrWindowResized atTimestamp:time atClock:clock andAllWindows:newArray];
            return event ;
        }
    }
    return nil;
}



/**
 return true if the order between the two arrays differ
 should be called only if same number of items, but still testing
 and return nil if different size of arrays
 empty array if same order
 array with reordered snaps if reordered
 @param two arrays of windowInfos we want to compare
 @return true if the order between the two arrays differ

 */


+(NSArray*)orderDiffersBetween:(NSArray*)newArray
                           and:(NSArray*)previousArray
                        atTime:(NSTimeInterval)time
                       atClock:(uint64)clock
{
    NSInteger nbNew = [newArray count];
    NSInteger nbPrevious = [previousArray count];
    NSMutableArray* reorderedSnapsList = [NSMutableArray array];
    NSMutableArray* reorderedWindowId = [NSMutableArray array];
    if(nbNew!=nbPrevious){
        return nil;
    }
    else {
        for(int i=0; i<nbNew;i++){
            int idNew = (int)[((VnrWindowInfo *)[newArray objectAtIndex:i]) windowID];
            int idOld = (int)[((VnrWindowInfo *)[previousArray objectAtIndex:i]) windowID];
            if(idNew!=idOld){
                // case of a reorder
                [reorderedWindowId addObject:[NSNumber numberWithInt:idNew]];
            }
        }
        //at this point, we should have alist of window ID that were reordered
        // we browse newsnapshot and feed the result array
        for(int i=0; i<nbNew;i++){
            VnrWindowInfo * wInfo = [newArray objectAtIndex:i];
            for(NSNumber* numberId in reorderedWindowId){
                
                if(((int)[wInfo windowID])==[numberId intValue]){
                    WindowInfoEvent* event = [[WindowInfoEvent alloc] initWith:wInfo atLayerNumber:i forEventType:vnrWindowReordered atTimestamp:time atClock:clock andAllWindows:newArray];
                    [reorderedSnapsList addObject:event];
                    break;
                }
            }
        }
        return reorderedSnapsList;
    }
    
    
    return reorderedSnapsList;
}





# pragma mark unused/deprecated below

//// return true if there is at least two snapshots with at least one different feature
//+(BOOL)differenceBetween:(NSArray*)newArray and:(NSArray*)previousArray{
//    if(previousArray){
//        NSEnumerator *otherEnum = [newArray objectEnumerator];
//        for (AYWindowInfo *info1 in previousArray) {
//            
//            AYWindowInfo *info2 =[otherEnum nextObject];
//            BOOL difference =[WindowTracker differenceBetweenWindow:info1 andWindow:info2];
//            if (difference) {
//                //We have found a pair of two different objects.
//                return YES;
//            }
//        }
//        return NO;
//    }
//    else {
//        return YES;
//    }
//}


//// return true if at least one of the feature of these snapshots differ
//+(BOOL)differenceBetweenWindow:(AYWindowInfo*)info1 andWindow:(AYWindowInfo*)info2{
//    return (!CGPointEqualToPoint(info1.rect.origin,info2.rect.origin)||!CGSizeEqualToSize(info1.rect.size,info2.rect.size)||![info1.ownerApplication.localizedName isEqualToString:info2.ownerApplication.localizedName]);
//}



- (void)stop{
    if ([_timer isValid]) {
            [_timer invalidate];
    }
    _timer = nil;
}





@end
