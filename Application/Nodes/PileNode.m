#import "PileNode.h"
@implementation PileNode
- (instancetype)initWithSize:(CGSize)size label:(NSString *)label {
    if ((self = [super init])) {
        CGPathRef path = CGPathCreateWithRoundedRect(
            CGRectMake(-size.width / 2 + 2, -size.height / 2 + 2, size.width - 4, size.height - 4), 7, 7,
            NULL);
        self.path = path;
        CGPathRelease(path);
        self.lineWidth = 1;
        self.fillColor = [SKColor blackColor];
        [self setHighlighted:NO];
        SKLabelNode *text = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Light"];
        text.text = label;
        text.fontSize = 24;
        text.fontColor = [SKColor colorWithWhite:0.3 alpha:1];
        text.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        [self addChild:text];
    }
    return self;
}
- (void)setHighlighted:(BOOL)highlighted {
    self.zPosition = highlighted ? 800 : 0;
    self.fillColor = [SKColor clearColor];
    for (SKNode *child in self.children)
        child.hidden = highlighted;
    self.strokeColor = highlighted ? [SKColor colorWithRed:0.45 green:0.68 blue:0.86 alpha:1]
                                   : [SKColor colorWithWhite:0.2 alpha:1];
    self.lineWidth = highlighted ? 2 : 1;
}
@end
