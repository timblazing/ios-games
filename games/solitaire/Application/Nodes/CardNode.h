#import "../Game/Card.h"
#import <SpriteKit/SpriteKit.h>
@interface CardNode : SKSpriteNode
@property(nonatomic, strong) Card *card;
@property(nonatomic) NSInteger pile;
@property(nonatomic) NSInteger index;
- (instancetype)initWithCard:(Card *)card size:(CGSize)size;
- (void)refreshWithSize:(CGSize)size animated:(BOOL)animated;
// Renders and caches every texture for the given card sizes off the main thread. Also logs any
// Resources/Cards art that is missing, once.
+ (void)preloadForSizes:(NSArray<NSValue *> *)sizes;
@end
