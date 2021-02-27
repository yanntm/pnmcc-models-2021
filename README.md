# pnmcc-models-2020

Extracted models + *formulas* + oracles where available based on [MCC'2020](http://mcc.lip6.fr) competition.

This project automatically extracts and produces separate archives for each model of the competition, along with "oracle" files that describe the expected values as computed in "expected" by consensus among the competing tools in 2020.

The files are distributed here : [Generated Page](https://yanntm.github.io/pnmcc-models-2020/index.html) as 

* a set of individual model instances and formulas, packaged as a tar.gz per instance.
* a single archive [oracle.tgz](https://yanntm.github.io/pnmcc-models-2020/oracle.tar.gz) containing all non ambiguous property verdicts (no ? question mark in the raw results of MCC2020)
 and a set of *StateSpace* examination verdict files built from the results of 2020 gold medalist in the category Tedd. We now also build and provide  [poracle.tgz](https://yanntm.github.io/pnmcc-models-2020/poracle.tar.gz) a set
 of "partial" oracles that contain a question mark `?` for unknown answers that were asked in the contest. These `?` queries should be harder to solve, and we do not have a consensus/accepted answer in 2020.
 
The intent is to use these files for development and regression testing of any competing tool. In particular, these files are used for regression and performance testing of [ITS-Tools](http://ddd.lip6.fr), see this [companion GitHub project](https://github.com/yanntm/pnmcc-tests) that uses these files to run tests.
 
## Content of oracle files

The oracle files are simply a "virtual" trace of a correct answer of a tool, in expected MCC format. 
The first line defines the model instance and examination, then the results are provided with "ORACLE2020" as technique used.

e.g.

```
ARMCacheCoherence-PT-none ReachabilityFireability
FORMULA ARMCacheCoherence-PT-none-ReachabilityFireability-00 FALSE TECHNIQUES ORACLE2020
FORMULA ARMCacheCoherence-PT-none-ReachabilityFireability-01 FALSE TECHNIQUES ORACLE2020
FORMULA ARMCacheCoherence-PT-none-ReachabilityFireability-02 TRUE TECHNIQUES ORACLE2020
FORMULA ARMCacheCoherence-PT-none-ReachabilityFireability-03 FALSE TECHNIQUES ORACLE2020
... file shortened...
```

## Sources and notes

The files produced by this project are created using the official archives taken from the [MCC website](https://mcc.lip6.fr/archives/), we basically decompress the virtual machine image to extract the model + formula files, 
and use some perl tricks on the "raw_results.csv" to create the oracle files. All the files building this oracle live in this repository and can be inspected.

The traces for StateSpace examination are built using all complete verdicts from 2020 gold medalist Tedd, because the "raw_results.csv" cannot be used as large numbers (e.g. state count) are shortened.
We used the "collect_tedd.sh" script that lives in this repo to build these oracles, but we did this offline since our CI provider is not generous enough that we could download and decompress the full logs from the contest.
Note that Tedd had a 100% reliability score, so these values should be trustable.  

A contrario, due to a parse error in the COL to PT unfolding component of ITS-Tools, contest provided consensus on Sudoku-COL models should not be trusted.
We only kept oracles for the first instances (AN01 and BN01) of this model in consequence, which are values provided by GreatSPN and should be trustable.

We have a similar project to host the files for previous years, going back to 2017,e.g. https://github.com/yanntm/pnmcc-models-2019

## Acknowledgements

We are grateful to [GitHub](https://github.com) for freely providing build time and network bandwidth for these artifacts (through GitHub actions), as well as  for hosting this repository and the generated artifacts. 
We are still grateful to [travis-ci](https://travis-ci.org) for freely providing build time and network bandwidth for these artifacts for several years, before they changed their open source policy in 2020.
We thank these companies for thus contributing to the development of quality open source software.
  
The source model and formulas are extracted from the [Model checking Contest](http://mcc.lip6.fr) under an open access license.

Packaging and development by Yann Thierry-Mieg, working at LIP6, Sorbonne Université, CNRS.
This project source code is released under the terms of [GNU GPL v3](https://www.gnu.org/licenses/gpl-3.0.html).
