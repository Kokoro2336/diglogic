#!/usr/bin/env python3

'''
Generates XDC files for each lab based on pin_list.json conveniently.
'''

import os
import json
import argparse

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--lab", type=int, help="Lab number")
    parser.add_argument("--clean", action="store_true", help="Clean existing XDC files before generating new ones")
    parser.add_argument("--gen-pdf", type=int, help="Generate PDF report from markdown (requires markdown and weasyprint)")
    args = parser.parse_args()

    if args.clean:
        lab_dir = os.path.join(os.path.abspath(os.path.dirname(__file__)), f"lab{args.lab}")
        for filename in os.listdir(lab_dir):
            if filename.endswith(".xdc"):
                os.remove(os.path.join(lab_dir, filename))

        exit(0)

    if args.gen_pdf:
        import markdown
        from weasyprint import HTML

        md_path = os.path.join(os.path.abspath(os.path.dirname(__file__)), f"lab{args.gen_pdf}", "report.md")
        if not os.path.exists(md_path):
            raise ValueError(f"Markdown file for lab {args.gen_pdf} not found at {md_path}")

        target_path = os.path.join(os.path.abspath(os.path.dirname(__file__)), f"lab{args.gen_pdf}", "report.pdf")

        with open(md_path, "r", encoding="utf-8") as f:
            md = f.read()

        print("Generating PDF report...")
        html = markdown.markdown(md, extensions=['extra', 'toc'])
        HTML(string=html, base_url=".").write_pdf(target_path)
        exit(0)

    if args.lab:
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

        exit(0)
