#import <SpriteKit/SpriteKit.h>
@interface PileNode : SKShapeNode
- (instancetype)initWithSize:(CGSize)size label:(NSString *)label;
- (void)setHighlighted:(BOOL)highlighted;
@end
