//
//  TableController.h
//  AXRecord
//
//  Created by Sylvain Malacria on 15/02/16.
//  Copyright © 2016 Sylvain Malacria. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WindowTracker.h"

@interface TableController : NSObject <NSTableViewDataSource,NSTableViewDelegate,WindowTrackerDelegate>

@property (nonatomic,strong) NSArray* snapshots;
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSWindow *theWindow;

@end
