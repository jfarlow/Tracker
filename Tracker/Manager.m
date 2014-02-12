//
//  Manager.m
//  Tracker2
//
//  Created by Justin Farlow on 9/19/13.
//  Copyright (c) 2013 Gartner Lab. All rights reserved.
//

#import "Manager.h"
#import "AppDelegate.h"
#import "DocDelegate.h"
#import "Document.h"
#import "ImportData.h"
#import "ImportRow.h"

@implementation Manager

-(void)TestParse{
    AppDelegate *appDelegate = [[NSApplication sharedApplication] delegate];
    [appDelegate.ImportRowControllerOutlet removeObjects:appDelegate.ImportRowControllerOutlet.arrangedObjects];
    ImportData *myData = [[appDelegate.ImportDataControllerOutlet arrangedObjects] objectAtIndex:0];
    NSString *fileContent = [[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:myData.filePath] encoding:NSUTF8StringEncoding error:nil];

    NSString *rowDelim = myData.rowDelim;
    NSString *colDelim = myData.colDelim;
    
   // if ([rowDelim isEqualToString:@"<return>"]) {rowDelim = @"\r";}
   // if ([colDelim isEqualToString:@"<tab>"]) {colDelim = @"\t";}
    myData.colDelim = colDelim;
    myData.rowDelim = rowDelim;
    
    NSArray *allLines = [fileContent componentsSeparatedByString:myData.rowDelim];
    
    [appDelegate.TestLineNumberOutlet setIntegerValue:allLines.count];
    
    if (allLines.count > 1) {
        
        
        for (NSInteger i=0; i < appDelegate.TestMaxLineNumberOutlet.integerValue; i++) {
            NSString *eachLine = [allLines objectAtIndex:i];
            ImportRow *thisNewRow = [appDelegate.ImportRowControllerOutlet newObject];
            NSArray *allColumns = [eachLine componentsSeparatedByString:myData.colDelim];
            
            if (allColumns.count > 1) {
                thisNewRow.index = [NSNumber numberWithFloat:[[allColumns objectAtIndex:[myData.indexID integerValue]] floatValue]];
                thisNewRow.t = [NSNumber numberWithFloat:[[allColumns objectAtIndex:[myData.indexT integerValue]] floatValue]];
                thisNewRow.x = [NSNumber numberWithFloat:[[allColumns objectAtIndex:[myData.indexX integerValue]] floatValue]];
                thisNewRow.y = [NSNumber numberWithFloat:[[allColumns objectAtIndex:[myData.indexY integerValue]] floatValue]];
                thisNewRow.i = [NSNumber numberWithFloat:[[allColumns objectAtIndex:[myData.indexI integerValue]] floatValue]];
                [myData addRowsObject:thisNewRow];
            }
        }
    }
}

-(void)ParseImport{
    
    
}




@end

@implementation SortPopUp
@synthesize sortKey;
-(void)setSortKey:(NSString *)input{
    sortKey = input;
}
@end

