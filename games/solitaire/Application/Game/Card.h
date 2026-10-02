#import <Foundation/Foundation.h>
@interface Card : NSObject
@property(nonatomic, readonly) NSInteger identifier;
@property(nonatomic, readonly) NSInteger rank;
@property(nonatomic, readonly) NSInteger suit;
@property(nonatomic, readonly) BOOL red;
@property(nonatomic) BOOL faceUp;
- (instancetype)initWithIdentifier:(NSInteger)identifier;
- (NSString *)rankText;
- (NSString *)suitText;
@end
