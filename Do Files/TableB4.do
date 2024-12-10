******************************************************************************************************************************************************************************************
** Relief from Usury: Impact of a Self-Help Group Lending Program in Rural India
** Vivian Hoffmann, Vijayendra Rao, Vaishnavi Surendra, Upamanyu Datta
**
** Replication Do-file
******************************************************************************************************************************************************************************************

** TABLE B4

		** Table B4.A: Downstream 2, Simple Difference
		est clear
		eststo clear
		local women "women_work_prop women_decision CA women_mobility daughter_edu_high"
		
		foreach var in `women' {

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

		esttab `women' using "$output/TableB4A.csv", b(%10.2f) keep(status) se ///
		scalars("coeff Effect of Jeevika for Gen HH" se1 p1 "coeff2 Effect of JEEViKA for SC/ST HH" se2 p2) ///
		sfmt(%9.2f %9.2f %9.2f %9.2f %9.2f %9.2f) star(* 0.10 ** 0.05 *** 0.01) csv noobs mtitles append title("Simple Diff (se)")
		
		** Table B4.B: Downstream 2, Diff-in-Diff
		est clear
		eststo clear
		local women "women_work_prop women_decision CA women_mobility daughter_edu_high"
		
		foreach var in `women' {
			
			eststo `var': reghdfe `var' time##status [pweight=wt] if hh_data==2,  absorb(panch_code) vce(cluster panch_code)
			
						  reghdfe `var' time##status##tar_group if hh_data==2, absorb(panch_code) vce(cluster panch_code)
							lincom 1.time#1.status
								estadd scalar coeff1 r(estimate): `var'
								estadd scalar se1 r(se): `var'
							test 1.time#1.status=0
								estadd scalar p1 r(p): `var'
							
							lincom 1.status#1.time + 1.status#1.time#1.tar_group
								estadd scalar coeff2 r(estimate): `var'
								estadd scalar se2 r(se): `var'
							test 1.status#1.time+1.status#1.time#1.tar_group=0
								estadd scalar p2 r(p):`var'
		}

		esttab `women' using "$output/TableB4B.csv", b(%10.2f) keep(1.time*1.status) se ///
		scalars("coeff1 Effect of Jeevika for Gen HH" se1 p1 "coeff2 Effect of JEEViKA for SC/ST HH" se2 p2) ///
		sfmt(%9.2f %9.2f %9.2f %9.2f %9.2f %9.2f) star(* 0.10 ** 0.05 *** 0.01) csv noobs mtitles append title("Diff-in-Diff (se)")
