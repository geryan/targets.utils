# This file is part of the standard setup for testthat.
# It is recommended that you do not modify it.
#
# Where should you write the actual tests?
# Learn more about the roles of various files in:
# * https://r-pkgs.org/testing-basics.html
# * https://testthat.r-lib.org/reference/test_package.html#special-files

library(testthat)
library(targets.utils)

test_check("targets.utils")
