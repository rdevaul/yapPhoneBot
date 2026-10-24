module yaphonebot_servo

# DYNAMIXEL XL430-W250-T servo envelope and mounting geometry.
#
# Dimensions from the Robotis e-manual and cross-referenced against the
# GrabCAD community model (grabcad.com/library/dynamixel-xl430-w250-t-1).
# All dimensions in mm.
#
# Coordinate convention: servo body axis = Z (output shaft up),
# +X through the cable exit, +Y through the horn mount face.

# ---------------------------------------------------------------------------
# Body envelope (simplified rectangular block with cable bump)
# ---------------------------------------------------------------------------

command XL430_BODY() -> solid:
    # Main body: 28.0 x 48.5 x 33.5 mm (W x D x H) per e-manual
    body: solid = box(28.0, 48.5, 33.5)
    emit body

command XL430_BODY_CABLE_BUMP() -> solid:
    # Cable exit protrusion on the +X face (approximate envelope)
    bump: solid = box(6.0, 12.0, 8.0)
    emit translate(bump, 17.0, 0.0, 0.0)

command XL430_FULL_BODY() -> solid:
    joined: solid = union(XL430_BODY(), XL430_BODY_CABLE_BUMP())
    emit joined

# ---------------------------------------------------------------------------
# Output shaft
# ---------------------------------------------------------------------------

command XL430_SHAFT() -> solid:
    # Output shaft: ~5.1 mm diameter, protrudes ~12 mm from top face
    shaft: solid = cylinder(2.55, 12.0)
    emit translate(shaft, 0.0, 0.0, 16.75)

# ---------------------------------------------------------------------------
# Complete servo envelope (for clearance / interference checks)
# ---------------------------------------------------------------------------

command XL430_ENVELOPE() -> solid:
    body: solid = XL430_FULL_BODY()
    shaft: solid = XL430_SHAFT()
    emit union(body, shaft)

# ---------------------------------------------------------------------------
# Servo mounted in a bracket: orientation helpers
# ---------------------------------------------------------------------------

command XL430_MOUNTED_Z_UP(x: float, y: float, z: float) -> solid:
    # Default orientation: shaft pointing +Z
    emit translate(XL430_ENVELOPE(), x, y, z)

command XL430_MOUNTED_Y_AXIS(x: float, y: float, z: float) -> solid:
    # Shaft pointing +Y (hip yaw / torso yaw joints)
    rotated: solid = rotate(XL430_ENVELOPE(), 90.0, 0.0, 0.0)
    emit translate(rotated, x, y, z)

command XL430_MOUNTED_X_AXIS(x: float, y: float, z: float) -> solid:
    # Shaft pointing +X (ankle roll, hip roll joints)
    rotated: solid = rotate(XL430_ENVELOPE(), 0.0, 90.0, 0.0)
    emit translate(rotated, x, y, z)
