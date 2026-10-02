#import <UIKit/UIKit.h>
@interface GameControls : UIView
@property(nonatomic, strong, readonly) UIButton *undoButton;
@property(nonatomic, strong, readonly) UIButton *restartButton;
@property(nonatomic, strong, readonly) UIButton *settingsButton;
@property(nonatomic, strong, readonly) UILabel *status;
@end
