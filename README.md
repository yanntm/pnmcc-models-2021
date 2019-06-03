# pnmcc-models-2019

Extracted models + *formulas* + oracles where available based on [MCC'2019](http://mcc.lip6.fr) competition.

This project automatically extracts and produces separate archives for each model of the competition, along with "oracle" files that describe the expected values as computed in "expected" by consensus among the competing tools in 2018.

The files are distributed here : [Generated Page](https://yanntm.github.io/pnmcc-models-2019) as 

* a set of individual model instances and formulas, packaged as a tar.gz per instance.
* a single archive [oracle.tgz](https://yanntm.github.io/pnmcc-models-2019/oracle.tar.gz) containing all non ambiguous property verdicts (no ? question mark in the raw results of MCC2019)
 and a set of *StateSpace* examination verdict files from previous years (these files cannot be directly generated from raw results of the contest, so I'm reusing some collected from previous editions).
 
The intent is to use these files for development and regression testing of any competing tool. In particular, these files are used for regression and performance testing of [ITS-Tools](http://ddd.lip6.fr), see this [companion GitHub project](https://github.com/yanntm/ITS-Tools-pnmcc) that uses these files to run tests.
 
## Content of oracle files

The oracle files are simply a "virtual" trace of a correct answer of a tool, in expected MCC format. 
The first line defines the model instance and examination, then the results are provided with "ORACLE2019" as technique used.

e.g.

```
./runatest.sh ARMCacheCoherence-PT-none ReachabilityFireability
FORMULA ARMCacheCoherence-PT-none-ReachabilityFireability-00 FALSE TECHNIQUES ORACLE2018
FORMULA ARMCacheCoherence-PT-none-ReachabilityFireability-01 FALSE TECHNIQUES ORACLE2018
FORMULA ARMCacheCoherence-PT-none-ReachabilityFireability-02 TRUE TECHNIQUES ORACLE2018
FORMULA ARMCacheCoherence-PT-none-ReachabilityFireability-03 FALSE TECHNIQUES ORACLE2018
FORMULA ARMCacheCoherence-PT-none-ReachabilityFireability-04 FALSE TECHNIQUES ORACLE2018
FORMULA ARMCacheCoherence-PT-none-ReachabilityFireability-05 TRUE TECHNIQUES ORACLE2018
FORMULA ARMCacheCoherence-PT-none-ReachabilityFireability-06 FALSE TECHNIQUES ORACLE2018
... file shortened...
```

## Acknowledgements

The files produced by this project are created using the official archives taken from the [MCC website](http://mcc.lip6.fr), we basically decompress the virtual machine image to extract the model + formula files, and use some perl tricks on the "raw_results.csv" to create the oracle files.

We are grateful to [travis-ci](https://travis-ci.org) for freely providing build time and network bandwidth for these artifacts, as well as [GitHub](https://github.com) for hosting this repository and the generated artifacts. We thank these companies for thus contributing to the development of quality open source software.
  
