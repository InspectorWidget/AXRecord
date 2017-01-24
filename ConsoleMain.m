//
//  ConsoleMain.m
//  AXAll
//
//  Created by Christian Frisson on 24/01/17.
//  Copyright © 2017 Christian Frisson. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include "ConsoleController.h"

int main(int argc, const char * argv[]) {
	// From stackoverflow: Run NSRunLoop in a Cocoa command-line program
	// http://stackoverflow.com/a/17078933/5848413
	@autoreleasepool {
	        ConsoleController *obj = [[ConsoleController alloc] init];
	        [[NSRunLoop currentRunLoop] run];
	 }
	 return 0;
}
