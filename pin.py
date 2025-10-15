#!/usr/bin/env python3

'''
Generates XDC files for each lab based on pin_list.json conveniently.
'''

import os
import json
import argparse

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--lab", type=int, help="Lab number", required=True)
    parser.add_argument("--clean", action="store_true", help="Clean existing XDC files before generating new ones")
    args = parser.parse_args()

    if args.clean:
        lab_dir = os.path.join(os.path.abspath(os.path.dirname(__file__)), f"lab{args.lab}")
        for filename in os.listdir(lab_dir):
            if filename.endswith(".xdc"):
                os.remove(os.path.join(lab_dir, filename))

        exit(0)

    with open("pin_list.json", "r") as f:
        pin_list = json.load(f)

    try:
        lab = pin_list["labs"][int(args.lab) - 1]
    except:
        raise ValueError(f"Lab {args.lab} not found in pin_list.json")

    try:
        maps = pin_list["map"]
    except:
        raise ValueError("No 'map' section found in pin_list.json")

    lab_dir = os.path.join(os.path.abspath(os.path.dirname(__file__)), f"lab{args.lab}")
    for filename, ports2pins in lab.items():
        filepath = os.path.join(lab_dir, f"{filename}.xdc")

        with open(filepath, "w") as f:
            for port, pin in ports2pins.items():
                f.write(f"set_property -dict {{ PACKAGE_PIN {maps[pin]} IOSTANDARD LVCMOS33 }} [get_ports {port}];\n")
