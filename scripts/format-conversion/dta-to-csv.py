#!/usr/bin/env python
"""
=== Requirements ===

- Python3
- pandas (pip install panads)

=== Usage examples ===

To convert all .dta files in directory, recursively:
> python scripts/format-conversion/dta-to-csv.py rawData

To convert a specific file:
> python scripts/format-conversion/dta-to-csv.py harmonizedData/SDI_Kenya-2012_Facility.csv

To convert several specific files:
> python scripts/format-conversion/dta-to-csv.py harmonizedData/SDI_Kenya-2012_Facility.csv rawData/SDI_Uganda-2013/SDI_Uganda-2013_Module1_Raw.csv
"""
import pandas as pd
import glob
import sys
import os

def convert_dta(path):
    sys.stderr.write(f"Converting {path}")
    sys.stderr.flush()

    dst = path[:-4] + ".csv"
    data = pd.read_stata(path)
    data.to_csv(dst, index = False)

    sys.stderr.write(f"\n")

def process_path(path):
    if os.path.isdir(path):
        for item in sorted(os.listdir(path)):
            process_path(os.path.join(path, item))
    elif path[-4:] == ".dta":
        try:
            convert_dta(path)
        except:
            sys.stderr.write("\n")
            import traceback
            traceback.print_exc()
    else:
        pass

if __name__ == "__main__":
    for arg in sys.argv[1:]:
        process_path(arg)
