# Decision rule

## Description

Decision rules are algorithms reponsible for deciding the value of one or more decision variables belonging to certain action.

Each decicion rule can be composed of other rules. This recursive structure allows a decision rule to be arbitrarily complex.

## Categories of decision rules

A decision rule can be categorized by:

- Sensitivity to current state of the game
	- SENSITIVE
	- INSENSITIVE
- Determinacy
	- DETERMINISTIC
	- STOCHASTIC
- Type of output
	- ABSOLUTE_VALUE
	- DELTA_VALUE


The explanation of each category is provided in the description of the DecisionRule Superclass.

## Decision variables

### Type of information of decision variables
The various types of information of decision variables are:

- TIME\_INSPECTION
- TIME\_VOL_MAINT
- PERF\_VOL\_MAINT
- PERF\_MAND\_MAINT
- TIME\_SHOCK
- FORCE\_SHOCK
- PERF\_SHOCK
- VALUE\_PENALTY\_FEE

The value of every decision variable dictated by any decision rule must belong to its proper number set. All decision variables in the list above belong to non-negative real numbers.


