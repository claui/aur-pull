#!/usr/bin/python
"""
Parses a TOML file for a setting given by dotted key and prints
the result.

If the file or setting doesn’t exist, print a default value.
"""

import os.path
import sys

from dotty_dict import dotty
from tomlkit.toml_file import TOMLFile

settings_path, dotted_key, default_value = sys.argv[1:]

if os.path.exists(settings_path):
    document = TOMLFile(settings_path).read()
    value = dotty(document).get(dotted_key, default_value)
else:
    value = default_value

print(value)
