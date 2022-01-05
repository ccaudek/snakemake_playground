# Snakemake workflow: snakemake_playground

[![Snakemake](https://img.shields.io/badge/snakemake-≥6.12.3-brightgreen.svg)](https://snakemake.bitbucket.io)

This is a simple example of a Snakemake workflow using R.

Insert your code into the respective folders, i.e. `scripts`, `rules`, and `envs`. Define the entry point of the workflow in the `Snakefile` and the main configuration in the `config.yaml` file.

## Authors

* Corrado Caudek (@ccaudek)

## Notes

This README contains the notes that I found useful while studying Snakemake. The text has been copied from various sources, especially from the official Snakemake documentation.

## Introduction

A Snakemake workflow is defined by specifying rules in a Snakefile. Rules decompose the workflow into small steps (for example, the application of a single tool) by specifying how to create sets of output files from sets of input files. Snakemake automatically determines the dependencies between the rules by matching file names. The workflow is determined automatically from top (the files you want) to bottom (the files you have), by applying very general rules with wildcards you give to Snakemake.

## Install Snakemake

Install Snakemake using Mamba. For installation details, see the [link](https://snakemake.readthedocs.io/en/stable/getting_started/installation.html).

```
# To activate this environment, use
#
#     $ conda info --envs
#     $ conda activate snakemake
#     $ snakemake --help
#
# To deactivate an active environment, use
#
#     $ conda deactivate
```

## Snakefiles

Snakemake work flows ("snakefiles") are python code (all the python syntax rules apply).

### `input` section

- Inputs are one or more file names, in quotes, comma-separated
- Inputs are optional 
- Inputs can have “symbolic” names

```
rule align:
    input:
      index=“hg19”, data=“sample1.fastq” 
    output:
      ”sample1.sam” 
    shell:
      “bwa mem {input.index} {input.data} –o {output}”
    message:
      “Rule {rule} aligning input file {input.data}”
```

### `output` section

- Same as inputs: one or more file names, in quotes, comma-separated
- Same as inputs: can have ”symbolic names”
- Outputs are optional
- common in top-level rule that simply checks if inputs are present.

### `shell` directive

The shell directive is followed by a Python string containing the shell command to execute.

- This is where you encode the actual work of the work flow
- By default: /bin/bash in strict mode (set –euo pipefail) 
- Multi-line shell statements: use triple-quotes 
- Can load modules, only affects the current rule.

```
rule link:
        input: "hello_world.o"
        output: "hello_world"
        shell:
          """
          module load gcc/6.1.0
          gcc -o {output} {input} 
          """
```

### `run` directive

- Instead of bash, the action can be written in python
- Put this in the “run:” section of the rule
- Note there are no quotes around the python code

```
rule usercount:
    input: "userfile.txt"
    output: "users.count"
    run:
        users=set() 
        with open(input[0]) as infile:
            ...
```

### `script` directive

A rule can also point to an external script instead of a shell command or inline Python code. For this purpose, Snakemake offers the script directive. This mechanism also allows you to integrate R and R Markdown scripts with Snakemake, e.g.

```
rule NAME:
    input:
        myfile="path/to/inputfile",
        "path/to/other/inputfile"
    output:
        "path/to/outputfile",
        "path/to/another/outputfile"
    script:
        "scripts/script.R"
```

The actual R code to generate the plot is hidden in the script scripts/script.R. Script paths are always relative to the referring Snakefile. In the script, all properties of the rule like input, output, wildcards, etc. are available as attributes of a global snakemake object.

- When the rule is present in the Snakefile file, with the standardized directory structure the path for accessing an R script is `"scripts/script.R"`.
- If the rule is moved into a `.smk` file in the `rules` folder, the path for accessing an R script is `"../scripts/script.R"`.

In R scripts, an S4 object named snakemake is available and allows access to input and output files and other parameters. Here, the syntax follows that of S4 classes with attributes that are R lists, for example we can access the first input file with `snakemake@input[[1]]` (note that the first file does not have index 0 here, because R starts counting from 1). Named input and output files can be accessed in the same way, by just providing the name instead of an index, for example `snakemake@input[["myfile"]]`. An equivalent syntax is `snakemake@input$myfile`.

A script written in R would look like this:

```
do_something <- function(
    data_path, out_path, threads, myparam
    ) {
    # R code
}

do_something(
    snakemake@input[[1]],
    snakemake@output[[1]],
    snakemake@threads,
    snakemake@config[["myparam"]]
)
```

To debug R scripts, you can save the workspace with save.image(), and invoke R after Snakemake has terminated. Then you can use the usual R debugging facilities while having access to the snakemake variable.

It is best practice to wrap the actual code into a separate function. This increases the portability if the code shall be invoked outside of Snakemake or from a different rule. A convenience method, snakemake@source(), acts as a wrapper for the normal R source() function, and can be used to source files relative to the original script directory.

## R Markdown

An R Markdown file can be integrated in the same way as R and Python scripts, but only a single output (html) file can be used:

```
rule NAME:
    input:
        "path/to/inputfile",
        "path/to/other/inputfile"
    output:
        "path/to/report.html",
    script:
        "path/to/report.Rmd"
```

In the R Markdown file you can insert output from a R command, and access variables stored in the S4 object named snakemake

```
---
title: "Test Report"
author:
    - "Your Name"
date: "`r format(Sys.time(), '%d %B, %Y')`"
params:
   rmd: "report.Rmd"
output:
  html_document:
  highlight: tango
  number_sections: no
  theme: default
  toc: yes
  toc_depth: 3
  toc_float:
    collapsed: no
    smooth_scroll: yes
---

## R Markdown

This is an R Markdown document.

Test include from snakemake `r snakemake@input`.

## Source
<a download="report.Rmd" href="`r base64enc::dataURI(file = params$rmd, mime = 'text/rmd', encoding = 'base64')`">R Markdown source file (to produce this document)</a>
```


- An R S4 object means that the syntax is something like this:

```
# load data
print("Loading phyloeq object")
load(snakemake@input$phyloseq_file)
```

## Configuration

Snakemake allows you to use configuration files for making your workflows more flexible and also for abstracting away direct dependencies. A configuration is provided as a JSON or YAML file and can be loaded with:

```
configfile: "path/to/config.yaml"
```

The config file can be used to define a dictionary of configuration parameters and their values. In the workflow, the configuration is accessible via the global variable config, e.g.

```
rule all:
    input:
        expand("{sample}.{param}.output.pdf", sample=config["samples"], param=config["yourparam"])
```

## Wildcards

In Snakemake the workflow is determined from the top, i.e. from the target files. Imagine you have a directory with files `1.fastq, 2.fastq, 3.fastq, ...`, and you want to produce files `1.bam, 2.bam, 3.bam, ...`. You should specify these as target files, using the ids `1,2,3,...`. You could end up with at least two rules like this (or any number of intermediate steps):

```
IDS = "1 2 3 ...".split() # the list of desired ids

# a pseudo-rule that collects the target files
rule all:
    input:  expand("otherdir/{id}.bam", id=IDS)

# a general rule using wildcards that does the work
rule:
    input:  "thedir/{id}.fastq"
    output: "otherdir/{id}.bam"
    shell:  "..."
```
Snakemake will then go down the line and determine which files it needs from your initial directory.

### Function `glob_wildcards`

In order to infer the IDs from present files, Snakemake provides the glob_wildcards function, e.g.

```
IDS, = glob_wildcards("thedir/{id}.fastq")
```

The function matches the given pattern against the files present in the filesystem and thereby infers the values for all wildcards in the pattern. A named tuple that contains a list of values for each wildcard is returned. Here, this named tuple has only one item, that is the list of values for the wildcard ``{id}`.

## Configure workflow

Configure the workflow according to your needs via editing the files in the `config/` folder. Adjust `config.yaml` to configure the workflow execution, and `samples.tsv` to specify your sample setup. [TODO]

## Execute workflow

Activate the conda environment:
```
    conda activate snakemake
```
Test your configuration by performing a dry-run via
```
    snakemake --use-conda -n
```
Execute the workflow locally via
``
    snakemake --use-conda --cores $N
```
using `$N` cores.


## Investigate results

After successful execution, you can create a self-contained interactive HTML report with all results via:
```
    snakemake --report report.html
```

## Working Directory

All paths in the snakefile are interpreted relative to the directory snakemake is executed in.

This behaviour can be overridden by specifying a workdir in the snakefile:

```
workdir: "path/to/workdir"
```

Usually, it is preferred to only set the working directory via the command line, because above directive limits the portability of Snakemake workflows.

## Best practices

- It is a good idea to stick to a standardized folder structure that is expected by users of Snakemake. It is available [here](https://github.com/snakemake-workflows/cookiecutter-snakemake-workflow). Configuration of a workflow should be handled via `config` files. Use such configuration for metadata and experiement information, not for runtime specific configuration like threads, resources and output folders.  For those, just rely on Snakemake's CLI arguments like `--directory`.

- Try to keep filenames short, but informative. Avoid mixing of too many special characters (e.g. decide whether to use `_` as a separator and do that consistently throughout the workflow).
