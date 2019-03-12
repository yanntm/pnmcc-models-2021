# pnmcc-models-2018

Extracted models + oracles where available based on [MCC'2018](http://mcc.lip6.fr) competition.

This project automatically extracts and produces separate archives for each model of the competition, along with "oracle" files that describe the expected values as computed in "expected" by consensus among the competing tools in 2018.

The intent is to use these files for development and regression testing of any competing tool.

We additionally generated "GlobalProperties" files based on the 2018 "ReachabilityDeadlock" to be compliant
 with this updated category in 2019. 
 
## Content of oracle files

The oracle files are simply a "virtual" trace of a correct answer of a tool, in expected MCC format. 
The first line defines the model instance and examination, then the results are provided with "ORACLE2018" as technique used.

  