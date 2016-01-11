//
//  M2RecordsTableViewController.m
//  m2048
//
//  Created by Yanping Lan on 1/9/16.
//  Copyright © 2016 Danqing. All rights reserved.
//

#import "M2RecordsTableViewController.h"
#import "Recode.h"
#import "M2AppDelegate.h"

#define kM2RecordCellIdentifier @"M2RecordCell"

@interface M2RecordsTableViewController ()

@property (nonatomic, strong) NSArray *fetchedRecords;

@end

@implementation M2RecordsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self fetchRecords];
    
    self.title = @"Game Records";
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kM2RecordCellIdentifier];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self  action:@selector(didTapDoneButton:)];
    self.navigationItem.rightBarButtonItem = doneButton;
}



- (void)fetchRecords {
    M2AppDelegate *appDelegate = (M2AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Recode" inManagedObjectContext:appDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"score" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
     NSError *error;
    self.fetchedRecords = [appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
}



#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.fetchedRecords.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kM2RecordCellIdentifier];
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Recode *record = [self.fetchedRecords objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"Score: %ld", record.score.integerValue];
    cell.imageView.image = [UIImage loadImage:record.imageUrl];
}


- (void)didTapDoneButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
