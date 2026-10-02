#import "SettingsViewController.h"
#import "../Nodes/CardNode.h"
@interface SettingsViewController ()
@property(nonatomic, strong) NSArray<NSString *> *backs;
@end
@implementation SettingsViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Settings";
    self.backs = [CardNode availableBacks];
    self.tableView.backgroundColor = [UIColor blackColor];
    self.tableView.separatorColor = [UIColor colorWithWhite:0.18 alpha:1];
    self.tableView.rowHeight = 64;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                      target:self
                                                      action:@selector(done)];
}
- (void)done {
    [self dismissViewControllerAnimated:YES completion:self.onClose];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? self.backs.count : (section == 1 ? 1 : 3);
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @[ @"Card back", @"Game", @"Statistics" ][section];
}
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return section == 0 ? @"Add PNG or JPEG artwork to Resources/CardBacks before building. Any aspect ratio "
                          @"works; artwork fills the card."
                        : nil;
}
- (void)tableView:(UITableView *)tableView
    willDisplayHeaderView:(UIView *)view
               forSection:(NSInteger)section {
    if ([view isKindOfClass:[UITableViewHeaderFooterView class]])
        ((UITableViewHeaderFooterView *)view).textLabel.textColor = [UIColor lightGrayColor];
}
- (void)tableView:(UITableView *)tableView
    willDisplayFooterView:(UIView *)view
               forSection:(NSInteger)section {
    if ([view isKindOfClass:[UITableViewHeaderFooterView class]])
        ((UITableViewHeaderFooterView *)view).textLabel.textColor = [UIColor lightGrayColor];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                                   reuseIdentifier:nil];
    cell.backgroundColor = [UIColor colorWithWhite:0.06 alpha:1];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    cell.tintColor = [UIColor colorWithRed:0.55 green:0.75 blue:0.94 alpha:1];
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    if (indexPath.section == 0) {
        NSString *name = self.backs[indexPath.row];
        cell.textLabel.text = name.stringByDeletingPathExtension;
        NSString *path = [[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"CardBacks"]
            stringByAppendingPathComponent:name];
        cell.imageView.image = [UIImage imageWithContentsOfFile:path];
        cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
        cell.accessoryType = [name isEqualToString:[d stringForKey:@"cardBack"] ?: @"default.png"]
                                 ? UITableViewCellAccessoryCheckmark
                                 : UITableViewCellAccessoryNone;
    } else if (indexPath.section == 1) {
        cell.textLabel.text = @"Draw mode";
        cell.detailTextLabel.text = @"Draw 1";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        NSArray *keys = @[ @"gamesPlayed", @"wins", @"winStreak" ];
        cell.textLabel.text = @[ @"Games played", @"Wins", @"Current win streak" ][indexPath.row];
        cell.detailTextLabel.text =
            [NSString stringWithFormat:@"%ld", (long)[d integerForKey:keys[indexPath.row]]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        [[NSUserDefaults standardUserDefaults] setObject:self.backs[indexPath.row] forKey:@"cardBack"];
        [tableView reloadData];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
