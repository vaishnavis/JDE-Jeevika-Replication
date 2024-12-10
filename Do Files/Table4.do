******************************************************************************************************************************************************************************************
** Relief from Usury: Impact of a Self-Help Group Lending Program in Rural India
** Vivian Hoffmann, Vijayendra Rao, Vaishnavi Surendra, Upamanyu Datta
**
** Replication Do-file
******************************************************************************************************************************************************************************************

** TABLE 4
		
		** Table 4A
	
			est clear
			eststo clear
			local welfare "ecstat_wt ecstat2_wt ecstat3_wt entitle real_tot_cons_pa downstream1"
			
			foreach var in `welfare' {
			tempname mean Mean0Temp
			
			eststo `var': reg EL_`var' status BL_`var' Imp_`var' $primary_controls_wt $missing_dummies_wt tar_group $base_controls [pweight=wt] if hh_data==1, vce(cluster panch_code)
						  gen sample = e(sample)
						  
						  ritest status _b[status], reps(5000) cluster(panch_code) strata(strat_dum) force : `e(cmdline)'

						  matrix pvalues=r(p) 
						  mat colnames pvalues = treatment
						  est restore `var'  						  
							
						  estadd scalar pvalue_treat = pvalues[1,1]: `var'
						
			mean EL_`var' [pweight=wt] if status==0 & sample==1
				matrix `Mean0Temp' = e(b)
				scalar `mean' = `Mean0Temp'[1,1]
				estadd scalar wt_mean `mean': `var'
				
			cap drop sample
			}
			
			esttab `welfare' using "$output/Table4A.csv", b(%10.2f) keep(status) se ///
			scalars("N Observations" "N_clust Number of clusters" "r2 R-squared" "wt_mean Mean" "pvalue_treat p RI") ///
			sfmt(%9.0f %9.0f %9.2f %9.2f %9.3f) star(* 0.10 ** 0.05 *** 0.01) csv mtitles append title("Main Effects (se)")
			
		** Table 4B
			est clear
			eststo clear
			local welfare "ecstat ecstat2 ecstat3 entitle real_tot_cons_pa downstream1"
			
			foreach var in `welfare' {
			eststo `var': reg EL_`var' status##tar_group BL_`var' Imp_`var' $primary_controls $missing_dummies $base_controls if hh_data==1, vce(cluster panch_code)
						  gen sample = e(sample)
						
						ritest status  _b[1.status] (_b[1.status] + _b[1.status#1.tar_group]), reps(5000) cluster(panch_code) strata(strat_dum) force : `e(cmdline)'

						matrix pvalues=r(p)
						est restore `var'  						  
						
						estadd scalar pvalue_treat = pvalues[1,1]: `var'
						estadd scalar pvalue_tartreat = pvalues[1,2]: `var'
						
						lincom 1.status+1.status#1.tar_group
								estadd scalar LC r(estimate): `var'
								estadd scalar SE r(se): `var'
								test 1.status+1.status#1.tar_group=0
								estadd scalar p r(p): `var'
						lincom 1.tar_group+1.status#1.tar_group
								estadd scalar LC2 r(estimate): `var'
								estadd scalar SE2 r(se): `var'
								test 1.tar_group+1.status#1.tar_group=0
								estadd scalar p2 r(p): `var'
						sum EL_`var' if status==0 & tar_group==0 & sample==1
								estadd r(mean): `var'
				
						cap drop sample	
			}

			esttab `welfare' using "$output/Table4B.csv", b(%10.2f) keep(1.status 1.tar_group 1.status*1.tar_group) se ///
			scalars("LC Effect of JEEViKA for SC/ST HH" SE "p p-value" "LC2 Effect of SC/ST in presence of JEEViKA" SE2 "p2 p-value" ///
			"N Observations" "N_clust Number of clusters" "r2 R-Squared" "mean Mean dep var omitted cat"  "pvalue_treat p1" "pvalue_tartreat p2") ///
			sfmt(%9.2f %9.2f %9.2f %9.2f %9.2f %9.2f %9.0f %9.0f %9.2f %9.2f %9.3f %9.3f) star(* 0.10 ** 0.05 *** 0.01) csv mtitles append title("Caste Effects (se)")
			
