//
//  AppleEventsManager.m
//  Shifty
//
//  Created by Nate Thompson on 2/12/19.
//
// This code thanks to https://halmueller.wordpress.com/2018/09/04/privacy-consent-in-mojave-part-2-applescript/


#import <Cocoa/Cocoa.h>
#import "AppleEventsManager.h"


@implementation AppleEventsManager : NSObject

+ (PrivacyConsentState)automationConsentForBundleIdentifier:(NSString *)bundleIdentifier {
    
    PrivacyConsentState result;
    
    if (@available(macOS 10.14, *)) {
        AEAddressDesc addressDesc;
        // We need a C string here, not an NSString
        const char *bundleIdentifierCString = [bundleIdentifier cStringUsingEncoding:NSUTF8StringEncoding];
        AECreateDesc(typeApplicationBundleID, bundleIdentifierCString, strlen(bundleIdentifierCString), &addressDesc);
        
        // askUserIfNeeded must be YES in order to return errAEEventNotPermitted: http://www.openradar.me/radar?id=4945773766639616
        OSStatus appleScriptPermission = AEDeterminePermissionToAutomateTarget(&addressDesc, typeWildCard, typeWildCard, YES);
        AEDisposeDesc(&addressDesc);
        
        switch (appleScriptPermission) {
            case errAEEventWouldRequireUserConsent:
                NSLog(@"Automation consent not yet granted for %@, would require user consent.", bundleIdentifier);
                result = PrivacyConsentStateUndetermined;
                break;
            case noErr:
                result = PrivacyConsentStateGranted;
                break;
            case errAEEventNotPermitted:
                NSLog(@"Automation of %@ not permitted.", bundleIdentifier);
                result = PrivacyConsentStateDenied;
                break;
            case procNotFound:
                NSLog(@"%@ not running, automation consent unknown.", bundleIdentifier);
                result = PrivacyConsentStateUndetermined;
                break;
            default:
                NSLog(@"%s switch statement fell through: %@ %d", __PRETTY_FUNCTION__, bundleIdentifier, appleScriptPermission);
                result = PrivacyConsentStateUndetermined;
        }
        return result;
        
    } else {
        return PrivacyConsentStateGranted;
    }
}

@end
