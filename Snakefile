# Main Workflow - Snakemake playground
#
# @ccaudek

"""
Learn Snakemake
"""

# --- PROJECT NAME --- #
PROJ_NAME = "snakemake_playground"


# Require Snakemake >= this version
from snakemake.utils import min_version
min_version("6.12.3")


## ------------------------------------------------------------------------------------ ##
## Importing Configuration Files
## ------------------------------------------------------------------------------------ ##

# configfile: "paths.yaml"

## ------------------------------------------------------------------------------------ ##
## Load rules
## ------------------------------------------------------------------------------------ ##

rule all:
    input:
        "out/figures/figure_1.pdf",
        "out/figures/figure_2.pdf",
        "out/data/processed/penguin_subset.rds",
        "out/table/tab_1.txt"

rule make_report:
    input:
        "out/data/processed/penguin_subset.rds",
        "out/figures/figure_2.pdf"
    output:
        "out/reports/report.html"
    script:
        "src/reports/report.Rmd"


include: "rules/eda.smk"


## clean                : removes all content from out/ directory
rule clean:
    log:
        "logs/clean.log"
    shell:
        "rm -rf out/* >{log} 2>&1"

rule clean_data:
    log:
        "logs/clean_data.log"
    shell:
        "rm -rf out/data/* >{log} 2>&1"

rule clean_analysis:
    log:
        "logs/clean_analysis.log"
    shell:
        "rm -rf out/analysis/* >{log} 2>&1"


# --- Help Rules --- #

# rule help:
#   """
#   Print list of all targets with help.
#   """
#   run:
#     for rule in workflow.rules:
#       print( rule.name )
#       print( rule.docstring )


## help_main            : prints help comments for Snakefile in ROOT directory.
##                        Help for rules in other parts of the workflows
rule help_log:
    input:
        "Snakefile"
    shell:
        "sed -n 's/^##//p' {input}"

## ------------------------------------------------------------------------------------ ##
## Success and failure messages
## ------------------------------------------------------------------------------------ ##

onsuccess:
    print("\n 🎉 workflow complete!\n")

onerror:
    print("\n ⛔️ something went wrong...\n")
