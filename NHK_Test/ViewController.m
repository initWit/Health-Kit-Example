//
//  ViewController.m
//  NHK_Test
//
//  Created by Robert Figueras on 2/19/15.
//

#import "ViewController.h"
#import <HealthKit/HealthKit.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *counterLabel;
@property (weak, nonatomic) IBOutlet UIButton *plusButton;
@property (weak, nonatomic) IBOutlet UIButton *minusButton;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (strong, nonatomic) HKHealthStore *healthStore;
@property (strong, nonatomic) NSString *hkIdentifier;
@property int count;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.counterLabel.text = @"0";
    self.count = 0;
    self.healthStore = [[HKHealthStore alloc] init];
//    self.hkIdentifier = HKQuantityTypeIdentifierNumberOfTimesFallen;
    self.hkIdentifier = HKQuantityTypeIdentifierFlightsClimbed;
    
    [self requestAuthorizationToAccessHealthStore];

}



- (IBAction)increaseCounter:(id)sender
{
    self.count ++;
    [self updateCounterLabel];
}



- (IBAction)decreaseCounter:(id)sender
{
    if (self.count != 0) {
        self.count --;
        [self updateCounterLabel];
    }
}



- (IBAction)resetCounter:(id)sender
{
    self.count = 0;
    [self updateCounterLabel];
}



-(void) updateCounterLabel
{
    self.counterLabel.text = [NSString stringWithFormat:@"%d", self.count];
}



- (IBAction)saveToHealthStore:(id)sender
{
        NSDate *now = [NSDate date];
        HKQuantityType *hkQuantityType = [HKQuantityType quantityTypeForIdentifier:self.hkIdentifier];
        HKQuantity *hkQuantity = [HKQuantity quantityWithUnit:[HKUnit unitFromString:@"count"] doubleValue:self.count];
        
        HKQuantitySample *countSample = [HKQuantitySample quantitySampleWithType:hkQuantityType
                                                                        quantity:hkQuantity
                                                                       startDate:now
                                                                         endDate:now];
        
        [self.healthStore saveObject:countSample withCompletion:^(BOOL success, NSError *error) {
            if (success) {
                NSLog(@"SAVED??");
            } else {
                NSLog(@"ERROR: %@", error.localizedDescription);
            }
        }];
}



- (BOOL) requestAuthorizationToAccessHealthStore
{
    
    __block BOOL isAuthorized = YES;
    
    if (NSClassFromString(@"HKHealthStore") && [HKHealthStore isHealthDataAvailable]) {
        
        NSSet *shareObjectTypes = [NSSet setWithObjects:[HKObjectType quantityTypeForIdentifier:self.hkIdentifier], nil];
        NSSet *readObjectTypes = [NSSet setWithObjects:[HKObjectType quantityTypeForIdentifier:self.hkIdentifier], nil];
        
        [self.healthStore requestAuthorizationToShareTypes:shareObjectTypes
                                            readTypes:readObjectTypes
                                           completion:^(BOOL success, NSError *error) {

                                               if (success == YES) {
                                                   isAuthorized = YES;
                                               } else {
                                                   isAuthorized = NO;
                                               }
                                           
                                           }];
        
    }
    
    return isAuthorized;

}



@end
