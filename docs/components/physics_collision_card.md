# Physics Collision Card

An interactive 2D physics simulation container. Circular elements (representing profile pictures, badges, tech brand icons, or emojis) bounce off walls, experience gravitational pull, collide elastically with each other, and support dragging and throwing using standard gestures.

![Physics Collision Card Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/physics_collision_card.gif)

#### Key Features

- **Kinetic Vector Physics**: Simulates gravity forces, air resistance (damping), wall collisions, and circle-to-circle rigid body collisions.
- **Natural Drag & Throw**: Gesture detection automatically inherits velocity from native platform scroll-momentum solvers, allowing items to be realistically thrown around.
- **Rate-Throttled Collision Haptics**: Triggers crisp impact vibration feedback only for high-energy collisions, preventing continuous buzzing.
- **Smart Auto-Sleep Optimization**: Automatically disables active tickers when all elements have come to rest, restoring GPU/CPU efficiency to 0% overhead until the user wakes them by touching.
- **Highly Configurable**: Customize container dimensions, border decor, gravity vector, restitution (bounciness), damping, and collision haptic thresholds via `PhysicsCollisionCardStyle`.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

PhysicsCollisionCard(
  items: [
    PhysicsCollisionItem(
      radius: 36.0,
      child: Image.network('https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop'),
    ),
    PhysicsCollisionItem(
      radius: 28.0,
      child: Icon(Icons.bolt, color: Colors.white),
      initialVelocity: Offset(100.0, -150.0),
    ),
  ],
  style: PhysicsCollisionCardStyle(
    gravity: Offset(0.0, 900.0), // downwards gravity
    restitution: 0.75, // bounciness
    damping: 0.15, // air friction
    enableHaptics: true,
  ),
)
```
