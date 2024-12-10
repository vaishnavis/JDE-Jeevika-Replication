******************************************************************************************************************************************************************************************
** Relief from Usury: Impact of a Self-Help Group Lending Program in Rural India
** Vivian Hoffmann, Vijayendra Rao, Vaishnavi Surendra, Upamanyu Datta
**
** Replication Do-file
******************************************************************************************************************************************************************************************

** TABLE B2
		
		cap mat drop boot_scalars boot_scalars2
		cap drop prob x x2 x3 x4
		
		probit EL_any_informal_loan EL_Health_Incident status BL_any_informal_loan tar_group $primary_controls_wt $missing_dummies_wt $base_controls if hh_data==1, vce(cluster panch_code)
			   predict prob, xb
			   gen x = (2*normprob(prob))-1
			   gen x2 = x^2
			   gen x3 = x^3
			   gen x4 = x^4			
			
		** Table B2.A
		est clear
		eststo clear
		local indirect_vars "hhinformal_rate wt_inf_rate"
		local indirect_fgd "informal_rate number_informal"
		
		foreach var in hhinformal_rate wt_inf_rate {
		eststo `var': reg EL_`var' status $base_controls $primary_controls_wt $missing_dummies_wt tar_group [pweight=wt] if hh_data==1, vce(cluster panch_code)
		
					  reg EL_`var' status##tar_group $base_controls $primary_controls $missing_dummies if hh_data==1, vce(cluster panch_code)
						lincom 1.status
								estadd scalar coeff r(estimate): `var'
								estadd scalar se1 r(se): `var'
						test 1.status=0
								estadd scalar p1 r(p): `var'
						
						lincom 1.status+1.status#1.tar_group
								estadd scalar coeff2 r(estimate): `var'
								estadd scalar se2 r(se): `var'
						test 1.status+1.status#1.tar_group=0
								estadd scalar p2 r(p) : `var'
		}

		foreach var in hhinformal_rate wt_inf_rate {			
		eststo `var'2: bootstrap _b, cluster(panch_code) idcluster(newid) strata(strat_dum) seed(101) rep(5000) force: reg EL_`var' status x x2 x3 x4 $primary_controls_wt $missing_dummies_wt tar_group $base_controls [pweight=wt] if hh_data==1, vce(cluster panch_code)
		
					   bootstrap _b r(LC) r(LC2), cluster(panch_code) idcluster(newid) strata(strat_dum) seed(101) rep(5000) force: het_effects_boot, outcome(EL_`var') het_vars(status##tar_group x x2 x3 x4 $primary_controls_wt $missing_dummies_wt $base_controls ) cond1(hh_data) cond2(1) clus_var(panch_code) comb1(_b[1.status]) comb2(_b[1.status]+_b[1.status#1.tar_group])
 
						  matrix boot_scalars = r(table)
						  est restore `var'2
						   
						  estadd scalar coeff = boot_scalars[1, 128]: `var'2
						  estadd scalar se1 = boot_scalars[2 128]: `var'2
						  estadd scalar p1= boot_scalars[4, 128]: `var'2
						  estadd scalar coeff2 = boot_scalars[1, 129]: `var'2 
						  estadd scalar se2 = boot_scalars[2, 129]: `var'2
						  estadd scalar p2 = boot_scalars[4, 129]: `var'2		
		}		
		
		foreach var in `indirect_fgd' {
			eststo `var': reg EL_`var' status $FGD_cont $base_controls if hh_data==0, vce(cluster panch_code)
		}

		esttab `indirect_vars' hhinformal_rate2 wt_inf_rate2 `indirect_fgd' using "$output/TableB2A.csv", b(%10.2f) keep(status) se ///
		scalars("coeff Effect of Jeevika for Gen HH" se1 p1 "coeff2 Effect of JEEViKA for SC/ST HH" se2 p2) ///
		sfmt(%9.2f %9.2f %9.2f %9.2f %9.2f %9.2f) star(* 0.10 ** 0.05 *** 0.01) csv noobs mtitles append title("Simple Diff (se)")
		
		
		** Table B2.B
		est clear
		eststo clear
		local indirect_vars "hhinformal_rate wt_inf_rate"
		local indirect_fgd "informal_rate number_informal"
		
		foreach var in `indirect_vars' {

			eststo `var': reghdfe `var' time##status [pweight=wt] if hh_data==2, absorb(panch_code) vce(cluster panch_code)
			
						  reghdfe `var' time##status##tar_group if hh_data==2, absorb(panch_code) vce(cluster panch_code)
							lincom 1.time#1.status
								estadd scalar LC r(estimate): `var'
								estadd scalar SE r(se): `var'
							test 1.time#1.status=0
								estadd scalar p1 r(p): `var'
							
							lincom 1.status#1.time + 1.status#1.time#1.tar_group
								estadd scalar LC2 r(estimate): `var'
								estadd scalar SE2 r(se): `var'
							test 1.status#1.time+1.status#1.time#1.tar_group=0
								estadd scalar p2 r(p):`var'
		}
		
			cap drop prob x x2 x3 x4
			
			probit any_informal_loan status##time Health_Incident i.panch_code if hh_data==2, vce(cluster panch_code)
					predict prob, xb
					gen x = (2*normprob(prob))-1
					gen x2 = x^2
					gen x3 = x^3
					gen x4 = x^4			

		foreach var in hhinformal_rate wt_inf_rate {

			eststo `var'2: bootstrap _b, cluster(panch_code) idcluster(newid) strata(strat_dum) seed(101) rep(5000) force: reghdfe `var' time##status x x2 x3 x4 [pweight=wt] if hh_data==2, absorb(panch_code) vce(cluster panch_code)

					       bootstrap _b r(LC) r(LC2), cluster(panch_code) idcluster(newid) strata(strat_dum) seed(101) rep(5000) force: DiD_boot, outcome(`var') het_vars(time##status##tar_group x x2 x3 x4) cond1(hh_data) cond2(2) clus_var(panch_code) comb1(_b[1.time#1.status]) comb2(_b[1.status#1.time] + _b[1.status#1.time#1.tar_group])
						  
						   matrix boot_scalars2 = r(table)
						   est restore `var'2

						   estadd scalar LC = boot_scalars2[1, 32]: `var'2
						   estadd scalar SE = boot_scalars2[2, 32]: `var'2
						   estadd scalar p1 = boot_scalars2[4, 32]: `var'2
						   estadd scalar LC2 = boot_scalars2[1, 33]: `var'2 
						   estadd scalar SE2 = boot_scalars2[2, 33]: `var'2
						   estadd scalar p2 = boot_scalars2[4, 33]: `var'2
						   						   
		}		
		
		foreach var in `indirect_fgd' {
			eststo `var': reghdfe `var' time##status if hh_data==3, absorb(panch_code) vce(cluster panch_code)
		}		

		esttab `indirect_vars' hhinformal_rate2 wt_inf_rate2 `indirect_fgd' using "$output/TableB2B.csv", b(%10.2f) keep(1.time*1.status) se ///
		scalars("LC Effect of Jeevika for Gen HH" SE p1 "LC2 Effect of JEEViKA for SC/ST HH" SE2 p2) ///
		sfmt(%9.2f %9.2f %9.2f %9.2f %9.2f %9.2f) star(* 0.10 ** 0.05 *** 0.01) csv noobs mtitles append title("Diff-in-Diff (se)")
