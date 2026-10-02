#import "../Game/SolitaireGame.h"
#import <SpriteKit/SpriteKit.h>
@interface GameScene : SKScene
@property(nonatomic, strong) SolitaireGame *game;
@property(nonatomic, copy) void (^gameChanged)(void);
- (void)refreshAnimated:(BOOL)animated;
- (void)cancelInteraction;
- (void)celebrate;
@end
