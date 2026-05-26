# Loading Shapes

![Loading Shapes Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/loading_shapes.gif)

A premium loading indicator that morphs between organic and geometric shapes with subtle rotational transitions and high-fidelity path interpolation.

#### Key Features

- **Dynamic Path Morphing**: High-fidelity path interpolation engine using 120-point vertex arrays for perfectly fluid shape-shifting.
- **Organic & Geometric States**: Fully customizable shape sequences using `PortalShapeDefinition` to define sides, smoothness, and radius ratios.
- **Momentum Rotation Engine**: Frame-perfect `Ticker`-based rotation that adds a physical "kick" of speed during transitions, avoiding resets or jumps.
- **Total Design Freedom**: Fully customizable colors, sizes, transition speeds, and wait times via `LoadingShapesStyle`.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

LoadingShapes(
  isLoading: true,
  style: LoadingShapesStyle(
    size: 140.0,
    color: Color(0xFF1D1D1F),
    transitionDuration: Duration(milliseconds: 800),
    baseRotationSpeed: 0.007,
    boostRotationSpeed: 0.02,
    pauseDuration: Duration(milliseconds: 400),
    shapes: [
      PortalShapeDefinition(sides: 5, smoothness: 0.4),
      PortalShapeDefinition(sides: 8, innerRadiusRatio: 0.6),
    ],
  ),
)
```

#### Custom Shapes & Geometry

The `PortalShapeDefinition` allows you to programmatically define any geometric or organic state for the morphing sequence:

| Parameter            | Description                                                     | Visual Effect                                  |
| :------------------- | :-------------------------------------------------------------- | :--------------------------------------------- |
| `sides`            | The number of vertices or peaks.                                | 3 = Triangle, 4 = Square, 1 = Teardrop.        |
| `innerRadiusRatio` | Ratio between inner and outer points (0.0 to 1.0).              | 1.0 = Polygon, 0.5 = Sharp Star, 0.2 = Needle. |
| `smoothness`       | Blending between rigid geometry and organic blobs (0.0 to 1.0). | 0.0 = Sharp edges, 1.0 = Liquid/Organic flow.  |

**Pro Tip:** To create a perfect circle morph, use a high `sides` count (e.g., 60) with `smoothness: 1.0`.
