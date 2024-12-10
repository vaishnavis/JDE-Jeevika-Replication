******************************************************************************************************************************************************************************************
** Relief from Usury: Impact of a Self-Help Group Lending Program in Rural India
** Vivian Hoffmann, Vijayendra Rao, Vaishnavi Surendra, Upamanyu Datta
**
** Replication Do-file
******************************************************************************************************************************************************************************************

** TABLE 3
		
		** Table 3A
			est clear
			eststo clear
			
			local indirect_fgd "informal_rate number_informal fgd_index"
			
			** Informal Interest Rate
			foreach var in hhinformal_rate wt_inf_rate {
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
			
			** Selection Corrected Regression I			
			tempname mean Mean0Temp
			
			eststo select: probit EL_any_informal_loan EL_Health_Incident status BL_any_informal_loan tar_group $primary_controls_wt $missing_dummies_wt $base_controls if hh_data==1, vce(cluster panch_code)
					predict prob, xb
					gen x = (2*normprob(prob))-1
					gen x2 = x^2
					gen x3 = x^3
					gen x4 = x^4			
			
			foreach var in hhinformal_rate wt_inf_rate {
			
			eststo `var'2: bootstrap _b, cluster(panch_code) idcluster(newid) strata(strat_dum) seed(101) rep(5000) force: reg EL_`var' status BL_`var' Imp_`var' x x2 x3 x4 $primary_controls_wt $missing_dummies_wt tar_group $base_controls [pweight=wt] if hh_data==1, vce(cluster panch_code)
						  gen sample = e(sample)
						  
						  ritest status _b[status], reps(5000) cluster(panch_code) strata(strat_dum) force : selection_wrapper , command_vars(EL_`var' BL_`var' Imp_`var') controls($primary_controls_wt $missing_dummies_wt tar_group $base_controls) pro_vars(EL_any_informal_loan BL_any_informal_loan EL_Health_Incident) clus_var(panch_code) cond1(hh_data) cond2(1)  het(0) treatment(status) weight(wt) treatment2(status)
						  
						  matrix pvalues=r(p)
						  mat colnames pvalues = treatment
						  est restore `var'2
							
						  estadd scalar pvalue_treat = pvalues[1,1]: `var'2
						
			mean EL_`var' [pweight=wt] if status==0 & sample==1
				matrix `Mean0Temp' = e(b)
				scalar `mean' = `Mean0Temp'[1,1]
				estadd scalar wt_mean `mean': `var'2
				
			cap drop sample
			}
			
			** FGD rate and lenders
			eststo informal_rate: reg EL_informal_rate status m_BL_informal_rate BL_no_informal $FGD_cont $base_controls if hh_data==0, vce(cluster panch_code)
								  gen sample = e(sample)
								  
								  ritest status _b[status], reps(5000) cluster(panch_code) strata(strat_dum) force : `e(cmdline)'
								  
								  matrix pvalues=r(p)
								  mat colnames pvalues = treatment
								  est restore `var'  						  
									
								  estadd scalar pvalue_treat = pvalues[1,1]: informal_rate
						
								  sum EL_informal_rate if status==0 & sample==1
								  estadd scalar wt_mean r(mean): informal_rate

								  drop sample
								  
			eststo number_informal: reg EL_number_informal BL_number_informal status $FGD_cont $base_controls if hh_data==0, vce(cluster panch_code)
								  gen sample = e(sample)
								  
								  ritest status _b[status], reps(5000) cluster(panch_code) strata(strat_dum) force : `e(cmdline)'
								  
								  matrix pvalues=r(p)
								  mat colnames pvalues = treatment
								  est restore `var'  						  
									
								  estadd scalar pvalue_treat = pvalues[1,1]: number_informal
						
								  sum EL_number_informal if status==0 & sample==1
								  estadd scalar wt_mean r(mean): number_informal

								  drop sample

			eststo fgd_index: reg EL_fgd_index BL_fgd_index status $FGD_cont $base_controls if hh_data==0, vce(cluster panch_code)
								  gen sample = e(sample)
								  
								  ritest status _b[status], reps(5000) cluster(panch_code) strata(strat_dum) force : `e(cmdline)'
								  
								  matrix pvalues=r(p)
								  mat colnames pvalues = treatment
								  est restore `var'  						  
									
								  estadd scalar pvalue_treat = pvalues[1,1]: fgd_index
						
								  sum EL_fgd_index if status==0 & sample==1
								  estadd scalar wt_mean r(mean): fgd_index

								  drop sample			
			
			esttab hhinformal_rate wt_inf_rate hhinformal_rate2 wt_inf_rate2 `indirect_fgd' using "$output/Table3A.csv", b(%10.2f) keep(status) se /// 
			scalars("N Observations" "N_clust Number of clusters" "r2 R-squared" "wt_mean Mean" "pvalue_treat p RI") ///
			sfmt(%9.0f %9.0f %9.2f %9.2f %9.3f) star(* 0.10 ** 0.05 *** 0.01) csv mtitles append title("Main Effects (se)")							

			esttab select using "$output/selection.csv", b(%10.2f) drop(strat* missing*) se /// 
			scalars("N Observations" "N_clust Number of clusters" "r2_p Pseudo R-squared" "chi2 chi-sq" "p p-val") ///
			sfmt(%9.0f %9.0f %9.2f %9.2f %9.3f) star(* 0.10 ** 0.05 *** 0.01) csv mtitles append title("Selection Equation")							
			
		** Table 3B
			est clear
			eststo clear
			local indirect_vars "hhinformal_rate wt_inf_rate"
			
			foreach var in `indirect_vars' {
			
			eststo `var': reg EL_`var' status##tar_group BL_`var' Imp_`var' $base_controls $primary_controls $missing_dummies if hh_data==1, vce(cluster panch_code)
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
								estadd scalar p1 r(p): `var'
						lincom 1.tar_group+1.status#1.tar_group
								estadd scalar LC2 r(estimate): `var'
								estadd scalar SE2 r(se): `var'
								test 1.tar_group+1.status#1.tar_group=0
								estadd scalar p2 r(p): `var'
						sum EL_hhinformal_rate if status==0 & tar_group==0 & sample==1
								estadd r(mean): `var'
				
						drop sample
			}
			
			tempname mean Mean0Temp
			
			foreach var in `indirect_vars' {
						
			eststo `var'2: bootstrap _b r(LC) r(LC2), cluster(panch_code) idcluster(newid) strata(strat_dum) seed(101) rep(5000) force: het_effects_boot , outcome(EL_`var') het_vars(status##tar_group BL_`var' Imp_`var' x x2 x3 x4 $primary_controls_wt $missing_dummies_wt $base_controls) cond1(hh_data) cond2(1) clus_var(panch_code) comb1(_b[1.status]+_b[1.status#1.tar_group]) comb2(_b[1.tar_group]+_b[1.status#1.tar_group])
						  
						  matrix boot_scalars = r(table)
						  estadd scalar LC = boot_scalars[1, 130]: `var'2
						  estadd scalar SE = boot_scalars[2, 130]: `var'2
						  estadd scalar p1 = boot_scalars[4, 130]: `var'2
						  estadd scalar LC2 = boot_scalars[1, 131]: `var'2 
						  estadd scalar SE2 = boot_scalars[2, 131]: `var'2
						  estadd scalar p2 = boot_scalars[4, 131]: `var'2
						  
						  reg EL_`var' status##tar_group BL_`var' Imp_`var' x x2 x3 x4 $base_controls $primary_controls $missing_dummies if hh_data==1, vce(cluster panch_code)
						  
						  scalar r22=e(r2)
						  est restore `var'2
						  estadd scalar r2 = r22: `var'2
						  
						  ritest status  _b[1.status] (_b[1.status] + _b[1.status#1.tar_group]), reps(5000) cluster(panch_code) strata(strat_dum) force : selection_wrapper , command_vars(EL_`var' BL_`var' Imp_`var') controls($primary_controls_wt $missing_dummies_wt tar_group $base_controls) pro_vars(EL_any_informal_loan BL_any_informal_loan EL_Health_Incident) clus_var(panch_code) cond1(hh_data) cond2(1)  het(1) treatment(status##tar_group) weight(wt) treatment2(status)
						  
						  matrix pvalues=r(p)
						  est restore `var'2
						
						  estadd scalar pvalue_treat = pvalues[1,1]: `var'2
						  estadd scalar pvalue_tartreat = pvalues[1,2]: `var'2
						
						  sum EL_`var' if status==0 & tar_group==0 & e(sample)						  
						  estadd r(mean): `var'2
						  
			}
			
			esttab hhinformal_rate wt_inf_rate hhinformal_rate2 wt_inf_rate2 using "$output/Table3B.csv", b(%10.2f) keep(1.status 1.tar_group 1.status*1.tar_group) se ///
			scalars("LC Effect of JEEViKA for SC/ST HH" SE "p1 p-value" "LC2 Effect of SC/ST in presence of JEEViKA" SE2 "p2 p-value" ///
			"N Observations" "N_clust Number of clusters" "r2 R-Squared" "mean Mean dep var omitted cat" ///
			"pvalue_treat p1" "pvalue_tartreat p2") ///
			sfmt(%9.2f %9.2f %9.2f %9.2f %9.2f %9.2f %9.0f %9.0f %9.2f %9.2f %9.3f %9.3f) star(* 0.10 ** 0.05 *** 0.01) csv mtitles append title("Caste Effects (se)")		
