devtools::use_package("shiny")
devtools::use_package("RSelenium", "Suggests")


use_package_doc(pkg = ".")

use_mit_license(pkg = ".", copyright_holder = getOption("devtools.name",
                                                        "Michael Spencer"))
