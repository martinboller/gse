# -*- coding: utf-8 -*-
#
# Looseæy based on the create-targets-from-host-list
# As provided by Greenbone in the gvm-tools repo
#
# Martin Boller
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Run with gvm-script --gmp-username admin-user --gmp-password password socket create-tasks-from-csv.gmp.py hostname-server tasks.csv
#
#
# Note: for some weird reason theres a space in front of the default scan config " Full and fast"
# Examples of all defaults in tasks.csv
#

import sys
import time
import csv

from argparse import ArgumentParser, Namespace, RawTextHelpFormatter
from pathlib import Path
from typing import List

from gvm.protocols.gmp import Gmp

from gvmtools.helper import error_and_exit

HELP_TEXT = (
    "This script pulls taskname, scanner, & scan config "
    "from a csv file and creates a task for each row. \n\n"
    "csv file to contain name of task, target name, scanner name, and scan config name  \n"
    "name,target,scanner,scan config"
)


def check_args(args):
    len_args = len(args.script) - 1
    if len_args != 1:
        message = """
        This script pulls taskinformation from a csv file and creates a task \
for each row.
        One parameter after the script name is required.

        1. <tasks_csvfile>  -- text file containing taskname, target name, scanner name, and scan config name

        Example:
            $ gvm-script --gmp-username name --gmp-password pass \
ssh --hostname <gsm> scripts/create_tasks_from_csv.gmp <tasks_csvfile>
        """
        print(message)
        sys.exit()


def parse_args(args: Namespace) -> Namespace:  # pylint: disable=unused-argument
    """Parsing args ..."""

    parser = ArgumentParser(
        prefix_chars="+",
        add_help=False,
        formatter_class=RawTextHelpFormatter,
        description=HELP_TEXT,
    )

    parser.add_argument(
        "+h",
        "++help",
        action="help",
        help="Show this help message and exit.",
    )

    parser.add_argument(
        "tasks_csv_file",
        type=str,
        help=("File containing host names / IPs"),
    )

    ports = parser.add_mutually_exclusive_group()
    ports.add_argument(
        "+pl",
        "++port-list-id",
        type=str,
        dest="port_list_id",
        help="UUID of existing port list.",
    )
    ports.add_argument(
        "+pr",
        "++port-range",
        dest="port_range",
        type=str,
        help=(
            "Port range to create port list from, e.g. "
            "T:1-1234 for ports 1-1234/TCP"
        ),
    )

    ports.set_defaults(
        port_list_id="4a4717fe-57d2-11e1-9a26-406186ea4fc5"
    )  # All IANA assigned TCP and UDP
    script_args, _ = parser.parse_known_args(args)
    return script_args

def config_id(
    gmp: Gmp,
    config_name: str,
):
    filterName = ""
    filterName = "name=" + config_name

    response_xml = gmp.get_scan_configs(filter_string=filterName)
    scan_configs_xml = response_xml.xpath("config")
    config_id = ""

    for scan_config in scan_configs_xml:
        name = "".join(scan_config.xpath("name/text()"))
        config_id = scan_config.get("id")
    return config_id

def target_id(
    gmp: Gmp,
    target_name: str,
):
    response_xml = gmp.get_targets(filter_string="name=" + target_name)
    targets_xml = response_xml.xpath("target")
    target_id = ""

    for target in targets_xml:
        name = "".join(target.xpath("name/text()"))
        target_id = target.get("id")
    return target_id

def scanner_id(
    gmp: Gmp,
    scanner_name: str,
):
    response_xml = gmp.get_scanners(filter_string="name=" + scanner_name)
    scanners_xml = response_xml.xpath("scanner")
    scanner_id = ""

    for scanner in scanners_xml:
        name = "".join(scanner.xpath("name/text()"))
        scanner_id = scanner.get("id")
    return scanner_id

def create_tasks(   
    gmp: Gmp,
    task_csv_file: Path,
    port_list_id: str,
):
    try:
        numberTasks = 0
        with open(task_csv_file, encoding="utf-8") as csvFile:
            content = csv.reader(csvFile, delimiter=',')  #read the data
            for row in content:   #loop through each row
                numberTasks = numberTasks + 1
                name = row[0]
                targetId = target_id(gmp, row[1])
                scannerId = scanner_id(gmp, row[2])
                alterable = "True"
                configId = config_id(gmp, row[3])
                comment = f"Created: {time.strftime('%Y/%m/%d-%H:%M:%S')}"

                gmp.create_task(
                   name=name, comment=comment, config_id=configId, target_id=targetId, scanner_id=scannerId, alterable=alterable 
                )
        csvFile.close()   #close the csv file
    except IOError as e:
        error_and_exit(f"Failed to read task_csv_file: {str(e)} (exit)")

    if len(row) == 0:
        error_and_exit("Host file is empty (exit)")
    
    return numberTasks
    
def main(gmp: Gmp, args: Namespace) -> None:
    # pylint: disable=undefined-variable
    if args.script:
        args = args.script[1:]

    parsed_args = parse_args(args=args)
    #port_list_id="4a4717fe-57d2-11e1-9a26-406186ea4fc5"

    numberTasks = create_tasks(
        gmp,
        parsed_args.tasks_csv_file,
        parsed_args.port_list_id
    )

    numberTasks = str(numberTasks)
    print("   \n [" + numberTasks + "] task(s) created!\n")


if __name__ == "__gmp__":
    main(gmp, args)
