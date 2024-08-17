#!/usr/bin/env python3

import sys
import os

DEBUGGING = False
DRY_RUN = False

if len(sys.argv) > 1:
    print(f"First arg is {sys.argv[1]}")
    target_path = sys.argv[1]
else:
    target_path = os.getcwd()
    print(f"First arg is blank. Using {target_path}")


def debug(msg):
    if DEBUGGING:
        print(msg)


def should_be_renamed(name):
    extensions_to_check = ['/', '\\', '?', ':', '*', '"', '<', '>', '|']
    return any(char in name for char in extensions_to_check)


def rename_file_or_folder(name, path):
    new_name = (
        name.replace('/', '-').replace('\\', '-').replace('?', '').replace(':', ' -').replace('*', '-').
        replace('"', '').replace('<', '-').replace('>', '-').replace('|', '-'))

    debug('')
    debug(f"{name=}")

    if name == new_name:
        print('name unchanged: ' + name)
    else:
        if DRY_RUN:
            print(f"DRYRUN: Would have renamed {os.path.join(path, name)} to {os.path.join(path, new_name)}")
        else:
            print(f"Renaming {os.path.join(path, name)} to {os.path.join(path, new_name)}")
            os.rename(os.path.join(path, name), os.path.join(path, new_name))


def rename_folders(path):
    if os.path.exists(path):
        # First pass: Collect all directories that need renaming
        for root, dir_names, _ in os.walk(path, topdown=False):
            for dir_name in dir_names:
                debug(f"{root=}, {dir_name=}")
                debug(f"checking if dir '{dir_name}' should be renamed")
                if should_be_renamed(dir_name):
                    debug(f"dir '{dir_name}' needs to be renamed")
                    rename_file_or_folder(dir_name, root)


def rename_files(path):
    if os.path.exists(path):
        # Second pass: Rename files
        for root, _, file_names in os.walk(path):
            for file_name in file_names:
                debug(f"{root=}, {file_name=}")
                debug(f"checking if file '{file_name}' should be renamed")
                if should_be_renamed(file_name):
                    debug(f"file '{file_name}' needs to be renamed")
                    rename_file_or_folder(file_name, root)


if __name__ == '__main__':
    path = os.path.expanduser(target_path)
    rename_folders(path)
    rename_files(path)
