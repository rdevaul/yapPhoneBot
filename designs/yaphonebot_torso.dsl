module yaphonebot_torso

# PhoneBot torso: single yaw joint + smartphone / SBC mounting structure.
#
# The torso provides:
#   - 1 DoF yaw rotation (DYNAMIXEL XL430-W250-T)
#   - Phone clamp / cradle
#   - SBC mounting shelf (Raspberry Pi or equivalent)
#   - Battery compartment (3S LiPo)
#
# Coordinate convention: +X forward, +Y left, +Z up.
# Torso yaw joint center is the robot's geometric midline origin.

# ---------------------------------------------------------------------------
# Torso yaw joint
# ---------------------------------------------------------------------------

command TORSO_YAW_JOINT(x: float, y: float, z: float) -> solid:
    # Servo shaft vertical (+Z), connecting lower body to upper body
    let servo: solid = XL430_ENVELOPE()
    emit translate(servo, x, y, z)

# ---------------------------------------------------------------------------
# Upper body plate (above the yaw joint)
# ---------------------------------------------------------------------------

command UPPER_BODY_PLATE() -> solid:
    # Flat plate carrying the phone cradle and SBC shelf
    let plate: solid = box(80.0, 100.0, 8.0)
    emit translate(plate, 0.0, 0.0, 20.0)

# ---------------------------------------------------------------------------
# Phone cradle
# ---------------------------------------------------------------------------

command PHONE_CRADLE() -> solid:
    # Open-frame cradle for a smartphone (~75 x 155 x 9 mm envelope)
    # Simplified as a U-channel with retention bumps
    let base: solid = box(78.0, 158.0, 4.0)
    let left_wall: solid = box(4.0, 158.0, 20.0)
    let right_wall: solid = box(4.0, 158.0, 20.0)
    let bottom_wall: solid = box(78.0, 4.0, 20.0)
    emit compound(
        translate(base, 0.0, 0.0, 28.0),
        translate(left_wall, -39.0, 0.0, 28.0),
        translate(right_wall, 39.0, 0.0, 28.0),
        translate(bottom_wall, 0.0, 77.0, 28.0)
    )

# ---------------------------------------------------------------------------
# SBC shelf
# ---------------------------------------------------------------------------

command SBC_SHELF() -> solid:
    # Shelf for a Raspberry Pi 4 (85 x 56 mm footprint)
    let shelf: solid = box(90.0, 60.0, 4.0)
    let riser: solid = box(90.0, 60.0, 15.0)
    emit compound(
        translate(shelf, 0.0, -55.0, 30.0),
        translate(riser, 0.0, -55.0, 22.0)
    )

# ---------------------------------------------------------------------------
# Battery compartment (3S LiPo, ~120 x 45 x 25 mm)
# ---------------------------------------------------------------------------

command BATTERY_COMPARTMENT() -> solid:
    let comp: solid = box(50.0, 125.0, 30.0)
    let inner: solid = box(44.0, 119.0, 26.0)
    let shell: solid = difference(comp, translate(inner, 0.0, 0.0, 4.0))
    emit translate(shell, 0.0, 0.0, -20.0)

# ---------------------------------------------------------------------------
# Lower body plate (below the yaw joint, leg mount surface)
# ---------------------------------------------------------------------------

command LOWER_BODY_PLATE() -> solid:
    let plate: solid = box(80.0, 100.0, 8.0)
    emit translate(plate, 0.0, 0.0, -28.0)

# ---------------------------------------------------------------------------
# Leg mounting towers (left + right)
# ---------------------------------------------------------------------------

command LEG_TOWER(side: int) -> solid:
    # Vertical tower at the leg hip yaw mount point
    # side = +1 for left, -1 for right
    require side == -1 or side == 1, "side must be -1 or +1"
    let tower: solid = box(30.0, 20.0, 28.0)
    let bore: solid = cylinder(5.0, 30.0)  # M8 shaft bore
    let bored_tower: solid = difference(tower, translate(rotate(bore, 90.0, 0.0, 0.0), 0.0, 0.0, 0.0))
    emit translate(bored_tower, side * 40.0, 0.0, -14.0)

# ---------------------------------------------------------------------------
# Full torso assembly (zero pose)
# ---------------------------------------------------------------------------

command TORSO_ASSEMBLY() -> solid:
    let yaw: solid = TORSO_YAW_JOINT(0.0, 0.0, 0.0)
    let upper: solid = UPPER_BODY_PLATE()
    let cradle: solid = PHONE_CRADLE()
    let sbc: solid = SBC_SHELF()
    let battery: solid = BATTERY_COMPARTMENT()
    let lower: solid = LOWER_BODY_PLATE()
    let left_tower: solid = LEG_TOWER(1)
    let right_tower: solid = LEG_TOWER(-1)

    emit compound(
        yaw, upper, cradle, sbc, battery,
        lower, left_tower, right_tower
    )
