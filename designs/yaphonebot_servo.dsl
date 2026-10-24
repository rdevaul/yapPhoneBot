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
    let body: solid = box(28.0, 48.5, 33.5)
    emit body

command XL430_BODY_CABLE_BUMP() -> solid:
    # Cable exit protrusion on the +X face (approximate envelope)
    let bump: solid = box(6.0, 12.0, 8.0)
    emit translate(bump, 17.0, 0.0, 0.0)

command XL430_FULL_BODY() -> solid:
    let joined: solid = union(XL430_BODY(), XL430_BODY_CABLE_BUMP())
    emit joined

# ---------------------------------------------------------------------------
# Output shaft
# ---------------------------------------------------------------------------

command XL430_SHAFT() -> solid:
    # Output shaft: ~5.1 mm diameter, protrudes ~12 mm from top face
    let shaft: solid = cylinder(2.55, 12.0)
    emit translate(shaft, 0.0, 0.0, 16.75)

# ---------------------------------------------------------------------------
# Mounting holes (M2 x 0.4 tapped, 4 corners)
# ---------------------------------------------------------------------------

command XL430_MOUNT_HOLES() -> solid:
    # 4 x M2 mounting holes through the side faces
    # Pattern: two holes per side face, spaced ~21 mm apart (center-to-center)
    let hole: solid = cylinder(1.3, 30.0)  # Ø2.6 clearance for M2
    let h1: solid = rotate(hole, 0.0, 90.0, 0.0)
    let h2: solid = rotate(hole, 0.0, 90.0, 0.0)
    emit compound(
        translate(h1, 0.0, 16.0, 0.0),
        translate(h1, 0.0, -16.0, 0.0),
        translate(h2, 0.0, 16.0, 0.0),
        translate(h2, 0.0, -16.0, 0.0)
    )

# ---------------------------------------------------------------------------
# Horn mount reference (top face)
# ---------------------------------------------------------------------------

command XL430_HORN_REFERENCE() -> solid:
    # Reference cylinder showing the horn mounting surface
    let horn: solid = cylinder(13.0, 2.0)  # ~Ø26 mm horn base
    emit translate(horn, 0.0, 0.0, 16.75)

# ---------------------------------------------------------------------------
# Complete servo envelope (for clearance / interference checks)
# ---------------------------------------------------------------------------

command XL430_ENVELOPE() -> solid:
    let body: solid = XL430_FULL_BODY()
    let shaft: solid = XL430_SHAFT()
    emit union(body, shaft)

# ---------------------------------------------------------------------------
# Servo mounted in a bracket: orientation helpers
# ---------------------------------------------------------------------------

command XL430_MOUNTED_Z_UP(x: float, y: float, z: float) -> solid:
    # Default orientation: shaft pointing +Z
    emit translate(XL430_ENVELOPE(), x, y, z)

command XL430_MOUNTED_Y_AXIS(x: float, y: float, z: float) -> solid:
    # Shaft pointing +Y (hip yaw / torso yaw joints)
    let rotated: solid = rotate(XL430_ENVELOPE(), 90.0, 0.0, 0.0)
    emit translate(rotated, x, y, z)

command XL430_MOUNTED_X_AXIS(x: float, y: float, z: float) -> solid:
    # Shaft pointing +X (ankle roll, hip roll joints)
    let rotated: solid = rotate(XL430_ENVELOPE(), 0.0, 90.0, 0.0)
    emit translate(rotated, x, y, z)
