# HandGesture

## Overview

HandGesture is a Swift Package for visionOS giving an API for capturing hand movements in a semantic way without having to code and manage the details of HandAnchors from ARKit. This package uses [ARUnderstanding](https://github.com/johnhaney/ARUnderstanding) for Hand Tracking.

If you are working at the level of HandAnchors or writing your own HandGesture, this package also extends HandAnchor to add some nice helper calculations and position points (ex. insidePalm and distanceBetween(joint1, joint2)).

Provided HandGestures are:
* ClapGesture (two hands together)
* FingerGunGesture (index finger pointer, thumb up/down)
* HoldingSphereGesture (gives a Sphere which could fit within one curved hand) 
* PunchGesture (Fist transform and velocity)
* SnapGesture (Pre-snap and post-snap indication)

This is very much a work in progress and your feedback is key. The best way to reach me at the moment is [on Bluesky](https://bsky.app/profile/johnhaney.bsky.social)

## Examples
```
.handGesture(
    PunchGesture(hand: .right)
        .onChanged { value in
            punch.transform = value.fist.transform
        }
)
```

```
.handGesture(
    HoldingSphereGesture(hand: .left)
        .onChanged { value in
            sphere.transform = Transform(matrix: value.sphere.originFromAnchorTransform)
        }
)
```

