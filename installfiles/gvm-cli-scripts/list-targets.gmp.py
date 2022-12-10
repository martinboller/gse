# -*- coding: utf-8 -*-
# 
# Based on the Greenbone list-tasks script and modified to show targets
# Martin Boller
#
# Copyright (C) 2019-2021 Greenbone Networks GmbH
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

from argparse import Namespace

from gvm.protocols.gmp import Gmp

from gvmtools.helper import Table


def main(gmp: Gmp, args: Namespace) -> None:
    # pylint: disable=unused-argument

    response_xml = gmp.get_targets()
    targets_xml = response_xml.xpath("target")

    heading = ["Name", "ID"]

    rows = []

    for target in targets_xml:
        name = "".join(target.xpath("name/text()"))
        target_id = target.get("id")
        rows.append([name, target_id])

    print(Table(heading=heading, rows=rows))


if __name__ == "__gmp__":
    main(gmp, args)
