module yaphonebot_servo

# DYNAMIXEL XL430-W250-T servo envelope and mounting geometry.
#
# Dimensions from the Robotis e-manual and cross-referenced against the
# GrabCAD community model and PhoneBot STEP assembly. All dimensions in mm.
#
# Coordinate convention: servo output shaft axis = +Z (shaft up),
# long body axis = X (46.5 mm), width = Y (28.5 mm), height = Z (34.0 mm).

command XL430_BODY() -> solid:
    body: solid = box(46.5, 28.5, 34.0)
    emit body

command XL430_SHAFT() -> solid:
    shaft: solid = cylinder(10.0, 4.0)
    emit translate(shaft, 11.25, 0.0, 17.0)

command XL430_ENVELOPE() -> solid:
    body: solid = XL430_BODY()
    shaft: solid = XL430_SHAFT()
    emit union(body, shaft)
