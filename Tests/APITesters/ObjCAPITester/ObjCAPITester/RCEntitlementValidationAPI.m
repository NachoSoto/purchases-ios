//
//  RCEntitlementValidationAPI.m
//  ObjCAPITester
//
//  Created by Nacho Soto on 2/10/23.
//

@import RevenueCat;

#import "RCEntitlementValidationAPI.h"

@implementation RCEntitlementValidationAPI

+ (void)checkAPI {
    const __unused RCEntitlementValidation validation = RCEntitlementValidationValidated;

    switch (validation) {
        case RCEntitlementValidationNotValidated:
        case RCEntitlementValidationValidated:
        case RCEntitlementValidationFailedValidation:
            break;
    }

    const __unused RCEntitlementValidationMode validationMode = RCEntitlementValidationModeDisabled;

    switch (validation) {
        case RCEntitlementValidationModeDisabled:
        case RCEntitlementValidationModeInformationOnly:
        case RCEntitlementValidationModeEnforced:
            break;
    }
}

@end
