#!/usr/bin/env python3
"""
Build the yapPhoneBot .ycpkg package from the DSL sources.

Uses yapCAD 1.2.0+ SDF geometry (no OCC required).

Usage:
    python tools/build_ycpkg.py [--version VERSION] [--force] [--output PATH]
                                [--resolution RESOLUTION]
"""

import argparse
import pathlib
import sys

REPO_ROOT = pathlib.Path(__file__).resolve().parent.parent


def build_ycpkg(
    version: str,
    output_dir: pathlib.Path,
    force: bool,
    resolution: int = 96,
):
    """Compile the DSL sources into a validated .ycpkg using SDF geometry."""
    print(f"yapPhoneBot package builder v{version}")
    print(f"  output:    {output_dir}")
    print(f"  force:     {force}")
    print(f"  res:       {resolution} cells/axis")
    print()

    designs = REPO_ROOT / "designs"
    if not designs.exists():
        print("ERROR: designs/ directory not found")
        sys.exit(1)

    dsl_files = sorted(designs.glob("*.dsl"))
    print(f"  Found {len(dsl_files)} DSL files:")
    for f in dsl_files:
        print(f"    {f.name}")
    print()

    try:
        from yapcad.dsl import compile_and_run, package_from_dsl
    except ImportError:
        print("ERROR: yapCAD not installed")
        print("  pip install -e '.[test]'")
        sys.exit(1)

    assembly = designs / "yaphonebot_assembly.dsl"
    if not assembly.exists():
        print(f"ERROR: assembly DSL not found: {assembly}")
        sys.exit(1)

    if output_dir.exists():
        if force:
            import shutil
            shutil.rmtree(output_dir)
        else:
            print("ERROR: output dir exists. Use --force to replace.")
            sys.exit(1)

    print("  Compiling yaphonebot_assembly.dsl (SDF mode)...")

    try:
        pkg_result = package_from_dsl(
            assembly.read_text(),
            "PHONEBOT_ZERO_POSE",
            {},
            output_dir,
            name="yapPhoneBot",
            version=version,
            representation="sdf",
            sdf_cell_mm=400.0 / resolution,  # ~400 mm robot height
            sdf_simplify=False,
            source_path=str(assembly),
            overwrite=force,
        )
        if not pkg_result.success:
            raise RuntimeError(pkg_result.error_message)
    except Exception as e:
        print(f"  ERROR during compilation: {e}")
        print()
        print("  Falling back to per-part SDF build...")
        # Build each part individually
        _build_parts_fallback(resolution)
        return

    print(f"\n  Package built successfully")
    print(f"  Written to: {output_dir}")


def _build_parts_fallback(resolution: int):
    """Build each top-level command individually as SDF solids."""
    from yapcad.dsl import compile_and_run
    from yapcad.io.stl import write_stl

    designs = REPO_ROOT / "designs"
    build_dir = REPO_ROOT / "build" / "stl"
    build_dir.mkdir(parents=True, exist_ok=True)

    dsl_map = {
        "yaphonebot_servo.dsl": [("XL430_ENVELOPE", "xl430_envelope.stl")],
        "yaphonebot_leg.dsl": [("LEFT_LEG", "left_leg.stl")],
        "yaphonebot_torso.dsl": [("TORSO", "torso.stl")],
        "yaphonebot_assembly.dsl": [("PHONEBOT_ZERO_POSE", "phonebot_full.stl")],
    }

    for dsl_name, commands in dsl_map.items():
        dsl_file = designs / dsl_name
        source = dsl_file.read_text()
        for cmd, stl_name in commands:
            print(f"  Compiling {cmd} from {dsl_name}...")
            try:
                result = compile_and_run(
                    source,
                    cmd,
                    {},
                    representation="sdf",
                    sdf_cell_mm=400.0 / resolution,
                    sdf_simplify=False,
                    source_path=str(dsl_file),
                )
                if result.success and result.geometry is not None:
                    out_path = build_dir / stl_name
                    write_stl(result.geometry, str(out_path))
                    print(f"    → {out_path}")
                else:
                    print(f"    ⚠ compilation returned no geometry: {result.error_message}")
            except Exception as e:
                print(f"    ✗ error: {e}")


def main():
    parser = argparse.ArgumentParser(description="Build yapPhoneBot .ycpkg")
    parser.add_argument("--version", default="0.1.0", help="Package version")
    parser.add_argument("--force", action="store_true", help="Replace existing build")
    parser.add_argument("--output", type=str, help="Output path (default: build/yaphonebot-VERSION.ycpkg)")
    parser.add_argument("--resolution", type=int, default=96, help="SDF mesh resolution (cells across longest axis)")
    args = parser.parse_args()

    if args.output:
        out = pathlib.Path(args.output)
    else:
        out = REPO_ROOT / "build" / f"yaphonebot-{args.version}.ycpkg"

    build_ycpkg(args.version, out, args.force, args.resolution)


if __name__ == "__main__":
    main()
