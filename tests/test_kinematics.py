"""
Kinematics tests: forward kinematics chain validation.
"""

import numpy as np
import pytest

from yaphonebot.kinematics.humanoid_chain import (
    leg_forward_kinematics,
    both_legs_forward_kinematics,
)


def test_zero_pose_foot_height():
    """
    In zero pose (all joints = 0), the foot sole should be at
    approximately -(hip_z + thigh + shin + ankle_height) in Z.
    """
    q = np.zeros(6)
    T = leg_forward_kinematics(q)
    foot_z = T[2, 3]

    expected_z = -(18.0 + 96.0 + 96.0 + 41.0)  # -251 mm
    assert abs(foot_z - expected_z) < 5.0, (
        f"Zero-pose foot Z = {foot_z:.1f} mm, expected ≈ {expected_z:.1f} mm"
    )


def test_zero_pose_foot_centered():
    """
    In zero pose, the foot should be roughly centered under the hip joint.
    """
    q = np.zeros(6)
    T = leg_forward_kinematics(q, side=1)
    foot_x = T[0, 3]
    foot_y = T[1, 3]

    # X should be near 0 (foot under hip)
    assert abs(foot_x) < 10.0, f"Zero-pose foot X = {foot_x:.1f} mm"
    # Y should be at the hip offset (+50 for left leg)
    assert abs(foot_y - 50.0) < 10.0, f"Zero-pose foot Y = {foot_y:.1f} mm"


def test_left_right_symmetry():
    """
    Left and right legs in zero pose should be mirror images about Y=0.
    """
    q = np.zeros(6)
    T_l, T_r = both_legs_forward_kinematics(q, q)

    # Z should be the same
    assert abs(T_l[2, 3] - T_r[2, 3]) < 1.0

    # Y should be opposite sign
    assert abs(T_l[1, 3] + T_r[1, 3]) < 2.0


def test_knee_bend_lifts_foot():
    """
    Bending the knee should raise the foot (less negative Z).
    """
    q_zero = np.zeros(6)
    q_bent = np.zeros(6)
    q_bent[3] = np.pi / 4  # knee pitch = 45 degrees

    T_zero = leg_forward_kinematics(q_zero)
    T_bent = leg_forward_kinematics(q_bent)

    # Bent knee should bring foot higher (less negative Z)
    assert T_bent[2, 3] > T_zero[2, 3], (
        "Knee bend did not raise the foot"
    )


def test_homogeneous_transform_valid():
    """
    The returned transform should be a valid homogeneous matrix
    (bottom row = [0, 0, 0, 1]).
    """
    q = np.zeros(6)
    T = leg_forward_kinematics(q)
    assert np.allclose(T[3], [0, 0, 0, 1])
