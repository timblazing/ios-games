#import <UIKit/UIKit.h>
@interface SettingsViewController : UITableViewController
@property(nonatomic, copy) void (^onClose)(void);
@end
