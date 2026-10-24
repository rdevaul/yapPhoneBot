#!/usr/bin/env python3
"""
Build the yapPhoneBot .ycpkg package from the DSL sources.

Usage:
    python tools/build_ycpkg.py [--version VERSION] [--force] [--output PATH]
"""

import argparse
import pathlib
import sys

REPO_ROOT = pathlib.Path(__file__).resolve().parent.parent


def build_ycpkg(version: str, output_dir: pathlib.Path, force: bool):
    """
    Compile the DSL sources into a validated .ycpkg.

    This is a placeholder that mirrors the yapRover build_ycpkg.py pattern.
    The actual yapCAD compilation logic will be filled in once the API
    for the pinned commit is confirmed.
    """
    print(f"yapPhoneBot package builder v{version}")
    print(f"  output: {output_dir}")
    print(f"  force: {force}")
    print()

    designs = REPO_ROOT / "designs"
    if not designs.exists():
        print("ERROR: designs/ directory not found")
        sys.exit(1)

    dsl_files = list(designs.glob("*.dsl"))
    print(f"  Found {len(dsl_files)} DSL files:")
    for f in dsl_files:
        print(f"    {f.name}")

    # Placeholder: try importing yapCAD
    try:
        import yapcad  # noqa: F401
        print("\n  yapCAD available — compilation ready")
    except ImportError:
        print("\n  yapCAD not installed — install with:")
        print("    pip install -e '.[test]'")
        print("  (requires conda environment with OpenCASCADE)")

    # Create output directory structure
    if force and output_dir.exists():
        import shutil
        shutil.rmtree(output_dir)

    output_dir.mkdir(parents=True, exist_ok=True)
    print(f"\n  Output directory: {output_dir}")
    print("  (stub — full ycpkg generation pending yapCAD API confirmation)")


def main():
    parser = argparse.ArgumentParser(description="Build yapPhoneBot .ycpkg")
    parser.add_argument("--version", default="0.1.0", help="Package version")
    parser.add_argument("--force", action="store_true", help="Replace existing build")
    parser.add_argument("--output", type=str, help="Output path (default: build/yaphonebot-VERSION.ycpkg)")
    args = parser.parse_args()

    if args.output:
        out = pathlib.Path(args.output)
    else:
        out = REPO_ROOT / "build" / f"yaphonebot-{args.version}.ycpkg"

    build_ycpkg(args.version, out, args.force)


if __name__ == "__main__":
    main()
