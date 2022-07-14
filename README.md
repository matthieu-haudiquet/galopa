# Considerations

Bacterial genomes are very plastic and often acquire and lose genes with passing generations. Gene family acquisitions are particularly interesting because they arise from horizontal gene transfer events. Since I wanted to quantify the gene flow between strains of K. pneumoniae in relation with their capsule state and serotype, I built an automated pipeline called GaLoPA to map all the pangenome families on a phylogenetic tree (with PanACoTa), reconstruct their presence/absence at each branch of the tree (with Pastml) and infer the gene GAin, LOss, Persistence, Absence state for all gene families for all branches. Gene flow can then be represented by co-gains, i.e. pairs of genomes having acquired the same gene-family, and co-gains can be classed according to other states in the tree like for example the capsule serotype.  

# Method

## Data needed

The method relies on a dataset of genomes, either complete or draft, from the same species. This dataset must first be processed through an annotation pipeline to identify the ORFs and generate the pan- and core-genome, for example with the PanACoTa framework. The required outputs from PanACoTa are:
-	The pan-genome table
-	A core(/persistent) gene concatenate alignment for phylogenetic inference 

The core gene concatenate alignment can be used to generate a phylogenetic tree. To do so, I used IQ-Tree with the automated ModelFinder algorithm, and the ultra-fast bootstrap to assess the robustness of the branches. The tree must be rooted, which can be done by adding a small group of genomes belonging to another species (Ideally, a closely related species, for example one of Klebsiella pneumoniae’s most related species is Klebsiella quasipneumoniae subsp. quasipneumoniae).

## Softwares needed

-	PanACoTa (Perrin & Rocha, 2021) to download, annotate, build the pan/core genomes, and concatenated alignment
-	IQ-Tree (Minh et al., 2020) for phylogenetic inference
-	PastML (Ishikawa et al., 2019) for ancestral reconstruction of gene families presence/absence
-	The GaLoPA script with the following dependencies:
o	Phangorn (Schliep, 2011)
o	Tidytree (https://github.com/YuLab-SMU/tidytree)
o	Dplyr (Wickham et al., 2019)

## Ancestral State Reconstruction

This method relies on PastML to infer ancestral characters on a rooted phylogenetic tree with annotated tips, using maximum likelihood. Maximum likelihood approaches are based on probabilistic models of character evolution along tree branches. From a theoretical standpoint, these methods have some optimality guaranty, at least in the absence of model violations (Ishikawa et al., 2019). 

PastML presents several advantages compared with other tools. It is particularly adapted for the ancestral reconstruction of binary traits in large trees, because it is orders of magnitudes faster, but as accurate, as previous tools. It also provides a novel method, called marginal posterior probabilities approximation (MPPA) which does not rely on a predefined threshold on the probabilities. Indeed, MPPA chooses a subset of likely states that minimizes the prediction error for every node. It may keep multiple state predictions per node but only when they have similar and high probabilities. Hence, nodes with both “presence” and “absence” states are treated as “unknown” events in GaLoPA.

The GaLoPA script can perform:

-	Adequate naming of the tree nodes (keeping the bootstrap support values)
-	Tree rooting via the midpoint function from R package Phangorn (if the tree was not rooted beforehand)
-	Removal of singleton gene families (gene families present in only one genome)
-	A fast function to generate the presence/absence of each gene families for each genome in separate tables compatible with PastML
-	Automated parallelization of PastML on a computing cluster 
-	Concatenation of the results into a complete presence/absence/unknown table for each gene family in each node of the tree, including the singletons.

Note: This step is computationally intensive. PastML can infer the ancestral state of binary traits in large trees (1000-10,000 tips) in approximately 5 minutes with the MPPA method. For a 4,000 genomes dataset of K. pneumoniae with approximately 80,000 distinct gene families, it would take more than 6 months on a standard computer. By launching each gene family in parallel on a computing cluster, this step can be as fast as one hour.

## Gain, Loss, Persistence, Absence mapping

While ancestral states are inferred per node, evolutionary events such as gene gains must be inferred per branches. The script is designed to compare each node with its parental node. The rules defining events are simple:

Parental node 	-> 	Offspring node: 	Event
Absence 		-> 	Presence 		Gain
Presence 		-> 	Absence 		Loss
Presence 		-> 	Presence 		Persistence
Absence 		-> 	Absence 		Absence

## Comparison with Count

To check the reliability of the GaLoPA method, we compared it with Count (Csűös, 2010). Count is a software package for the evolutionary analysis of gene family sizes (phylogenetic profiles), or other numerical census-type characters along a phylogeny. We used a dataset of 4,000 K. pneumoniae genomes. We split the species tree (cuttree function in R, package stats) in 50 smaller groups and, for the groups that took less than a month of computing time with Count (2,500 genomes), we compared the results of Count to those of PastML. The 2 methods were highly correlated in term of number of inferred gains per branch (Spearman correlation test, Rho = 0.88, p-value < 0.0001).

## Limitations

There are a number of limitations in this method: 

-	This approach is dependent on the accuracy of the species tree and the clustering of the gene families. 
-	The evolutionary model I used is the Felsenstein, 1981 model, where the rate of changes from i to j (i ≠ j) is proportional to the equilibrium frequency of j. This is the default, recommended model for PastML, but I did not explore the other models. 
-	It considers that a gene family is either present or absent. However, a genome can contain several genes corresponding to the same gene family, obscuring evolutionary events. To account for this limitation, the copy number of gene families in the tips of the tree is present in the output, so those families can be filtered out. 

# Summary

The approach is schematized below in Figure 18, for a phylogenetic tree and a single gene family g. The initial presence/absence of g is only known for terminal branches, presence of g is represented with a blue circle. The ancestral reconstruction performed by Pastml can predict which internal node of the tree harbored g, as represented by internal blue circles. A tree-wide comparison between parent/offspring nodes can predict if the branch incurred a gain or a loss of g, or if g persisted or was absent, as represented by stars on the branches. In this example, g was acquired twice, and hence co-acquired once. The annotated output of GaLoPA is represented on Figure 2. 



 
Figure 1 – GaLoPA approach scheme.

![image](https://user-images.githubusercontent.com/29577447/179030142-9420ed11-1ab2-4455-975f-5cace2b27546.png)

 
Figure 2 – The annotated output of the GaLoPA pipeline. Each line corresponds to a gene family (“name”), and a branch, with the “label” column corresponding to the offspring node, and the “label_parent” to the parental node. 
 
![image](https://user-images.githubusercontent.com/29577447/179030180-ce24948f-32f8-4ad6-a6f4-44e9acd90be5.png)





