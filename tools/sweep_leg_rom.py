#!/usr/bin/env python3
"""
PhoneBot leg ROM sweep: demonstrates yapcad.rom on a realistic kinematic chain.

Builds the single leg as SDF boxes representing the thigh link, shin link,
and foot plate, attaches them in a kinematic tree with revolute joints,
and sweeps the knee pitch DOF to find the minimum clearance between the
thigh and shin at each angle.
"""

import sys
import numpy as np
from pathlib import Path

# Ensure yapCAD is on the path
sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "src"))

from yapcad.sdf import box, translate, union
from yapcad.kinematics import Transform

from yapcad.rom import (
    RomTree,
    RomLink,
    sweep_kinematics,
    SweepConfig,
    dof_schedule_from_tree,
    interference_summary,
)


def build_leg_tree() -> RomTree:
    """Build a simplified phonebot leg kinematic tree with SDF geometry."""
    # --- Part geometry (SDF nodes) ---
    # Hip yaw joint envelope (servo body)
    hip_yaw = box((46.5, 28.5, 34.0))

    # Hip roll envelope (rotated 90° about X)
    hip_roll = box((34.0, 28.5, 46.5))

    # Hip pitch envelope (rotated 90° about Z then X)
    hip_pitch = box((34.0, 46.5, 28.5))

    # Thigh link (C-channel simplified as a wide U)
    thigh_link = box((54.2, 46.0, 80.0))

    # Knee pitch envelope (rotated 90°)
    knee_pitch = box((34.0, 28.5, 46.5))

    # Shin link (narrower C-channel)
    shin_link = box((31.0, 46.0, 92.0))

    # Ankle pitch envelope
    ankle_pitch = box((34.0, 46.5, 28.5))

    # Ankle roll envelope
    ankle_roll = box((34.0, 28.5, 46.5))

    # Foot plate
    foot_plate = box((110.0, 60.0, 35.0))

    # --- Build links ---
    links = [
        RomLink(
            name="HIP_YAW",
            parent=None,
            joint_kind="fixed",
            description="Hip yaw servo (fixed to pelvis)",
            sdf_node=hip_yaw,
        ),
        RomLink(
            name="HIP_ROLL",
            parent="HIP_YAW",
            parent_frame="ORIGIN",
            joint_kind="revolute",
            axis=(1, 0, 0),
            limits=[-45, 45],
            zero_pose=0.0,
            description="Hip roll joint",
            sdf_node=hip_roll,
        ),
        RomLink(
            name="HIP_PITCH",
            parent="HIP_ROLL",
            parent_frame="ORIGIN",
            joint_kind="revolute",
            axis=(0, 1, 0),
            limits=[-90, 90],
            zero_pose=0.0,
            description="Hip pitch joint",
            sdf_node=hip_pitch,
        ),
        RomLink(
            name="THIGH_LINK",
            parent="HIP_PITCH",
            parent_frame="ORIGIN",
            joint_kind="fixed",
            axis=(0, 1, 0),
            limits=[-180, 180],
            zero_pose=0.0,
            description="Thigh link",
            sdf_node=thigh_link,
        ),
        RomLink(
            name="KNEE_PITCH",
            parent="THIGH_LINK",
            parent_frame="ORIGIN",
            joint_kind="revolute",
            axis=(0, 1, 0),
            limits=[0, 135],
            zero_pose=0.0,
            description="Knee pitch joint",
            sdf_node=knee_pitch,
        ),
        RomLink(
            name="SHIN_LINK",
            parent="KNEE_PITCH",
            parent_frame="ORIGIN",
            joint_kind="fixed",
            axis=(0, 1, 0),
            limits=[-180, 180],
            zero_pose=0.0,
            description="Shin link",
            sdf_node=shin_link,
        ),
        RomLink(
            name="ANKLE_PITCH",
            parent="SHIN_LINK",
            parent_frame="ORIGIN",
            joint_kind="revolute",
            axis=(0, 1, 0),
            limits=[-45, 45],
            zero_pose=0.0,
            description="Ankle pitch joint",
            sdf_node=ankle_pitch,
        ),
        RomLink(
            name="ANKLE_ROLL",
            parent="ANKLE_PITCH",
            parent_frame="ORIGIN",
            joint_kind="revolute",
            axis=(1, 0, 0),
            limits=[-30, 30],
            zero_pose=0.0,
            description="Ankle roll joint",
            sdf_node=ankle_roll,
        ),
        RomLink(
            name="FOOT_PLATE",
            parent="ANKLE_ROLL",
            parent_frame="ORIGIN",
            joint_kind="fixed",
            description="Foot plate",
            sdf_node=foot_plate,
        ),
    ]

    tree = RomTree.from_links("PhoneBotLeg", links)
    return tree


def main():
    print("=" * 60)
    print("  PhoneBot Leg ROM Sweep")
    print("  Using yapcad.rom with SDF geometry (no meshing)")
    print("=" * 60)

    # Build the tree
    tree = build_leg_tree()
    print(f"\nTree: {tree.name}")
    print(f"  Links: {', '.join(tree.link_names())}")
    print(f"  Adjacent pairs: {len(tree.adjacent_pairs())}")
    for p, c in tree.adjacent_pairs():
        print(f"    {p} ↔ {c}")

    # Sweep the knee
    print("\n--- Sweep: KNEE_PITCH 0° → 135°, step 5° ---")

    cfg = SweepConfig(
        sdf_resolution=20,
        sdf_padding=1.0,
        step_deg=5.0,
        clearance_threshold=5.0,
        interference_threshold=0.0,
        early_stop=0,
        progress=5,
    )

    result = sweep_kinematics(
        tree,
        {"KNEE_PITCH": (0, 136, 5)},
        config=cfg,
    )

    print(f"\nConfigurations evaluated: {result.n_configurations}")
    print(f"Interference events:     {len(result.events)}")
    print(f"Near misses:             {len(result.near_misses)}")

    if result.events:
        print("\nWorst interferences:")
        for ev in sorted(result.events, key=lambda e: e.min_distance)[:5]:
            config_str = ", ".join(
                f"{k}={v:.1f}" for k, v in sorted(ev.config.items())
            )
            print(f"  {config_str} | {ev.pair[0]} ↔ {ev.pair[1]}: "
                  f"{ev.min_distance:.3f} mm")

    # Print the full report
    print()
    print(interference_summary(result))


if __name__ == "__main__":
    main()