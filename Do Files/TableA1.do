** Relief from Usury: Impact of a Self-Help Group Lending Program in Rural India

** Table A1: Summary Statistics and Randomization Balance across Treatment Groups at Baseline

		global hh_char BL_tar_group1 BL_land BL_num_mem BL_head_gender /*household characteristics*/
		global shg_sav_debt BL_Bas_SHG_Part BL_savings_yes BL_real_tot_out_hcdebt BL_real_tot_out_debt BL_real_tot_informal_debt BL_real_tot_shg_debt /*shg, savings, debt*/
		global credit_mar BL_avg_int_rate_last1 BL_avg_inf_rate1 /*credit markets*/
		global wel_ind BL_ecstat_wt BL_ecstat2_wt BL_ecstat3_wt BL_real_tot_cons_pa BL_entitle /*welfare*/
		global wel_ind2 BL_ecstat BL_ecstat2 BL_ecstat3 BL_real_tot_cons_pa BL_entitle /*welfare*/
		global roles BL_women_work_prop BL_women_decision BL_CA BL_women_mobility BL_daughter_edu_high /*women's roles and capabilities*/

		global hh_char0 BL_land0 BL_num_mem0 BL_head_gender0 /*household characteristics*/
		global shg_sav_debt0 BL_Bas_SHG_Part0 BL_savings_yes0 BL_real_tot_out_hcdebt0 BL_real_tot_out_debt0 BL_real_tot_informal_debt0 BL_real_tot_shg_debt0 /*shg, savings, debt*/
		global credit_mar0 BL_avg_int_rate_last10 BL_avg_inf_rate10 /*credit markets*/
		global wel_ind0 BL_ecstat20 BL_ecstat0 BL_ecstat30 BL_real_tot_cons_pa0 BL_entitle0 /*welfare*/
		global roles0 BL_women_work_prop0 BL_women_decision0 BL_CA0 BL_women_mobility0 BL_daughter_edu_high0 /*women's roles and capabilities*/

		global hh_char1 BL_land1 BL_num_mem1 BL_head_gender1 /*household characteristics*/
		global shg_sav_debt1 BL_Bas_SHG_Part1 BL_savings_yes1 BL_real_tot_out_hcdebt1 BL_real_tot_out_debt1 BL_real_tot_informal_debt1 BL_real_tot_shg_debt1 /*shg, savings, debt*/
		global credit_mar1 BL_avg_int_rate_last11 BL_avg_inf_rate11 /*credit markets*/
		global wel_ind1 BL_ecstat21 BL_ecstat1 BL_ecstat31 BL_real_tot_cons_pa1 BL_entitle1 /*welfare*/
		global roles1 BL_women_work_prop1 BL_women_decision1 BL_CA1 BL_women_mobility1 BL_daughter_edu_high1 /*women's roles and capabilities*/
		
		** HH level data balance
		est clear
		eststo clear
		
		foreach var in $hh_char $shg_sav_debt $credit_mar $wel_ind $roles BL_attrition {
			eststo `var': reg zbl_n_`var' status strat_dummy1-strat_dummy85 [pweight=wt] if hh_data==1, vce(cluster panch_code) noconstant
						  
						  ritest status _b[status], reps(5000) cluster(panch_code) strata(strat_dum) force : `e(cmdline)'
						  
						  matrix pvalues=r(p)
						  mat colnames pvalues = treatment
						  est restore `var'  						  
							
						  estadd scalar pvalue_treat = pvalues[1,1]: `var'
						  
				}
				
			esttab $hh_char $shg_sav_debt $credit_mar $wel_ind $roles BL_attrition using "$output/TableA1_all.csv", b(%10.2f) keep(status) se ///
			scalars(N r2 SE "p p-value" "pvalue_treat p-val RI") sfmt(%9.2f %9.2f %9.2f %9.2f %9.3f) ///
			star(* 0.10 ** 0.05 *** 0.01) csv mtitles append title("HH Data Balance")
				
		** Caste-wise balance
		est clear
		eststo clear
		
		foreach var in BL_land BL_num_mem BL_head_gender $shg_sav_debt $credit_mar $wel_ind2 $roles BL_attrition {
			eststo `var'0: reg zbl_n0_`var' status strat_dummy1-strat_dummy85 if hh_data==1 & tar_group==0, vce(cluster panch_code) noconstant
						  
						  ritest status _b[status], reps(5000) cluster(panch_code) strata(strat_dum) force : `e(cmdline)'
						  
						  matrix pvalues=r(p)
						  mat colnames pvalues = treatment
						  est restore `var'0
							
						  estadd scalar pvalue_treat = pvalues[1,1]: `var'0
						  
			eststo `var'1: reg zbl_n1_`var' status strat_dummy1-strat_dummy85 if hh_data==1 & tar_group==1, vce(cluster panch_code) noconstant
						  
						  ritest status _b[status], reps(5000) cluster(panch_code) strata(strat_dum) force : `e(cmdline)'
						  
						  matrix pvalues=r(p)
						  mat colnames pvalues = treatment
						  est restore `var'1
							
						  estadd scalar pvalue_treat = pvalues[1,1]: `var'1
						  
				}
							
			esttab $hh_char0 $shg_sav_debt0 $credit_mar0 $wel_ind0 $roles0 BL_attrition0 using "$output/TableA1_0.csv", b(%10.2f) keep(status) se ///
			scalars(N r2 SE "p p-value" "pvalue_treat p-val RI") sfmt(%9.2f %9.2f %9.2f %9.2f %9.3f) ///
			star(* 0.10 ** 0.05 *** 0.01) csv mtitles append title("HH Data Balance")

			esttab $hh_char1 $shg_sav_debt1 $credit_mar1 $wel_ind1 $roles1 BL_attrition1 using "$output/TableA1_1.csv", b(%10.2f) keep(status) se ///
			scalars(N r2 SE "p p-value" "pvalue_treat p-val RI") sfmt(%9.2f %9.2f %9.2f %9.2f %9.3f) ///
			star(* 0.10 ** 0.05 *** 0.01) csv mtitles append title("HH Data Balance")
			
		** Means
		est clear
		eststo clear
		foreach var in $hh_char $shg_sav_debt $credit_mar $wel_ind $roles BL_attrition {
			eststo `var': mean `var' [pweight=wt] if hh_data==1, over(status)
		}

			esttab $hh_char $shg_sav_debt $credit_mar $wel_ind $roles BL_attrition using "$output/TableA1_Means.csv", keep() csv not nostar ///
			sfmt(%9.2f %9.2f %9.2f %9.2f %9.2f %9.2f %9.2f %9.2f %9.2f %9.2f %9.2f %9.2f %9.2f %9.2f %9.2f %9.2f %9.2f %9.2f %9.2f %9.2f %9.2f %9.2f %9.2f) ///
			mtitles append title("Baseline Means")

		** FGD balance
		est clear
		eststo clear
		foreach var in BL_informal_rate BL_number_informal ///
					   BL_avg_age BL_total BL_share_men BL_share_women BL_share_scst BL_share_obc BL_share_ebc BL_share_gen BL_share_scstwom ///
					   EL_avg_age EL_total EL_share_men EL_share_women EL_share_scst EL_share_obc EL_share_ebc EL_share_gen EL_share_scstwom {
			eststo `var': reg zbl_n_`var' status strat_dummy1-strat_dummy85 if hh_data==0, vce(cluster panch_code) noconstant
						  
						  ritest status _b[status], reps(5000) cluster(panch_code) strata(strat_dum) force : `e(cmdline)'
						  
						  matrix pvalues=r(p)
						  mat colnames pvalues = treatment
						  est restore `var'
							
						  estadd scalar pvalue_treat = pvalues[1,1]: `var'
			}

		esttab using "$output/TableA1_FGD.csv", b(%10.2f) keep(status) se ///
		scalars(N r2 SE "p p-value" "pvalue_treat p-val RI") sfmt(%9.2f %9.2f %9.2f %9.2f %9.3f) ///
		star(* 0.10 ** 0.05 *** 0.01) csv mtitles append title("FGD Data Balance")

		foreach var in BL_share_men BL_share_women BL_share_scst BL_share_obc BL_share_ebc BL_share_gen BL_share_scstwom ///
		EL_share_men EL_share_women EL_share_scst EL_share_obc EL_share_ebc EL_share_gen EL_share_scstwom {
			replace `var' = `var'*100
		}
		
		** FGD Means
		est clear
		estpost tabstat BL_informal_rate BL_number_informal ///
						BL_avg_age BL_total BL_share_men BL_share_women BL_share_scst BL_share_obc BL_share_ebc BL_share_gen BL_share_scstwom ///
						EL_avg_age EL_total EL_share_men EL_share_women EL_share_scst EL_share_obc EL_share_ebc EL_share_gen EL_share_scstwom ///		
						if hh_data==0, by(status) statistics(mean) columns(statistics)
		esttab using "$output/TableA1_Means2.csv", main(mean) b(%10.2f) p unstack append title("FGD Means")

