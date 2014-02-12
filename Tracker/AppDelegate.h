//
//  AppDelegate.h
//  P2
//
//  Created by Justin Farlow on 11/10/12.
//  Copyright (c) 2012 Justin Farlow. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Manager.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) Manager *manager;

- (IBAction)saveAction:(id)sender;
@property (weak) IBOutlet NSView *MainViewOutlet;
- (IBAction)ImportWindow:(id)sender;
@property (weak) IBOutlet NSView *ImportViewOutlet;


@property (weak) IBOutlet NSArrayController *DocumentsControllerOutlet;
@property (weak) IBOutlet NSArrayController *ImportDataControllerOutlet;
@property (weak) IBOutlet NSArrayController *ImportRowControllerOutlet;


///Import Window Objects

@property (weak) IBOutlet NSTextField *TestMaxLineNumberOutlet;
@property (weak) IBOutlet NSTextField *TestLineNumberOutlet;
@property (unsafe_unretained) IBOutlet NSTextView *ImportRawViewOutlet;


- (IBAction)ParseImport:(id)sender;
- (IBAction)SetImportPreset:(id)sender;
- (IBAction)ImportIntoNewDoc:(id)sender;


//Document Window Objects
- (IBAction)Tab1Menu:(id)sender;
- (IBAction)Tab2Menu:(id)sender;
- (IBAction)Tab3Menu:(id)sender;
- (IBAction)Tab4Menu:(id)sender;

/////Track Menu Objects
- (IBAction)ChangeClassification:(id)sender;
- (IBAction)ClassificationChanged:(id)sender;
@property (weak) IBOutlet NSMenu *ClassificationMenuOutlet;



///recent menu
@property (weak) IBOutlet NSTableView *recentTableOutlet;

- (IBAction)MainMenu:(id)sender;
- (void)OpenDocument;

//get version number
- (NSString *)VersionNumber;

@end