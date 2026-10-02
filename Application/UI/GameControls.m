#import "GameControls.h"
@implementation GameControls
- (UIButton *)button:(NSString *)title {
    UIButton *b = [UIButton buttonWithType:UIButtonTypeSystem];
    [b setTitle:title forState:UIControlStateNormal];
    [b setTitleColor:[UIColor colorWithWhite:0.85 alpha:1] forState:UIControlStateNormal];
    [b setTitleColor:[UIColor colorWithWhite:0.3 alpha:1] forState:UIControlStateDisabled];
    b.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    [self addSubview:b];
    return b;
}
- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor blackColor];
        _undoButton = [self button:@"Undo"];
        _restartButton = [self button:@"New game"];
        _settingsButton = [self button:@"Settings"];
        _status = [UILabel new];
        _status.textColor = [UIColor colorWithWhite:0.55 alpha:1];
        _status.font = [UIFont monospacedDigitSystemFontOfSize:14 weight:UIFontWeightRegular];
        [self addSubview:_status];
    }
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = self.bounds.size.width;
    self.status.frame = CGRectMake(24, 0, MAX(0, w - 320), 52);
    self.undoButton.frame = CGRectMake(w - 280, 0, 72, 52);
    self.restartButton.frame = CGRectMake(w - 208, 0, 110, 52);
    self.settingsButton.frame = CGRectMake(w - 98, 0, 86, 52);
}
@end
