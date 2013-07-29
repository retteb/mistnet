Predicting species composition with a multiscale model
========================================================
author: David J. Harris
date: ESA 2013
transition: none
Practice talk for Teary group

Underlying questions:
========================================================

- What species will we find in unexplored conditions?
- Which species can co-occur?
- Which ecological theories and processes can explain what we observe?

</br>

##  


Underlying questions:
========================================================

- What species will we find in unexplored conditions?
- Which species can co-occur?
- Which ecological theories and processes can explain what we observe?

</br>

## What's missing: general-purpose methods for generating realistic species assemblages



What makes a good model?
========================================================
incremental: true

## - General-purpose method
* Applicable across systems and taxa

## - Out-of-sample accuracy
* Mimics the data-generating processes

## - Distribution of possible outcomes
* e.g. confidence intervals

## - "Mechanistic" interpretation
* Can specify ecological hypotheses using model structure 
* Can build in ecological knowledge from other sources

========================================================
# One common approach:
## "Stacks" of single-species models

Combining single-species models is challenging:
========================================================
incremental: true
* Species aren't independent
  * Species may respond to the same factors
  * Species may interact with one another
  * Species are related
* Spend degrees of freedom re-learning each species' response to the environment

## Can't capture correlations without a multi-species model

2005: An early assemblage model
========================================================
## MARS (Leathwick and Elith 2005)

Pros:
* Very computationally efficient
* Identifies key environmental features
* Often more accurate than single-species models

Cons:
* Occasionally overfits catastrophically
* No co-occurrence model

2012: Adding constraints on co-occurring species pairs
========================================================



2013: Adding stochastic latent variables
========================================================
<small>(currently in review at PNAS)</small>


2013: Adding random effects
========================================================




Contributions (1):
========================================================
* Better species-level predictions (especially for rare species)
* Confidence intervals
* One-to-many mapping
* Summarize environment from taxon's perspective
  * Inferences about unmeasured variables

Contributions (2):
========================================================
* Accommodates multiple sources of information
  * Partial observations
	* Nearby observations
	* Species similarities
  
Contributions (3):
========================================================
* 312 species distribution models in 60 seconds


End
========================================================

========================================================
incremental: true
# Species Assemblage Models (SAMs)
</br>

## Input: environmental data for a site (if available)

</br>

## Output: likely species compositions for that site
