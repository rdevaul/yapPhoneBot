module yaphonebot_torso

# PhoneBot torso: single yaw joint + phone mount + SBC shelf + battery.
# +X forward, +Y left, +Z up.

use yaphonebot_servo as servo

# === Torso yaw joint ====================================================
command TORSO_YAW_JOINT(x: float, y: float, z: float) -> solid:
    emit translate(servo.XL430_ENVELOPE(), x, y, z)

# === Upper body plate ===================================================
command UPPER_BODY_PLATE() -> solid:
    emit translate(box(80.0, 100.0, 8.0), 0.0, 0.0, 20.0)

# === Phone cradle =======================================================
command PHONE_CRADLE() -> solid:
    base: solid = box(78.0, 158.0, 4.0)
    lw: solid   = box(4.0, 158.0, 20.0)
    rw: solid   = box(4.0, 158.0, 20.0)
    bw: solid   = box(78.0, 4.0, 20.0)
    emit compound(
        translate(base, 0.0, 0.0, 28.0),
        translate(lw, -39.0, 0.0, 28.0),
        translate(rw, 39.0, 0.0, 28.0),
        translate(bw, 0.0, 77.0, 28.0)
    )

# === SBC shelf ==========================================================
command SBC_SHELF() -> solid:
    shelf: solid = box(90.0, 60.0, 4.0)
    riser: solid = box(90.0, 60.0, 15.0)
    emit compound(
        translate(shelf, 0.0, -55.0, 30.0),
        translate(riser, 0.0, -55.0, 22.0)
    )

# === Battery compartment ================================================
command BATTERY_COMPARTMENT() -> solid:
    comp: solid  = box(50.0, 125.0, 30.0)
    inner: solid = box(44.0, 119.0, 26.0)
    hull: solid  = difference(comp, translate(inner, 0.0, 0.0, 4.0))
    emit translate(hull, 0.0, 0.0, -20.0)

# === Lower body plate ===================================================
command LOWER_BODY_PLATE() -> solid:
    emit translate(box(80.0, 100.0, 8.0), 0.0, 0.0, -28.0)

# === Leg mounting towers ================================================
command LEG_TOWER(side: int) -> solid:
    require side == -1 or side == 1, "side must be -1 or +1"
    tower: solid = box(30.0, 20.0, 28.0)
    bore: solid = cylinder(5.0, 30.0)
    bore_rotated: solid = rotate(bore, 90.0, 0.0, 0.0)
    bored_tower: solid = difference(tower, translate(bore_rotated, 0.0, 0.0, 0.0))
    emit translate(bored_tower, side * 40.0, 0.0, -14.0)

# === Full torso assembly ================================================
command TORSO() -> solid:
    emit compound(
        TORSO_YAW_JOINT(0.0, 0.0, 0.0),
        UPPER_BODY_PLATE(), PHONE_CRADLE(), SBC_SHELF(),
        BATTERY_COMPARTMENT(), LOWER_BODY_PLATE(),
        LEG_TOWER(1), LEG_TOWER(-1)
    )