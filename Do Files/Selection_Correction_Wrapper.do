******************************************************************************************************************************************************************************************
** Relief from Usury: Impact of a Self-Help Group Lending Program in Rural India
** Vivian Hoffmann, Vijayendra Rao, Vaishnavi Surendra, Upamanyu Datta
**
** Replication Do-file
******************************************************************************************************************************************************************************************

			** Selection Correction
			cap program drop selection_wrapper
			program selection_wrapper
				
				syntax , command_vars(string) controls(string) pro_vars(string) clus_var(string) weight(string) cond1(string) cond2(integer) het(integer) treatment(string) treatment2(string)
				
				probit `pro_vars' `treatment2' `controls' if `cond1'==`cond2', vce(cluster `clus_var')
					tempvar prob x x2 x3 x4
					predict `prob', xb
					gen `x' = (2*normprob(`prob'))-1
					gen `x2' = `x'^2
					gen `x3' = `x'^3
					gen `x4' = `x'^4			
				
				if `het'==0 {
					reg `command_vars' `treatment' `x' `x2' `x3' `x4' `controls' [pweight=`weight']  if `cond1'==`cond2', vce(cluster `clus_var')				
					}
				
				if `het'==1 {
					reg `command_vars' `treatment' `x' `x2' `x3' `x4' `controls'  if `cond1'==`cond2', vce(cluster `clus_var')
					}
			end
