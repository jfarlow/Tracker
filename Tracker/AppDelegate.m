//
//  AppDelegate.m
//  P2
//
//  Created by Justin Farlow on 11/10/12.
//  Copyright (c) 2012 Justin Farlow. All rights reserved.
//

#import "AppDelegate.h"
#import "Manager.h"
#import "DocDelegate.h"
#import "Document.h"

///objects
#import "MainDocuments.h"
#import "ImportData.h"

@implementation AppDelegate

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize manager;

////Main Window Objects
@synthesize MainViewOutlet;
@synthesize DocumentsControllerOutlet;

///Import Window Objets
@synthesize ImportViewOutlet;
@synthesize ImportDataControllerOutlet;
@synthesize ImportRowControllerOutlet;
@synthesize ImportRawViewOutlet;
@synthesize TestLineNumberOutlet;
@synthesize TestMaxLineNumberOutlet;

@synthesize ClassificationMenuOutlet;

@synthesize recentTableOutlet;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    self.manager = [Manager new];
    
    
    [MainViewOutlet.window setStyleMask:NSBorderlessWindowMask];
    [MainViewOutlet.window makeKeyAndOrderFront:self];
        
    NSSortDescriptor* sortInputRowsIndex = [[NSSortDescriptor alloc] initWithKey: @"index" ascending: YES];
    NSSortDescriptor* sortInputRowsT = [[NSSortDescriptor alloc] initWithKey: @"t" ascending: YES];
    [ImportRowControllerOutlet setSortDescriptors:[NSArray arrayWithObjects:sortInputRowsIndex, sortInputRowsT, nil]];

    NSArray *recentDocs = [[NSDocumentController sharedDocumentController] recentDocumentURLs];
    
    [DocumentsControllerOutlet removeObjects:[DocumentsControllerOutlet arrangedObjects]];
    
    for (NSURL *eachURL in recentDocs) {
        MainDocuments *recentDoc = [DocumentsControllerOutlet newObject];
        recentDoc.name = [[eachURL lastPathComponent] stringByDeletingPathExtension];
        recentDoc.location = [eachURL absoluteString];
        [DocumentsControllerOutlet addObject:recentDoc];
    }
}

// Returns the directory the application uses to store the Core Data store file. This code uses a directory named "tracker" in the user's Application Support directory.
- (NSURL *)applicationFilesDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"gartner.tracker"];
}

// Creates if necessary and returns the managed object model for the application.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Tracker" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
    
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    } else {
        if (![properties[NSURLIsDirectoryKey] boolValue]) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"Tracker.storedata"];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _persistentStoreCoordinator = coordinator;
    
    return _persistentStoreCoordinator;
}

// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) 
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];

    return _managedObjectContext;
}

// Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
    return [[self managedObjectContext] undoManager];
}

// Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
- (IBAction)saveAction:(id)sender
{
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        NSLog(@"%@",@"saved!");
    }
}

- (IBAction)ImportWindow:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:YES];
    [panel setCanCreateDirectories:NO];
    [panel setAllowsMultipleSelection:NO];
    [panel setPrompt:@"Select Track Data"];
    if ([panel runModal]) {
        NSURL *fileURL = [panel URL];
        [ImportDataControllerOutlet removeObjects:[ImportDataControllerOutlet arrangedObjects]];
        ImportData *theData = [ImportDataControllerOutlet newObject];
        theData.filePath = [fileURL absoluteString];
        
        
        //call the import Window
        [MainViewOutlet.window addChildWindow:ImportViewOutlet.window ordered:NSWindowAbove];
        [ImportViewOutlet.window center];
        [ImportViewOutlet.window makeKeyAndOrderFront:self];
    
    
        NSString *fileContent = [[NSString alloc] initWithContentsOfURL:fileURL encoding:NSUTF8StringEncoding error:nil];
        theData.rawdata = fileContent;
    }

    //[manager TestParse];

}

- (IBAction)ParseImport:(id)sender {
    [manager TestParse];
}

- (IBAction)SetImportPreset:(id)sender {
    NSInteger myValue = [sender indexOfSelectedItem];
    ImportData *myImportData = [[ImportDataControllerOutlet selectedObjects] objectAtIndex:0];
    
    if (myValue == 2) {
        myImportData.indexID = [NSNumber numberWithInteger:6];
        myImportData.indexT = [NSNumber numberWithInteger:5];
        myImportData.indexX = [NSNumber numberWithInteger:0];
        myImportData.indexY = [NSNumber numberWithInteger:1];
        myImportData.indexI = [NSNumber numberWithInteger:2];
        myImportData.rowDelim = @"\r\n";
        myImportData.colDelim = @"\t";
        [self ImportIntoNewDoc:self];
    }else if (myValue ==3){
        myImportData.rowDelim = @"\r";
        myImportData.colDelim = @",";
        myImportData.indexID = [NSNumber numberWithInteger:0];
        myImportData.indexT = [NSNumber numberWithInteger:1];
        myImportData.indexX = [NSNumber numberWithInteger:2];
        myImportData.indexY = [NSNumber numberWithInteger:3];
        myImportData.indexI = [NSNumber numberWithInteger:4];
        [manager TestParse];
    }
    
}

- (IBAction)ImportIntoNewDoc:(id)sender {
    ////get appropriate data////
    ImportData *myData = [[ImportDataControllerOutlet arrangedObjects] objectAtIndex:0];
    NSURL *dataURL = [NSURL URLWithString:myData.filePath];
    
    //// create and open appropriate windows///
    NSDocumentController *myDocController = [NSDocumentController sharedDocumentController];
    NSArray *allDocuments = [myDocController documents];
    if ([allDocuments count] == 0  ) {
        [myDocController newDocument:self];
        allDocuments = [myDocController documents];
    }
    Document *myDocument = [allDocuments objectAtIndex:([[myDocController documents] count] - 1)];
    
    
    
    [myDocument ImportDataFromURL:dataURL withRow:myData.rowDelim withCol:myData.colDelim withIDat:myData.indexID withTat:myData.indexT withXat:myData.indexX withYat:myData.indexY withIat:myData.indexI];
    

    //cleanup & close appropriate windows///
    [ImportViewOutlet.window close];
    [MainViewOutlet.window close];
    
    
    
    
}


//////Document Menu Options
- (IBAction)Tab1Menu:(id)sender {
    NSDocumentController *myDocController = [NSDocumentController sharedDocumentController];
    DocDelegate *myDelegate = [[myDocController currentDocument] DocumentDelegate];
    [myDelegate.TabbedViewOutlet selectTabViewItemAtIndex:0];
    [myDelegate.TabViewButtonOutlet setSelectedSegment:0];
    
}

- (IBAction)Tab2Menu:(id)sender {
    NSDocumentController *myDocController = [NSDocumentController sharedDocumentController];
    DocDelegate *myDelegate = [[myDocController currentDocument] DocumentDelegate];
    [myDelegate.TabbedViewOutlet selectTabViewItemAtIndex:1];
    [myDelegate.TabViewButtonOutlet setSelectedSegment:1];
}

- (IBAction)Tab3Menu:(id)sender {
    NSDocumentController *myDocController = [NSDocumentController sharedDocumentController];
    DocDelegate *myDelegate = [[myDocController currentDocument] DocumentDelegate];
    [myDelegate.TabbedViewOutlet selectTabViewItemAtIndex:2];
    [myDelegate.TabViewButtonOutlet setSelectedSegment:2];
        [myDelegate UpdateTrackBezierCanvas];
}

- (IBAction)Tab4Menu:(id)sender {
    NSDocumentController *myDocController = [NSDocumentController sharedDocumentController];
    DocDelegate *myDelegate = [[myDocController currentDocument] DocumentDelegate];
    [myDelegate.TabbedViewOutlet selectTabViewItemAtIndex:3];
    [myDelegate.TabViewButtonOutlet setSelectedSegment:3];
}



- (IBAction)ChangeClassification:(id)sender{
    DocDelegate *myDelegate = [[[NSDocumentController sharedDocumentController] currentDocument] DocumentDelegate];
    NSArray *myTracks = [myDelegate.TrackControllerOutlet selectedObjects];
    for (Track *eachTrack in myTracks) {
        eachTrack.classification = @"Useful!";
    }
}


- (IBAction)ClassificationChanged:(id)sender{
    NSString *name = [sender title];
    DocDelegate *TheDocDelegate = [[[NSDocumentController sharedDocumentController] currentDocument] DocumentDelegate];
    NSArray *tracks = [TheDocDelegate.TrackControllerOutlet selectedObjects];
    
    for (Track *eachTrack in tracks) {
        eachTrack.classification = name;
    }
}



- (IBAction)openSelected:(id)sender {
    MainDocuments *myDocument =[[DocumentsControllerOutlet selectedObjects] objectAtIndex:0];
    NSURL *myDocumentLocation = [NSURL URLWithString:myDocument.location];
    
    NSError *error = nil;
    [[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:myDocumentLocation display:YES error:&error];
    [MainViewOutlet.window close];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    // Save changes in the application's managed object context before the application terminates.
    
    if (!_managedObjectContext) {
        return NSTerminateNow;
    }
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {

        // Customize this code block to include application-specific recovery steps.              
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }

        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }
    return NSTerminateNow;
}
- (void)OpenDocument{
    MainDocuments *selectedDoc = [[DocumentsControllerOutlet selectedObjects] objectAtIndex:0];
    NSURL *documentURL = [NSURL URLWithString:[selectedDoc location]];
    [[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:documentURL display:YES error:nil];
    [MainViewOutlet.window close];
}


- (IBAction)MainMenu:(id)sender {
    [MainViewOutlet.window makeKeyAndOrderFront:self];
}

- (NSString *)VersionNumber{
    
    NSString *version = [NSString stringWithFormat:@"%@ (Build %@)", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
    
    return version;
}
@end
