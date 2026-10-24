module yaphonebot_torso

# PhoneBot torso: pelvis (housing 3 vertical yaw servos J1, J7, J13),
# torso base, 3S shorty LiPo battery, electronics frame (Radxa ZERO 3W,
# U2D2, LM2596), and vertical smartphone clamp + phone envelope.
#
# Coordinate convention: +X forward, +Y left, +Z up.
# Origin (0, 0, 0) is at the torso yaw bearing interface (PelvisTop top face).

use yaphonebot_servo as servo

# === Pelvis (lower body housing J1, J7, J13 yaw servos) ====================
command PELVIS_TOP() -> solid:
    # Spans X=[-24, +39.3] (63.3), Y=[-67.9, +67.9] (135.7), Z=[-12.8, +4.6]
    main_plate: solid = translate(box(54.7, 135.7, 8.0), 12.0, 0.0, -6.8)
    bearing_boss: solid = translate(cylinder(24.0, 7.4), 0.0, 0.0, -2.8)
    emit union(main_plate, bearing_boss)

command PELVIS_BOTTOM() -> solid:
    # Spans X=[-15.4, +39.3] (54.7), Y=[-67.9, +67.9] (135.7), Z=[-40.2, -26.2] (14.0)
    outer: solid = translate(box(54.7, 135.7, 14.0), 12.0, 0.0, -33.2)
    cutout: solid = translate(box(46.0, 126.0, 10.0), 12.0, 0.0, -30.0)
    emit difference(outer, cutout)

command TORSO_YAW_JOINT(x: float, y: float, z: float) -> solid:
    # J13 torso yaw servo centered in pelvis (X=12.0, Y=0.0, Z=-17.0)
    emit translate(servo.XL430_ENVELOPE(), x + 12.0, y, z - 17.0)

# === Upper body / TorsoBase ================================================
command UPPER_BODY_PLATE() -> solid:
    # TorsoBase: X=[-20.5, +45.5] (66.0), Y=[-53.0, +53.0] (106.0), Z=[+2.1, +45.6]
    base_plate: solid = translate(box(66.0, 106.0, 21.0), 12.5, 0.0, 12.6)
    riser_wall: solid = translate(box(49.8, 59.0, 22.5), 4.4, 0.0, 34.35)
    riser_cut: solid = translate(box(42.0, 51.0, 20.0), 6.0, 0.0, 32.0)
    emit union(base_plate, difference(riser_wall, riser_cut))

command LOWER_BODY_PLATE() -> solid:
    emit union(PELVIS_TOP(), PELVIS_BOTTOM())

# === Battery & Electronics =================================================
command BATTERY_COMPARTMENT() -> solid:
    # Zeee 3S Shorty Battery: X=[-9.5, +23.5] (33.0), Y=[-37.5, +37.5] (75.0), Z=[+9.6, +34.6] (25.0)
    emit translate(box(33.0, 75.0, 25.0), 7.0, 0.0, 22.1)

command SBC_SHELF() -> solid:
    # ElectronicsFrame + standoffs + PCBs at Z=[+52.6, +89.5]
    frame: solid = translate(box(49.8, 91.0, 5.0), 4.4, -0.5, 75.8)
    standoffs: solid = translate(box(49.8, 45.0, 20.7), -0.5, -4.4, 63.0)
    u2d2_phb: solid = translate(box(48.0, 62.0, 18.9), 4.4, -4.9, 62.2)
    radxa_dcdc: solid = translate(box(43.2, 85.0, 10.0), 4.4, -5.0, 83.3)
    emit union(union(frame, standoffs), union(u2d2_phb, radxa_dcdc))

# === Vertical Phone Mount & Smartphone =====================================
command PHONE_CRADLE() -> solid:
    # PhoneMount: X=[+29.5, +48.6] (19.1), Y=[-53.0, +53.0] (106.0), Z=[+19.6, +132.1] (112.5)
    # Plus vertical Smartphone envelope: X=[+34.5, +43.5] (9.0), Y=[-37.4, +37.5] (74.9), Z=[+24.6, +187.2] (162.6)
    mount_base: solid = translate(box(16.0, 106.0, 11.0), 37.5, 0.0, 25.1)
    back_plate: solid = translate(box(5.0, 85.2, 112.5), 32.0, 0.0, 75.85)
    left_clamp: solid = translate(box(19.1, 8.0, 95.0), 39.0, 38.6, 75.0)
    right_clamp: solid = translate(box(19.1, 8.0, 95.0), 39.0, -38.6, 75.0)
    phone_body: solid = translate(box(9.0, 74.9, 162.6), 39.0, 0.0, 105.9)
    cradle: solid = union(union(mount_base, back_plate), union(left_clamp, right_clamp))
    emit union(cradle, phone_body)

# === Hip C-Bracket (connects hip yaw to hip roll/pitch) ====================
command LEG_TOWER(side: float) -> solid:
    # HipBracket: X=[-35.5, +47.6] (83.1), Y=side*[37.5, 91.5] (54.0), Z=[-78.2, +1.0] (79.2)
    top_plate: solid = translate(box(30.0, 54.0, 8.0), 6.0, side * 64.5, -3.0)
    outer_wall: solid = translate(box(48.0, 8.0, 46.0), 6.0, side * 87.5, -22.0)
    lower_yoke: solid = translate(box(83.1, 36.0, 37.2), 6.0, side * 55.5, -59.6)
    yoke_cut: solid = translate(box(57.0, 38.0, 32.0), 6.0, side * 55.5, -62.0)
    emit union(union(top_plate, outer_wall), difference(lower_yoke, yoke_cut))

# === Full torso assembly ===================================================
command TORSO() -> solid:
    yaw: solid     = TORSO_YAW_JOINT(0.0, 0.0, 0.0)
    upper: solid   = UPPER_BODY_PLATE()
    cradle: solid  = PHONE_CRADLE()
    sbc: solid     = SBC_SHELF()
    battery: solid = BATTERY_COMPARTMENT()
    lower: solid   = LOWER_BODY_PLATE()
    lt: solid      = LEG_TOWER(1.0)
    rt: solid      = LEG_TOWER(-1.0)
    emit compound(yaw, upper, cradle, sbc, battery, lower, lt, rt)

command TORSO_ASSEMBLY() -> assembly:
    a0: assembly = assembly("Torso")
    a1: assembly = add_part(a0, TORSO_YAW_JOINT(0.0, 0.0, 0.0), "yaw_servo")
    a2: assembly = add_part(a1, UPPER_BODY_PLATE(), "upper_plate")
    a3: assembly = add_part(a2, PHONE_CRADLE(), "phone_cradle")
    a4: assembly = add_part(a3, SBC_SHELF(), "sbc_shelf")
    a5: assembly = add_part(a4, BATTERY_COMPARTMENT(), "battery")
    a6: assembly = add_part(a5, LOWER_BODY_PLATE(), "lower_plate")
    a7: assembly = add_part(a6, LEG_TOWER(1.0), "left_tower")
    a8: assembly = add_part(a7, LEG_TOWER(-1.0), "right_tower")
    emit a8
