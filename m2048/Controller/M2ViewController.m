//
//  M2ViewController.m
//  m2048
//
//  Created by Danqing on 3/16/14.
//  Copyright (c) 2014 Danqing. All rights reserved.
//

#import "M2ViewController.h"
#import "M2SettingsViewController.h"
#import "M2AppDelegate.h"

#import "M2Scene.h"
#import "M2GameManager.h"
#import "M2ScoreView.h"
#import "M2Overlay.h"
#import "M2GridView.h"
#import "M2RecordsTableViewController.h"


@implementation M2ViewController {
  IBOutlet UIButton *_restartButton;
  IBOutlet UIButton *_settingsButton;
  IBOutlet UILabel *_targetScore;
  IBOutlet UILabel *_subtitle;
  IBOutlet M2ScoreView *_scoreView;
  IBOutlet M2ScoreView *_bestView;
  
  M2Scene *_scene;
  
  IBOutlet M2Overlay *_overlay;
  IBOutlet UIImageView *_overlayBackground;
  IBOutlet UIButton *_saveButton;
  IBOutlet UIButton *_recordsButton;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self updateState];
  [self setupScreen];
}


- (void)updateState {
  [_scoreView updateAppearance];
  [_bestView updateAppearance];
  
  _targetScore.textColor = [GSTATE buttonColor];
  
  long target = [GSTATE valueForLevel:GSTATE.winningLevel];
  
  if (target > 100000) {
    _targetScore.font = [UIFont fontWithName:[GSTATE boldFontName] size:34];
  } else if (target < 10000) {
    _targetScore.font = [UIFont fontWithName:[GSTATE boldFontName] size:42];
  } else {
    _targetScore.font = [UIFont fontWithName:[GSTATE boldFontName] size:40];
  }
  
  _targetScore.text = [NSString stringWithFormat:@"%ld", target];
  
  _subtitle.textColor = [GSTATE buttonColor];
  _subtitle.font = [UIFont fontWithName:[GSTATE regularFontName] size:14];
  _subtitle.text = [NSString stringWithFormat:@"Join the numbers to get to %ld!", target];
  
  _overlay.message.font = [UIFont fontWithName:[GSTATE boldFontName] size:36];
  _overlay.keepPlaying.titleLabel.font = [UIFont fontWithName:[GSTATE boldFontName] size:17];
  _overlay.restartGame.titleLabel.font = [UIFont fontWithName:[GSTATE boldFontName] size:17];
  
  _overlay.message.textColor = [GSTATE buttonColor];
  [_overlay.keepPlaying setTitleColor:[GSTATE buttonColor] forState:UIControlStateNormal];
  [_overlay.restartGame setTitleColor:[GSTATE buttonColor] forState:UIControlStateNormal];
}


- (void)setupScreen {
    _bestView.score.text = [NSString stringWithFormat:@"%ld", (long)[Settings integerForKey:@"Best Score"]];
    
    [_recordsButton M2ButtonStyle];
    [_settingsButton M2ButtonStyle];
    [_saveButton M2ButtonStyle];
    [_restartButton M2ButtonStyle];
    
    _overlay.hidden = YES;
    _overlayBackground.hidden = YES;
    
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    
    // Create and configure the scene.
    M2Scene * scene = [M2Scene sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
    [self updateScore:0];
    [scene startNewGame];
    
    _scene = scene;
    _scene.controller = self;
}


- (void)updateScore:(NSInteger)score {
  _scoreView.score.text = [NSString stringWithFormat:@"%ld", (long)score];
  if ([Settings integerForKey:@"Best Score"] < score) {
    [Settings setInteger:score forKey:@"Best Score"];
    _bestView.score.text = [NSString stringWithFormat:@"%ld", (long)score];
  }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  // Pause Sprite Kit. Otherwise the dismissal of the modal view would lag.
  ((SKView *)self.view).paused = YES;
}


- (IBAction)restart:(id)sender {
  [self hideOverlay];
  [self updateScore:0];
  [_scene startNewGame];
}


- (IBAction)keepPlaying:(id)sender {
  [self hideOverlay];
}


- (IBAction)done:(UIStoryboardSegue *)segue {
  ((SKView *)self.view).paused = NO;
  if (GSTATE.needRefresh) {
    [GSTATE loadGlobalState];
    [self updateState];
    [self updateScore:0];
    [_scene startNewGame];
  }
}


- (void)endGame:(BOOL)won {
  _overlay.hidden = NO;
  _overlay.alpha = 0;
  _overlayBackground.hidden = NO;
  _overlayBackground.alpha = 0;
  
  if (!won) {
    _overlay.keepPlaying.hidden = YES;
    _overlay.message.text = @"Game Over";
  } else {
    _overlay.keepPlaying.hidden = NO;
    _overlay.message.text = @"You Win!";
  }
  
  // Fake the overlay background as a mask on the board.
  _overlayBackground.image = [M2GridView gridImageWithOverlay];
  
  // Center the overlay in the board.
  CGFloat verticalOffset = [[UIScreen mainScreen] bounds].size.height - GSTATE.verticalOffset;
  NSInteger side = GSTATE.dimension * (GSTATE.tileSize + GSTATE.borderWidth) + GSTATE.borderWidth;
  _overlay.center = CGPointMake(GSTATE.horizontalOffset + side / 2, verticalOffset - side / 2);
  
  [UIView animateWithDuration:0.5 delay:1.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
    _overlay.alpha = 1;
    _overlayBackground.alpha = 1;
  } completion:^(BOOL finished) {
    // Freeze the current game.
    ((SKView *)self.view).paused = YES;
  }];
}


- (void)hideOverlay {
  ((SKView *)self.view).paused = NO;
  if (!_overlay.hidden) {
    [UIView animateWithDuration:0.5 animations: ^{
      _overlay.alpha = 0;
      _overlayBackground.alpha = 0;
    } completion:^(BOOL finished) {
      _overlay.hidden = YES;
      _overlayBackground.hidden = YES;
    }];
  }
}


- (IBAction)didTapSaveButton:(UIButton *)sender {
    // TODO: shall we supoort lower than IOS8?
    __weak __typeof(self)weakSelf = self;
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Save Game?"
                                message:@"Are you sure you want to save this screen as recode?"
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* saveAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        UIImage *snapShot = [UIImage takeSnapshot:weakSelf.view];
        NSString *path = [UIImage saveImage:snapShot];
        
        M2AppDelegate *appDelegate = (M2AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = appDelegate.managedObjectContext;
        NSManagedObject *recodeInfo = [NSEntityDescription
                                       insertNewObjectForEntityForName:@"Recode"
                                       inManagedObjectContext:context];
        [recodeInfo setValue:path forKey:@"imageUrl"];
        [recodeInfo setValue:@([_scoreView.score.text integerValue]) forKey:@"score"];
        [recodeInfo setValue:[NSDate date] forKey:@"recodeTime"];
      
        [appDelegate saveContext];
    }];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:nil];
    
    [alert addAction:saveAction];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}


- (IBAction)didTapRecordsButton:(UIButton *)sender {
    M2RecordsTableViewController *viewController = [[M2RecordsTableViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}


@end
