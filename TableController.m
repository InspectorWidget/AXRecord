//
//  TableController.m
//  AXAll
//
//  Created by Sylvain Malacria on 15/02/16.
//  Copyright © 2016 Sylvain Malacria. All rights reserved.
//

#import "TableController.h"
#import "AXAll.h"
#import "AppTracker.h"
#import "WindowGrabber.h"

@implementation TableController{
    AXAll* axAll;
    WindowTracker* windowTracker;
    AppTracker* appTracker;
    XMLFileAccessMethods* xmlFileAccess;
}


// main function

-(id)init{
    self = [super init];
    if(self){
        [self refresh];
        xmlFileAccess = [XMLFileAccessMethods new];
        
        axAll = [[AXAll alloc] initWithXMLFileAccess:xmlFileAccess];
        
        windowTracker = [[WindowTracker alloc] initWithDelay:0.2 andXMLFileAccess:xmlFileAccess];
        [windowTracker setWindowTrackerDelegate:self];
       
        appTracker= [[AppTracker alloc] initWithXMLFileAccess:xmlFileAccess];
        
        }
    return self;
}





-(void)refresh{
    NSMutableArray* currSnaps = [NSMutableArray array];
    for (VnrWindowInfo *info in [WindowGrabber getWindowList]) {
        [currSnaps addObject:info];
    }
    self.snapshots = currSnaps;
    //[self.tableView reloadData];
}
- (IBAction)doRefresh:(id)sender {
    [self refresh];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [self.snapshots count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    VnrWindowInfo *snapshot = [self.snapshots objectAtIndex:row];
    NSString *identifier = [tableColumn identifier];
    if([identifier isEqualToString:@"title"]) {
        return snapshot.title;
    } else if([identifier isEqualToString:@"ownerApplication"]) {
        return snapshot.ownerName;
    } /*else if([identifier isEqualToString:@"representedURL"]) {
        return [[snapshot.representedURL URLByStandardizingPath] absoluteString];
    }*/
    
    return nil;
}

-(void)tableViewSelectionDidChange:(NSNotification *)notification
{
    //    NSInteger row = [self.windowTableView selectedRow];
    //    if(row >= 0) {
    //        windowView.selection = [windowView.snapshots objectAtIndex:row];
    //    } else {
    //        windowView.selection = nil;
    //    }
    //    [windowView setNeedsDisplay:YES];
}






-(void)windowInfoEventHappened:(WindowInfoEvent*)windowEvent{
    [xmlFileAccess addXMLElementToFileForWindowEvent:windowEvent];
}


@end
