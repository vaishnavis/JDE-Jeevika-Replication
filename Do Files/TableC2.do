******************************************************************************************************************************************************************************************
** Relief from Usury: Impact of a Self-Help Group Lending Program in Rural India
** Vivian Hoffmann, Vijayendra Rao, Vaishnavi Surendra, Upamanyu Datta
**
** Replication Do-file
******************************************************************************************************************************************************************************************

** TABLE C2
	
		** Table C2 (unweighted)

		cap drop prob x x2 x3 x4
		
		probit EL_any_informal_loan status BL_any_informal_loan tar_group EL_Health_Incident $primary_controls_wt $missing_dummies_wt $base_controls if hh_data==1, vce(cluster panch_code)
				predict prob, xb
				gen x = (2*normprob(prob))-1
				gen x2 = x^2
				gen x3 = x^3
				gen x4 = x^4			
		
		
		** ANCOVA
		est clear
		eststo clear
		local indirect_vars "hhinformal_rate wt_inf_rate"
				
		foreach var in `indirect_vars' {
		eststo `var': reg EL_`var' status BL_`var' Imp_`var' $base_controls $primary_controls $missing_dummies tar_group if hh_data==1, vce(cluster panch_code)
			sum EL_`var' if status==0 & e(sample)
			estadd r(mean): `var'
			
		eststo `var'2: bootstrap _b, cluster(panch_code) idcluster(newid) strata(strat_dum) seed(101) rep(5000) force: reg EL_`var' status BL_`var' Imp_`var' x x2 x3 x4 $primary_controls_wt $missing_dummies_wt tar_group $base_controls if hh_data==1, vce(cluster panch_code)

			sum EL_`var' if status==0 & e(sample)
			estadd r(mean): `var'2
		
		}
		
		esttab `indirect_vars' hhinformal_rate2 wt_inf_rate2 using "$output/TableC2.csv", b(%10.2f) keep(status) se ///
		scalars("N Observations" "N_clust Number of clusters" "r2 R-squared" "mean Mean") ///
		sfmt(%9.0f %9.0f %9.2f %9.2f) star(* 0.10 ** 0.05 *** 0.01) csv mtitles append title("ANCOVA Unweighted (se)")
		
		cap drop prob x x2 x3 x4
		
		probit EL_any_informal_loan status EL_Health_Incident $base_controls if hh_data==1, vce(cluster panch_code)
				predict prob, xb
				gen x = (2*normprob(prob))-1
				gen x2 = x^2
				gen x3 = x^3
				gen x4 = x^4			
				
		** Simple Diff
		est clear
		eststo clear
		local indirect_vars "hhinformal_rate wt_inf_rate"
				
		foreach var in `indirect_vars' {
		eststo `var': reg EL_`var' status $base_controls if hh_data==1, vce(cluster panch_code)
			sum EL_`var' if status==0 & e(sample)
			estadd r(mean): `var'
			
		eststo `var'2: bootstrap _b, cluster(panch_code) idcluster(newid) strata(strat_dum) seed(101) rep(5000) force: reg EL_`var' status x x2 x3 x4 $base_controls if hh_data==1, vce(cluster panch_code)

			sum EL_`var' if status==0 & e(sample)
			estadd r(mean): `var'2
			
		}
		
		esttab `indirect_vars' hhinformal_rate2 wt_inf_rate2 using "$output/TableC2.csv", b(%10.2f) keep(status) se ///
		scalars("N Observations" "N_clust Number of clusters" "r2 R-squared" "mean Mean") ///
		sfmt(%9.0f %9.0f %9.2f %9.2f) star(* 0.10 ** 0.05 *** 0.01) csv mtitles append title("Simple Diff Unweighted (se)")		
		
		cap drop prob x x2 x3 x4
		
		probit any_informal_loan status##time Health_Incident i.panch_code if hh_data==2, vce(cluster panch_code)
				predict prob, xb
				gen x = (2*normprob(prob))-1
				gen x2 = x^2
				gen x3 = x^3
				gen x4 = x^4			
		
		** Diff-in-Diff
		est clear
		eststo clear
		local indirect_vars "hhinformal_rate wt_inf_rate"
				
		foreach var in `indirect_vars' {
		eststo `var': reghdfe `var' time##status if hh_data==2, absorb(panch_code) vce(cluster panch_code)	
		sum `var' if status==0 & time==0 & e(sample)
		estadd r(mean):`var'
		
		eststo `var'2: bootstrap _b, cluster(panch_code) idcluster(newid) strata(strat_dum) seed(101) rep(5000) force: reghdfe `var' status##time x x2 x3 x4 if hh_data==2, absorb(panch_code) vce(cluster panch_code)

		sum `var' if status==0 & time==0 & e(sample)
		estadd r(mean): `var'2
		
		}

		esttab `indirect_vars' hhinformal_rate2 wt_inf_rate2 using "$output/TableC2.csv", b(%10.2f) keep(1.time*1.status) se ///
		scalars("N Observations" "N_clust Number of clusters" r2 "mean Mean dep var omitted cat") ///
		sfmt(%9.0f %9.0f %9.2f %9.2f) star(* 0.10 ** 0.05 *** 0.01) csv noobs mtitles append title("Diff-in-Diff Unweighted(se)")		
		
