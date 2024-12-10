******************************************************************************************************************************************************************************************
** Relief from Usury: Impact of a Self-Help Group Lending Program in Rural India
** Vivian Hoffmann, Vijayendra Rao, Vaishnavi Surendra, Upamanyu Datta
**
** Replication Do-file
******************************************************************************************************************************************************************************************

		clear
		clear matrix
		clear mata

		set maxvar 10000

		if "`c(username)'" == "<change username here>" {
		global directory "<include director here>"
		global path "JDE_Relief from Usury_Replication/Data"
		global dofiles "JDE_Relief from Usury_Replication/Do Files"
		global output "JDE_Relief from Usury_Replication/Output" 
		}
		
		** Set Directory
		cd "$directory"
		
		log using "$output/tables_log.smcl", replace
		
		
******************************************************************************************************************************************************************************************
** Set up datasets

		** hh data for ancova
		use "$path/HH_Wide_Panel_JDE.dta", clear
		gen hh_data=1
		
		** village data for ancova
		append using "$path/Vill_Wide_Panel_JDE.dta"
		replace hh_data=0 if mi(hh_data)
		
		** pooled hh data
		append using "$path/HH_Long_Panel_JDE.dta"
		replace hh_data=2 if mi(hh_data)
		
		** pooled village data
		append using "$path/Vill_Long_Panel_JDE.dta"
		replace hh_data=3 if mi(hh_data)
		
		** loan level data
		append using "$path/Loans_JDE.dta"
		replace hh_data = 4 if mi(hh_data)
		
			** controls
			global base_controls strat_dummy2-strat_dummy85

			global primary_controls_wt BL_Bas_SHG_Part_miss BL_savings_yes_miss BL_real_tot_out_hcdebt_miss ///
									BL_avg_int_rate_last1_miss BL_ecstat2_wt_miss BL_ecstat_wt_miss BL_ecstat3_wt_miss BL_real_tot_cons_pa_miss ///
									BL_entitle_miss BL_women_work_prop_miss BL_women_decision_miss BL_CA_miss ///
									BL_daughter_edu_high_miss BL_women_mobility_miss BL_landless_miss
									
			global missing_dummies_wt missing_BL_Bas_SHG_Part missing_BL_savings_yes missing_BL_real_tot_out_hcdebt ///
									missing_BL_avg_int_rate_last1 ///
									missing_BL_ecstat2_wt missing_BL_ecstat_wt missing_BL_ecstat3_wt missing_BL_real_tot_cons_pa ///
									missing_BL_entitle missing_BL_women_work_prop missing_BL_women_decision missing_BL_CA ///
									missing_BL_daughter_edu_high missing_BL_women_mobility missing_BL_landless

			global primary_controls BL_Bas_SHG_Part_miss BL_savings_yes_miss BL_real_tot_out_hcdebt_miss ///
									BL_avg_int_rate_last1_miss BL_ecstat2_miss BL_ecstat_miss BL_ecstat3_miss BL_real_tot_cons_pa_miss ///
									BL_entitle_miss BL_women_work_prop_miss BL_women_decision_miss BL_CA_miss ///
									BL_daughter_edu_high_miss BL_women_mobility_miss BL_landless_miss
									
			global missing_dummies missing_BL_Bas_SHG_Part missing_BL_savings_yes missing_BL_real_tot_out_hcdebt ///
									missing_BL_avg_int_rate_last1 ///
									missing_BL_ecstat2 missing_BL_ecstat missing_BL_ecstat3 missing_BL_real_tot_cons_pa ///
									missing_BL_entitle missing_BL_women_work_prop missing_BL_women_decision missing_BL_CA ///
									missing_BL_daughter_edu_high missing_BL_women_mobility missing_BL_landless
									
		** village level controls
			global FGD_cont BL_vill_SHG_share BL_vill_savings_share ///
							BL_vill_avg_int BL_vill_ecstat2 BL_vill_ecstat BL_vill_ecstat3 BL_vill_cons_pa BL_vill_entitle_share ///
							BL_vill_women_prop BL_vill_decision_share BL_vill_CA_share BL_vill_asp_share BL_vill_mobility ///
							m_BL_scst_share BL_no_scst
		

		foreach var in Bas_SHG_Part any_shg_loan2 any_informal_loan2 any_loan2 entitle women_work_prop ///
						women_decision CA women_mobility daughter_edu_high {
			replace `var' = `var'*100
			replace EL_`var' = EL_`var'*100
			replace BL_`var' = BL_`var'*100
		}
		
******************************************************************************************************************************************************************************************
** Define wrappers/programs

	do "$dofiles/Selection_Correction_Het_Wrapper.do"
	do "$dofiles/Selection_Correction_Wrapper.do"
	do "$dofiles/DiD_Bootstrap.do"
	
******************************************************************************************************************************************************************************************

** Baseline Balance
	do "$dofiles/TableA1.do"
	
** Caste-differences at Baseline
	do "$dofiles/Table1.do"
	
** Main Regression Results
	do "$dofiles/Table2.do"
	do "$dofiles/Table3.do"
	do "$dofiles/Table4.do"	
	do "$dofiles/Table5.do"		
	
** Appendix B Tables 
	do "$dofiles/TableB1.do"
	do "$dofiles/TableB2.do"
	do "$dofiles/TableB3.do"
	do "$dofiles/TableB4.do"

** Appendix C Tables
	do "$dofiles/TableC1.do"
	do "$dofiles/TableC2.do"
	do "$dofiles/TableC3.do"
	do "$dofiles/TableC4.do"
		
** RW p-vals Family Indices
	do "$dofiles/RWpvals.do"
	
** Instrument Validity
	do "$dofiles/Instrument Validity.do"

** Interest Rate Variation
	do "$dofiles/Variation in Interest Rates.do"

******************************************************************************************************************************************************************************************

	clear
	log close
