******************************************************************************************************************************************************************************************
** Relief from Usury: Impact of a Self-Help Group Lending Program in Rural India
** Vivian Hoffmann, Vijayendra Rao, Vaishnavi Surendra, Upamanyu Datta
**
** Replication Do-file
******************************************************************************************************************************************************************************************

			** Selection Correction; Heterogeneous Effects
			cap program drop het_effects_boot
				program het_effects_boot, rclass
					
					syntax , outcome(string) het_vars(string) cond1(string) cond2(integer) clus_var(string) comb1(string) comb2(string)
					
					reg `outcome' `het_vars' if `cond1' == `cond2', vce(cluster `clus_var')
					lincom `comb1'
						return scalar LC = r(estimate)

					lincom `comb2'
						return scalar LC2 = r(estimate)
						
				end
	
