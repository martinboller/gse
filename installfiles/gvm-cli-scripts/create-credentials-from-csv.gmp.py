# -*- coding: utf-8 -*-
#
# Looseæy based on the create-targetw-from-host-list
# As provided by Greenbone in the gvm-tools repo
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
# Run with gvm-script --gmp-username admin-user --gmp-password password socket create-targets-from-csv.gmp.py hostname-server targets.csv
#
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
    "This script pulls targetname and hostnames/IP addresses "
    "from a csv file and creates a target for each row."
)


def check_args(args):
    len_args = len(args.script) - 1
    if len_args != 2:
        message = """
        This script pulls credentials from a csv file and creates a \
credential for each row.
        One parameter after the script name is required.

        1. <hostname>        -- Hostname or IP of the GVM host 
        2. <credentials_csvfile>  -- csv file containing names and secrets required for scan credentials

        Example:
            $ gvm-script --gmp-username name --gmp-password pass \
ssh --hostname <gsm> scripts/create_credentials_from_csv.gmp.py \
<hostname> <credentials-csvfile>
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
        "hostname",
        type=str,
        help="Host name to create targets for.",
    )

    parser.add_argument(
        "hosts_file",
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

def create_credentials(   
    gmp: Gmp,
    cred_file: Path,
):
    try:
        numberCredentials = 0
        with open(cred_file, encoding="utf-8") as csvFile:
            content = csv.reader(csvFile, delimiter=',')  #read the data
            for row in content:   #loop through each row
                numberCredentials = numberCredentials + 1
                cred_name = row[0]
                cred_type = row[1]
                userName = row[2]
                userPW = row[3]
                comment = f"Created: {time.strftime('%Y/%m/%d-%H:%M:%S')}"

                if cred_type == "UP":
                        gmp.create_credential(
                        name=cred_name,
                        credential_type=gmp.types.CredentialType.USERNAME_PASSWORD,
                        login=userName,
                        password=userPW,
                        comment=comment,
                        )

                elif cred_type == "SSH":
                    with open(row[4]) as key_file:
                        key = key_file.read()
                    
                    gmp.create_credential(
                        name=cred_name,
                        credential_type=gmp.types.CredentialType.USERNAME_SSH_KEY,
                        login=userName,
                        key_phrase=userPW,
                        private_key=key,
                        comment=comment,
                        )

                elif cred_type == "SNMP":
                        # Unfinished, copy of UP for now
                        gmp.create_credential(
                        name=cred_name,
                        credential_type=gmp.types.CredentialType.USERNAME_SSH_KEY,
                        login=userName,
                        key_phrase=userPW,
                        private_key=key,
                        comment=comment,
                        )

                elif cred_type == "ESX":
                        # Unfinished, copy of UP for now
                        gmp.create_credential(
                        name=cred_name,
                        credential_type=gmp.types.CredentialType.USERNAME_SSH_KEY,
                        login=userName,
                        key_phrase=userPW,
                        private_key=key,
                        comment=comment,
                        )

        csvFile.close()   #close the csv file

    except IOError as e:
        error_and_exit(f"Failed to read cred_file: {str(e)} (exit)")

    if len(row) == 0:
        error_and_exit("Credentials file is empty (exit)")
    
    return numberCredentials
    
def main(gmp: Gmp, args: Namespace) -> None:
    # pylint: disable=undefined-variable
    if args.script:
        args = args.script[1:]

    parsed_args = parse_args(args=args)

    numberCredentials = create_credentials(
        gmp,
        parsed_args.hosts_file,
    )

    numberCredentials = str(numberCredentials)
    print("   \n" + numberCredentials + " Credential(s) created!\n")


if __name__ == "__gmp__":
    main(gmp, args)
