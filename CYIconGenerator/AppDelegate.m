//
//  AppDelegate.m
//  CYIconGenerator
//
//  Created by SaturdayNight on 2017/12/18.
//  Copyright © 2017年 SaturdayNight. All rights reserved.
//

#import "AppDelegate.h"
#import "MasterViewController.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (nonatomic,strong) IBOutlet MasterViewController *masterViewController;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    // 1. Create the master View Controller
    self.masterViewController = [[MasterViewController alloc] initWithNibName:@"MasterViewController" bundle:nil];
    
    // 2. Add the view controller to the Window's content view
    [self.window.contentView addSubview:self.masterViewController.view];
    self.window.minSize = NSMakeSize(800, 600);
    self.window.maxSize = NSMakeSize(800, 600);
    self.window.contentView.frame = NSMakeRect(0, 0, 800, 600);
    self.masterViewController.view.frame = NSMakeRect(0, 0, 800, 600);
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
