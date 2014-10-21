//
//  TCLMainViewController.m
//  TestCatalog
//
//  Created by Могрин on 10/19/14.
//  Copyright (c) 2014 Могрин. All rights reserved.
//

#import "TCLMainViewController.h"
#import "TCLDirectory.h"

@interface TCLMainViewController ()

@end


@implementation TCLMainViewController

@synthesize directories;
@synthesize files;
//@synthesize runDirectory;
//@synthesize runDirectoryId;

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];    
    [self reloadTableView];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //self.runDirectoryId = 0;
    
    UIBarButtonItem *editButton = self.editButtonItem;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                  target:self
                                  action:@selector(insertNewObject:)];
    
    self.navigationItem.rightBarButtonItem = addButton;
    addButton.enabled = false;
    
    NSArray *rightButtons = [[NSArray alloc] initWithObjects: addButton, editButton, nil];
    self.navigationItem.rightBarButtonItems = rightButtons;
    
    //выбираем объекты для проигрования
    /*self.files = [NSArray arrayWithObjects:
                  @".mp3",
                  @".mp3",
                  @".mp3",
                  @".mp3", nil];
    
    for(int i=0; i < files.count; i++)
    {
        NSManagedObjectContext *context = [self managedObjectContext];
        NSManagedObject *newDir= [NSEntityDescription insertNewObjectForEntityForName:@"Directory"
                                                               inManagedObjectContext:context];
        NSString *file = [files objectAtIndex:i];
        [newDir setValue:file forKey:@"title"];
        [self.directories insertObject:newDir atIndex:0];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    [[TCLSoundPlayer sharedPlayer] cacheWithFiles:directories];*/
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)insertNewObject:(id)sender
{
    [self getDialog];
}

-(void)getDialog
{
    UIAlertView * alert = [[UIAlertView alloc]
                           initWithTitle:NSLocalizedString(@"Создать директорию", nil)
                           message:NSLocalizedString(@"", nil)
                           delegate:self
                           cancelButtonTitle:NSLocalizedString(@"Создать", nil)
                           otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *tmpTitle = [[alertView textFieldAtIndex:0] text]; 
    
    if( tmpTitle.length >= 1 ){
        NSManagedObjectContext *context = [self managedObjectContext];
        NSManagedObject *newDir= [NSEntityDescription insertNewObjectForEntityForName:@"Directory"
                                                                   inManagedObjectContext:context];
        [newDir setValue:tmpTitle forKey:@"title"];
        //[newDir setValue:[[NSNumber alloc] initWithInt:[NSDate timeIntervalSinceReferenceDate]] forKey:@"id"];
        //[newDir setValue:self.runDirectoryId forKey:@"parentId"];
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
        [self.directories insertObject:newDir atIndex:0];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}


- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}



#pragma mark - Table view data source

-(void)reloadTableView
{
    [self.directories removeAllObjects];    
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Directory"];
    self.directories = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];    
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.directories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];    
    NSManagedObject *directory = [self.directories objectAtIndex:indexPath.row];
    [cell.textLabel setText:[directory valueForKey:@"title"]];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [context deleteObject:[self.directories objectAtIndex:indexPath.row]];
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
            return;
        }
        
        [self.directories removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } 
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    for (NSString *file in files) {
        if ([[TCLSoundPlayer sharedPlayer] isPlaying:file]) {
            [[TCLSoundPlayer sharedPlayer] pausePlaing:file];
        }
    }
    
    NSString *fileName = [files objectAtIndex:indexPath.row];
    [[TCLSoundPlayer sharedPlayer] playFile:fileName volume:0.5f loops:0];
}

@end
