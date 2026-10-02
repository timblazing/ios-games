#import "GameViewController.h"
#import "Scenes/GameScene.h"
#import "UI/GameControls.h"
#import "UI/SettingsViewController.h"
#import <SpriteKit/SpriteKit.h>
@interface GameViewController ()
@property(nonatomic, strong) SKView *board;
@property(nonatomic, strong) GameScene *scene;
@property(nonatomic, strong) GameControls *controls;
@property(nonatomic, strong) UILabel *victory;
@property(nonatomic, strong) NSTimer *timer;
@property(nonatomic) BOOL showingVictory;
@end
@implementation GameViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [[NSUserDefaults standardUserDefaults]
        registerDefaults:@{@"cardBack" : @"default.png", @"drawMode" : @1, @"soundEnabled" : @NO}];
    self.board = [[SKView alloc] initWithFrame:self.view.bounds];
    self.board.backgroundColor = [UIColor blackColor];
    self.board.ignoresSiblingOrder = YES;
    self.board.preferredFramesPerSecond = 60;
    self.board.multipleTouchEnabled = NO;
    [self.view addSubview:self.board];
    self.scene = [[GameScene alloc] initWithSize:self.board.bounds.size];
    self.scene.game = [SolitaireGame new];
    __weak typeof(self) weakSelf = self;
    self.scene.gameChanged = ^{
        [weakSelf updateStatus];
    };
    [self.board presentScene:self.scene];
    self.controls = [[GameControls alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.controls];
    [self.controls.undoButton addTarget:self
                                 action:@selector(undo)
                       forControlEvents:UIControlEventTouchUpInside];
    [self.controls.restartButton addTarget:self
                                    action:@selector(confirmNewGame)
                          forControlEvents:UIControlEventTouchUpInside];
    [self.controls.settingsButton addTarget:self
                                     action:@selector(settings)
                           forControlEvents:UIControlEventTouchUpInside];
    self.victory = [UILabel new];
    self.victory.textColor = [UIColor whiteColor];
    self.victory.textAlignment = NSTextAlignmentCenter;
    self.victory.font = [UIFont systemFontOfSize:26 weight:UIFontWeightLight];
    self.victory.numberOfLines = 0;
    self.victory.hidden = YES;
    [self.view addSubview:self.victory];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(background)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(foreground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    [self startTimer];
    [self.scene refreshAnimated:YES];
    [self updateStatus];
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGSize size = self.view.bounds.size;
    self.controls.frame = CGRectMake(0, 0, size.width, 52);
    self.board.frame = CGRectMake(0, 52, size.width, size.height - 52);
    self.scene.size = self.board.bounds.size;
    self.victory.frame = CGRectMake(24, size.height * 0.48, size.width - 48, 150);
}
- (BOOL)prefersStatusBarHidden {
    return YES;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}
- (void)startTimer {
    [self.timer invalidate];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1
                                                  target:self
                                                selector:@selector(updateStatus)
                                                userInfo:nil
                                                 repeats:YES];
}
- (void)background {
    [self.scene cancelInteraction];
    [self.scene refreshAnimated:NO];
    [self.scene.game pauseTimer];
    self.board.paused = YES;
    [self.timer invalidate];
    self.timer = nil;
}
- (void)foreground {
    [self.scene.game resumeTimer];
    self.board.paused = NO;
    [self startTimer];
    [self updateStatus];
}
- (void)updateStatus {
    NSInteger seconds = (NSInteger)self.scene.game.elapsed;
    NSString *time = [NSString stringWithFormat:@"%ld:%02ld", (long)(seconds / 60), (long)(seconds % 60)];
    self.controls.status.text =
        [NSString stringWithFormat:@"%@   •   %ld moves", time, (long)self.scene.game.moves];
    self.controls.undoButton.enabled = self.scene.game.canUndo;
    if (self.scene.game.won) {
        self.victory.hidden = NO;
        self.victory.text =
            [NSString stringWithFormat:@"Nicely played.\n%@   ·   %ld moves\nTap New game to play again",
                                       time, (long)self.scene.game.moves];
        if (!self.showingVictory)
            [self.scene celebrate];
        self.showingVictory = YES;
    } else {
        self.victory.hidden = YES;
        self.showingVictory = NO;
    }
}
- (void)undo {
    [self.scene cancelInteraction];
    [self.scene.game undo];
    [self.scene refreshAnimated:YES];
    [self updateStatus];
}
- (void)confirmNewGame {
    [self.scene cancelInteraction];
    [self.scene refreshAnimated:NO];
    if (self.scene.game.won) {
        [self newGame];
        return;
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Start a new game?"
                                                                   message:@"This replaces your current game."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Keep playing"
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"New game"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *action) {
                                                [self newGame];
                                            }]];
    [self presentViewController:alert animated:YES completion:nil];
}
- (void)newGame {
    [self.scene cancelInteraction];
    [self.scene.game newGame];
    [self.scene refreshAnimated:YES];
    [self updateStatus];
}
- (void)settings {
    [self.scene cancelInteraction];
    [self.scene refreshAnimated:NO];
    SettingsViewController *settings = [[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    __weak typeof(self) weakSelf = self;
    settings.onClose = ^{
        [weakSelf.scene refreshAnimated:NO];
    };
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:settings];
    nav.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:nav animated:YES completion:nil];
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.timer invalidate];
}
@end
