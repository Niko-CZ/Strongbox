//
//  PrivacyViewController.m
//  Strongbox-iOS
//
//  Created by Mark on 14/05/2019.
//  Copyright © 2014-2021 Mark McGuill. All rights reserved.
//

#import "PrivacyViewController.h"
#import "PinEntryController.h"
#import "Settings.h"
#import "Alerts.h"
#import "SafesList.h"
#import "AutoFillManager.h"
#import "FileManager.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "BiometricsManager.h"

@interface PrivacyViewController ()

@property (weak, nonatomic) IBOutlet UIButton *buttonUnlock;
@property NSDate* startTime;
@property (weak, nonatomic) IBOutlet UILabel *labelUnlockAttemptsRemaining;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewLogo;

@end

@implementation PrivacyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupImageView];
    
    self.startTime = [[NSDate alloc] init];
    
    if(!self.startupLockMode) {
        self.buttonUnlock.hidden = YES; 
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.buttonUnlock.hidden = NO; 
        });
    }
    else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self beginUnlockSequence]; 
        });
    }
    
    [self updateFailedUnlockAttemptsUI];
}

- (void)setupImageView {
    self.imageViewLogo.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onUnlock:)];
    tapGesture1.numberOfTapsRequired = 1;
    [self.imageViewLogo addGestureRecognizer:tapGesture1];
}

- (void)onAppBecameActive {
    if(self.startupLockMode) {
        NSLog(@"Ignore App Active events for startup lock screen...");
        return; 
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.buttonUnlock.hidden = NO; 
    });

    [self beginUnlockSequence];
}

- (IBAction)onUnlock:(id)sender { 
    [self beginUnlockSequence];
}

- (void)beginUnlockSequence {
    NSLog(@"beginUnlockSequence....");
    
    if (Settings.sharedInstance.appLockMode == kNoLock || ![self shouldLock]) {
        Settings.sharedInstance.failedUnlockAttempts = 0;
        self.onUnlockDone(NO);
        return;
    }

    if(Settings.sharedInstance.appLockMode == kBiometric || Settings.sharedInstance.appLockMode == kBoth) {
        if(BiometricsManager.isBiometricIdAvailable) {
            [self requestBiometric];
        }
        else {
            [Alerts info:self
                   title:NSLocalizedString(@"privacy_vc_prompt_biometrics_unavailable_title", @"Biometrics Unavailable")
                 message:NSLocalizedString(@"privacy_vc_prompt_biometrics_unavailable_message", @"This application requires a biometric unlock but biometrics is unavailable on this device. You must re-enable biometrics to continue unlocking this application.")];
        }
    }
    else if (Settings.sharedInstance.appLockMode == kPinCode || Settings.sharedInstance.appLockMode == kBoth) {
        [self requestPin:NO];
    }
    else {
        Settings.sharedInstance.failedUnlockAttempts = 0;
        self.onUnlockDone(NO);
    }
}

- (void)requestBiometric {
    
    [BiometricsManager.sharedInstance requestBiometricId:NSLocalizedString(@"privacy_vc_prompt_identify_to_open", @"Identify to Open Strongbox")
                                           fallbackTitle:Settings.sharedInstance.appLockAllowDevicePasscodeFallbackForBio ? nil : @""
                                              completion:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (Settings.sharedInstance.appLockMode == kPinCode || Settings.sharedInstance.appLockMode == kBoth) {
                    [self requestPin:YES];
                }
                else {
                    Settings.sharedInstance.failedUnlockAttempts = 0;
                    self.onUnlockDone(YES);
                }
            });
        }
        else {
            if (error.code == LAErrorUserCancel) {
                NSLog(@"User Cancelled - Not Incrementing Fail Count...");
            }
            else  if ( error.code == LAErrorUserFallback ) {
                NSLog(@"LAErrorUserFallback");
            }
            else {
                [self incrementFailedUnlockCount];
            }
        }}];
}

- (void)updateFailedUnlockAttemptsUI {
    NSUInteger failed = Settings.sharedInstance.failedUnlockAttempts;
    
    if (failed > 0 ) {
        if(Settings.sharedInstance.deleteDataAfterFailedUnlockCount > 0) {
            NSInteger remaining = Settings.sharedInstance.deleteDataAfterFailedUnlockCount - failed;
            
            if(remaining > 0) {
                self.labelUnlockAttemptsRemaining.text = [NSString stringWithFormat:NSLocalizedString(@"privacy_vc_label_unlock_attempts_fmt", @"Unlock Attempts Remaining: %ld"), (long)remaining];
            }
            else {
                self.labelUnlockAttemptsRemaining.text = NSLocalizedString(@"privacy_vc_label_unlock_attempts_exceeded", @"Unlock Attempts Exceeded");
            }
            
            self.labelUnlockAttemptsRemaining.hidden = NO;
            self.labelUnlockAttemptsRemaining.textColor = UIColor.systemRedColor;
        }
        else {
            self.labelUnlockAttemptsRemaining.text = [NSString stringWithFormat:NSLocalizedString(@"privacy_vc_label_number_of_failed_unlock_attempts_fmt", @"%@ Failed Unlock Attempts"), @(failed)];
            self.labelUnlockAttemptsRemaining.hidden = NO;
            self.labelUnlockAttemptsRemaining.textColor = UIColor.systemOrangeColor;
        }
    }
    else {
        self.labelUnlockAttemptsRemaining.hidden = YES;
    }
}

- (void)requestPin:(BOOL)afterSuccessfulBiometricAuthentication {
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"PinEntry" bundle:nil];
    PinEntryController* pinEntryVc = (PinEntryController*)[storyboard instantiateInitialViewController];
    
    pinEntryVc.pinLength = Settings.sharedInstance.appLockPin.length;
    pinEntryVc.isDatabasePIN = NO;
    
    if(Settings.sharedInstance.deleteDataAfterFailedUnlockCount > 0 && Settings.sharedInstance.failedUnlockAttempts > 0) {
        NSInteger remaining = Settings.sharedInstance.deleteDataAfterFailedUnlockCount - Settings.sharedInstance.failedUnlockAttempts;
        
        if(remaining > 0) {
            pinEntryVc.warning = [NSString stringWithFormat:NSLocalizedString(@"privacy_vc_prompt_pin_attempts_remaining_fmt", @"%ld Attempts Remaining"), (long)remaining];
        }
    }
    
    pinEntryVc.onDone = ^(PinEntryResponse response, NSString * _Nullable pin) {
        if(response == kOk) {
            if([pin isEqualToString:Settings.sharedInstance.appLockPin]) {
                Settings.sharedInstance.failedUnlockAttempts = 0;
                self.onUnlockDone(afterSuccessfulBiometricAuthentication);
                
                UINotificationFeedbackGenerator* gen = [[UINotificationFeedbackGenerator alloc] init];
                [gen notificationOccurred:UINotificationFeedbackTypeSuccess];
            }
            else {
                [self incrementFailedUnlockCount];

                UINotificationFeedbackGenerator* gen = [[UINotificationFeedbackGenerator alloc] init];
                [gen notificationOccurred:UINotificationFeedbackTypeError];

                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }
        else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    };

    [self presentViewController:pinEntryVc animated:YES completion:nil];
}

- (BOOL)shouldLock {
    NSTimeInterval secondsBetween = [[NSDate date] timeIntervalSinceDate:self.startTime];
    NSInteger seconds = Settings.sharedInstance.appLockDelay;
    
    if (self.startupLockMode || seconds == 0 || secondsBetween > seconds)
    {
        NSLog(@"Locking App. %ld - %f", (long)seconds, secondsBetween);
        return YES;
    }

    NSLog(@"App Lock Not Required %f", secondsBetween);
    return NO;
}

- (void)incrementFailedUnlockCount {
    dispatch_async(dispatch_get_main_queue(), ^{
        Settings.sharedInstance.failedUnlockAttempts = Settings.sharedInstance.failedUnlockAttempts + 1;
        NSLog(@"Failed Unlocks: %lu", (unsigned long)Settings.sharedInstance.failedUnlockAttempts);
        [self updateFailedUnlockAttemptsUI];

        if(Settings.sharedInstance.deleteDataAfterFailedUnlockCount > 0) {
            if(Settings.sharedInstance.failedUnlockAttempts >= Settings.sharedInstance.deleteDataAfterFailedUnlockCount) {
                [self deleteAllData];
            }
        }
    });
}

- (void)deleteAllData {
    [AutoFillManager.sharedInstance clearAutoFillQuickTypeDatabase];
    
    [FileManager.sharedInstance deleteAllLocalAndAppGroupFiles]; 

    [SafesList.sharedInstance deleteAll]; 
}

@end
