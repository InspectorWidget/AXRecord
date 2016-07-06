//
//  WindowTracker.m
//  TrackingFramework
//
//  Created by Sylvain Malacria on 10/07/15.
//  Copyright (c) 2015 Sylvain Malacria. All rights reserved.
//

#import "WindowTracker.h"
#import "WindowInfoEvent.h"

@implementation WindowTracker{
    NSMutableArray* snapshots;
}

-(id)initWithDelay:(float)delay{
    self = [super init];
    if(self){
        snapshots = nil;
        
        
        NSLog(@"init windowTracker");
        [self initSnapshots];
        //[NSTimer scheduledTimerWithTimeInterval:delay target:self selector:@selector(updateMyWindows) userInfo:nil repeats:YES];
        [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(printSnapshots) userInfo:nil repeats:YES];
    }
    return self;
}


-(void)initSnapshots{
    snapshots = [NSMutableArray new];
    for (AYWindowInfo *info in [AYWindowInfo visibleWindowsOnCurrentSpaceFromFrontToBack]) {
        [snapshots addObject:[info snapshot]];
    }
}


-(void)printSnapshots{
    int depth=0;
    snapshots = [[WindowTracker currentSnapshots] copy];
    NSMutableString* print = [NSMutableString new];
    [print appendString:@"\n"];
    for(AYWindowSnapshot* mysnap in snapshots){
        CGRect frame= mysnap.rect;
        [print appendString:[NSString stringWithFormat:@"%d - %@ - %@ \n",++depth,[mysnap ownerApplication],NSStringFromRect(frame)]];

    }
    [print appendString:@"\n\n\n"];
    NSLog(@"%@",print);
}


+(NSArray*)currentSnapshots{
    NSMutableArray* result = [NSMutableArray new];
    for (AYWindowInfo *info in [AYWindowInfo visibleWindowsOnCurrentSpaceFromFrontToBack]) {
        [result addObject:[info snapshot]];
    }
    return result;
}

// Method that returns an array of AYWindowSnapshot that are contained in one array but not in the other
// if no winwow was found, return nil
+(NSArray*)getDisposedWindowsBetween:(NSArray*)oldSnaps and:(NSArray*)newSnaps{
    NSMutableArray* result = [NSMutableArray array];
    for (int i=0; i<[oldSnaps count];i++) {
        AYWindowSnapshot *snapshot1 = [oldSnaps objectAtIndex:i];
        BOOL contains = NO;
        for (AYWindowSnapshot *snapshot2 in newSnaps) {
            if([snapshot1 windowID]==[snapshot2 windowID]){
                contains = YES;
                break;
            }
        }
        if(!contains){
            WindowInfoEvent* event = [[WindowInfoEvent alloc] initWith:snapshot1 atLayerNumber:i forEventType:vnrWindowDisappeared atTimestamp:CFAbsoluteTimeGetCurrent()];
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
+(NSArray*)getOpenedWindowsBetween:(NSArray*)oldSnaps and:(NSArray*)newSnaps{
    NSMutableArray* result = [NSMutableArray array];
    for (int i=0; i<[oldSnaps count];i++) {
        AYWindowSnapshot *snapshot1 = [newSnaps objectAtIndex:i];
        BOOL contains = NO;
        for (AYWindowSnapshot *snapshot2 in oldSnaps) {
            if([snapshot1 windowID]==[snapshot2 windowID]){
                contains = YES;
                break;
            }
        }
        if(!contains){
            WindowInfoEvent* event = [[WindowInfoEvent alloc] initWith:snapshot1 atLayerNumber:i forEventType:vnrWindowAppeared atTimestamp:CFAbsoluteTimeGetCurrent()];
            [result addObject:event];
        }
    }
    if([result count]>0){
        return result;
    }
    return nil;
}




-(void)updateMyWindows{
    NSMutableArray* newArray =[NSMutableArray array];
    for (AYWindowInfo *info in [AYWindowInfo visibleWindowsOnCurrentSpaceFromFrontToBack]) {
        [newArray addObject:[info snapshot]];
    }
    
    if([newArray count]<[snapshots count]){
        // here window(s) closed
        // find windows that are gone and send events
        NSArray* disposedWindowsEvents = [WindowTracker getDisposedWindowsBetween:snapshots and:newArray];
        for(WindowInfoEvent* event in disposedWindowsEvents){
            if([self.windowTrackerDelegate respondsToSelector:@selector(sendWindowInfoEvent:)]){
                [self.windowTrackerDelegate sendWindowInfoEvent:event];
            }
        }
        
    }
    else if([newArray count]>[snapshots count]){
        // here window(s) opened
        // find windows that are gone and send events
        NSArray* openedWindowsEvents = [WindowTracker getOpenedWindowsBetween:snapshots and:newArray];
        for(WindowInfoEvent* event in openedWindowsEvents){
            if([self.windowTrackerDelegate respondsToSelector:@selector(sendWindowInfoEvent:)]){
                [self.windowTrackerDelegate sendWindowInfoEvent:event];
            }
        }
        
    }
    else {
        //  test if order of windows has changed
        // if yes, window(s)reordered
        NSArray* reorderedSnaps =[WindowTracker orderDiffersBetween:newArray and:snapshots];
        
        if([reorderedSnaps count]>0){
            for (WindowInfoEvent *event in reorderedSnaps){
                
                if([self.windowTrackerDelegate respondsToSelector:@selector(sendWindowInfoEvent:)]){
                    [self.windowTrackerDelegate sendWindowInfoEvent:event];
                }
            }
        }
        else {
            
            // test if position of a window has changed
            // if yes, window is currently moving. Wait for stable position or write everything????
            WindowInfoEvent * movingWindow = [WindowTracker getIDofMovingWindowBetween:newArray and:snapshots];
            if(movingWindow){
                if([self.windowTrackerDelegate respondsToSelector:@selector(sendWindowInfoEvent:)]){
                    [self.windowTrackerDelegate sendWindowInfoEvent:movingWindow];
                    
                    NSLog(@"window %@ was moved",[movingWindow.snapshot title]);
                }
            }
            
            
            WindowInfoEvent * resizedWindow = [WindowTracker getIDofResizedWindowBetween:newArray and:snapshots];
            if(resizedWindow){
                if([self.windowTrackerDelegate respondsToSelector:@selector(sendWindowInfoEvent:)]){
                    [self.windowTrackerDelegate sendWindowInfoEvent:resizedWindow];
                    
                    NSLog(@"window %@ was resized",[resizedWindow.snapshot title]);
                }
            }
            
        }
        
        
        
        
    }
    
    
    snapshots = newArray;
    
}


// Should be called only if same number of items
// and windows not reordered
// returns 0 if no window moving
// return the id of the moving window otherwise
+(WindowInfoEvent* )getIDofMovingWindowBetween:(NSArray*)newArray and:(NSArray*)previousArray{
    NSInteger nbNew = [newArray count];
    for(int i=0; i <nbNew;i++){
        CGPoint location1 =[((AYWindowSnapshot *)[newArray objectAtIndex:i]) rect].origin;
        CGPoint location2 =[((AYWindowSnapshot *)[previousArray objectAtIndex:i]) rect].origin;
        if((location1.x!=location2.x)||(location1.y!=location2.y)){
            WindowInfoEvent* event = [[WindowInfoEvent alloc] initWith:[newArray objectAtIndex:i] atLayerNumber:i forEventType:vnrWindowMoved atTimestamp:CFAbsoluteTimeGetCurrent()];
            return event ;
        }
    }
    return nil;
}

// Should be called only if same number of items
// and windows not reordered
// returns 0 if no window moving
// return the id of the moving window otherwise
+(WindowInfoEvent*)getIDofResizedWindowBetween:(NSArray*)newArray and:(NSArray*)previousArray{
    NSInteger nbNew = [newArray count];
    for(int i=0; i <nbNew;i++){
        CGSize size1 =[((AYWindowSnapshot *)[newArray objectAtIndex:i]) rect].size;
        CGSize size2 =[((AYWindowSnapshot *)[previousArray objectAtIndex:i]) rect].size;
        if((size1.height!=size2.height)||(size1.width!=size2.width)){
            WindowInfoEvent* event = [[WindowInfoEvent alloc] initWith:[newArray objectAtIndex:i] atLayerNumber:i forEventType:vnrWindowResized atTimestamp:CFAbsoluteTimeGetCurrent()];
            return event ;
        }
    }
    return nil;
}



//return true if the order between the two arrays differ
// should be called only if same number of items, but still testing
// and return nil if different size of arrays
// empty array if same order
// array with reordered snaps if reordered
+(NSArray*)orderDiffersBetween:(NSArray*)newArray and:(NSArray*)previousArray{
    NSInteger nbNew = [newArray count];
    NSInteger nbPrevious = [previousArray count];
    NSMutableArray* reorderedSnapsList = [NSMutableArray array];
    NSMutableArray* reorderedWindowId = [NSMutableArray array];
    if(nbNew!=nbPrevious){
        return nil;
    }
    else {
        for(int i=0; i<nbNew;i++){
            int idNew = (int)[((AYWindowSnapshot *)[newArray objectAtIndex:i]) windowID];
            int idOld = (int)[((AYWindowSnapshot *)[previousArray objectAtIndex:i]) windowID];
            if(idNew!=idOld){
                // case of a reorder
                [reorderedWindowId addObject:[NSNumber numberWithInt:idNew]];
            }
        }
        //at this point, we should have alist of window ID that were reordered
        // we browse newsnapshot and feed the result array
        CFAbsoluteTime timestamp = CFAbsoluteTimeGetCurrent();
        for(int i=0; i<nbNew;i++){
            AYWindowSnapshot * snapshot = [newArray objectAtIndex:i];
            for(NSNumber* numberId in reorderedWindowId){
                
                if(((int)[snapshot windowID])==[numberId intValue]){
                    WindowInfoEvent* event = [[WindowInfoEvent alloc] initWith:snapshot atLayerNumber:i forEventType:vnrWindowReordered atTimestamp:timestamp];
                    [reorderedSnapsList addObject:event];
                    break;
                }
            }
        }
        return reorderedSnapsList;
    }
    
    
    return reorderedSnapsList;
}


// return true if there is at least two snapshots with at least one different feature
+(BOOL)differenceBetween:(NSArray*)newArray and:(NSArray*)previousArray{
    if(previousArray){
        NSEnumerator *otherEnum = [newArray objectEnumerator];
        for (AYWindowSnapshot *snapshot in previousArray) {
            
            AYWindowSnapshot *snap2 =[otherEnum nextObject];
            BOOL difference =[WindowTracker differenceBetweenSnap:snapshot andSnap:snap2];
            if (difference) {
                //We have found a pair of two different objects.
                return YES;
            }
        }
        return NO;
    }
    else {
        return YES;
    }
}


// return true if at least one of the feature of these snapshots differ
+(BOOL)differenceBetweenSnap:(AYWindowSnapshot*)snap1 andSnap:(AYWindowSnapshot*)snap2{
    return (!CGPointEqualToPoint(snap1.rect.origin,snap2.rect.origin)||!CGSizeEqualToSize(snap1.rect.size,snap2.rect.size)||![snap1.ownerApplication isEqualToString:snap2.ownerApplication]);
}



//
//-(void)printSnapshots{
//    int depth=0;
//    for(AYWindowSnapshot* snap in snapshots){
//        NSLog(@"%@ - %@ - %u - %d",[snap ownerApplication], NSStringFromRect([snap rect]),[snap windowID], depth++);
//    }
//}

@end
