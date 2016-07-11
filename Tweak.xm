#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#include <objc/runtime.h>

%hook NSFileManager
- (BOOL)fileExistsAtPath:(NSString *)path
{
    // %log;
    if ([path isEqualToString:@"/Applications/Cydia.app"] ||
        [path isEqualToString:@"/Applications/blackra1n.app"] ||
        [path isEqualToString:@"/Applications/FakeCarrier.app"] ||
        [path isEqualToString:@"/Applications/Iny.app"] ||
        [path isEqualToString:@"/Applications/IntelliScreen.app"] ||
        [path isEqualToString:@"/Applications/MxTube.app"] ||
        [path isEqualToString:@"/Applications/RockApp.app"] ||
        [path isEqualToString:@"/Applications/SBSettings.app"] ||
        [path isEqualToString:@"/Applications/WinterBoard.app"] ||
        [path isEqualToString:@"/private/var/tmp/cydia.log"] ||
        [path isEqualToString:@"/usr/binsshd"] ||
        [path isEqualToString:@"/usr/sbinsshd"] ||
        [path isEqualToString:@"/usr/libexec/sftp-server"] ||
        [path isEqualToString:@"/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist"] ||
        [path isEqualToString:@"/Library/MobileSubstrateMobileSubstrate.dylib"] ||
        [path isEqualToString:@"/var/log/syslog"] ||
        [path isEqualToString:@"/bin/bash"] ||
        [path isEqualToString:@"/bin/sh"] ||
        [path isEqualToString:@"/etc/ssh/sshd_config"] ||
        [path isEqualToString:@"/usr/libexec/ssh-keysign"]) {
        return NO;
    }
    return %orig;
}
%end

%hook UIApplication 
- (BOOL)canOpenURL:(NSURL *)url {
    if ([[url absoluteString] isEqualToString:@"cydia://"]) {
        // NSLog(@"URL Scheme Patched");
        return NO;
    }
    return %orig;
}
%end


%hook CLLocation

static float x = -1;
static float y = -1;

- (CLLocationCoordinate2D) coordinate {
    CLLocationCoordinate2D position = %orig;
    if (x == -1 && y == -1) {
        x = position.latitude - 37.7883923;
        y = position.longitude - (-122.4076413);
    }
    [[NSUserDefaults standardUserDefaults] setValue:@(x) forKey:@"_fake_x"];
    [[NSUserDefaults standardUserDefaults] setValue:@(y) forKey:@"_fake_y"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    return CLLocationCoordinate2DMake(position.latitude-x, position.longitude-y);
}

+ (void) load {
    %orig;

    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"_fake_x"]) {
        x = [[[NSUserDefaults standardUserDefaults] valueForKey:@"_fake_x"] floatValue];
    };
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"_fake_y"]) {
        y = [[[NSUserDefaults standardUserDefaults] valueForKey:@"_fake_y"] floatValue];
    };
}
%end


%ctor {
    %init;
}