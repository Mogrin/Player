//
//  TCLMainViewController.h
//  TestCatalog
//
//  Created by Могрин on 10/19/14.
//  Copyright (c) 2014 Могрин. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCLSoundPlayer.h"

@interface TCLMainViewController : UITableViewController

@property (strong, nonatomic) NSMutableArray *directories;
@property (nonatomic, retain) NSArray *files;
//@property (nonatomic, retain) NSManagedObject *runDirectory;
//@property (nonatomic, retain) NSNumber *runDirectoryId;

@end
