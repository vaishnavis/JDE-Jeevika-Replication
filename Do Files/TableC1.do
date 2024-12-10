******************************************************************************************************************************************************************************************
** Relief from Usury: Impact of a Self-Help Group Lending Program in Rural India
** Vivian Hoffmann, Vijayendra Rao, Vaishnavi Surendra, Upamanyu Datta
**
** Replication Do-file
******************************************************************************************************************************************************************************************

** TABLE C1

		** Table C1 (unweighted)

		** ANCOVA
		est clear
		eststo clear
		local direct_vars "Bas_SHG_Part any_shg_loan2 any_informal_loan2 any_loan2 real_tot_shg_debt real_tot_informal_debt real_tot_out_debt int_rate primary"
				
		foreach var in `direct_vars' {
		eststo `var': reg EL_`var' status BL_`var' Imp_`var' $base_controls $primary_controls $missing_dummies tar_group if hh_data==1, vce(cluster panch_code)
			sum EL_`var' if status==0 & e(sample)
			estadd r(mean): `var'
		}
		
		esttab `direct_vars' using "$output/TableC1.csv", b(%10.2f) drop(BL_* _cons missing* strat_dummy* tar_group* Imp*) se ///
		scalars("N Observations" "N_clust Number of clusters" "r2 R-squared" "mean Mean") ///
		sfmt(%9.0f %9.0f %9.2f %9.2f) star(* 0.10 ** 0.05 *** 0.01) csv mtitles append title("ANCOVA Unweighted (se)")
		
		** Simple Diff
		est clear
		eststo clear
		local direct_vars "Bas_SHG_Part any_shg_loan any_informal_loan any_loan real_tot_shg_debt real_tot_informal_debt real_tot_out_debt int_rate"
				
		foreach var in `direct_vars' {
		eststo `var': reg EL_`var' status $base_controls if hh_data==1, vce(cluster panch_code)
			sum EL_`var' if status==0 & e(sample)
			estadd r(mean): `var'
		}
		
		esttab `direct_vars' using "$output/TableC1.csv", b(%10.2f) drop(strat_dummy*) se ///
		scalars("N Observations" "N_clust Number of clusters" "r2 R-squared" "mean Mean") ///
		sfmt(%9.0f %9.0f %9.2f %9.2f) star(* 0.10 ** 0.05 *** 0.01) csv mtitles append title("Simple Diff Unweighted (se)")		
		
		** Diff-in-Diff
		est clear
		eststo clear
		local direct_vars "Bas_SHG_Part any_shg_loan any_informal_loan any_loan real_tot_shg_debt real_tot_informal_debt real_tot_out_debt int_rate"
				
		foreach var in `direct_vars' {
		eststo `var': reghdfe `var' time##status if hh_data==2, absorb(panch_code) vce(cluster panch_code)	
		sum `var' if status==0 & time==0 & e(sample)
		estadd r(mean):`var'
		}

		esttab `direct_vars' using "$output/TableC1.csv", b(%10.2f) keep(1.time*1.status) se ///
		scalars("N Observations" "N_clust Number of clusters" r2 "mean Mean dep var omitted cat") ///
		sfmt(%9.0f %9.0f %9.2f %9.2f) star(* 0.10 ** 0.05 *** 0.01) csv noobs mtitles append title("Diff-in-Diff Unweighted(se)")	
