module yaphonebot_servo

# DYNAMIXEL XL430-W250-T servo envelope and mounting geometry.
#
# Dimensions from the Robotis e-manual and cross-referenced against the
# GrabCAD community model. All dimensions in mm.
#
# Coordinate convention: servo body axis = Z (output shaft up),
# +X through the cable exit, +Y through the horn mount face.

command XL430_BODY() -> solid:
    body: solid = box(28.0, 48.5, 33.5)
    emit body

command XL430_SHAFT() -> solid:
    shaft: solid = cylinder(2.55, 12.0)
    emit translate(shaft, 0.0, 0.0, 16.75)

command XL430_ENVELOPE() -> solid:
    body: solid = XL430_BODY()
    shaft: solid = XL430_SHAFT()
    emit union(body, shaft)