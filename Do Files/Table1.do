** Relief from Usury: Impact of a Self-Help Group Lending Program in Rural India

** Table 1: Credit access, assets, and consumption, by caste

			global table1_a BL_any_debt BL_num_loans BL_real_tot_out_debt BL_real_tot_out_hcdebt BL_avg_int_rate1 BL_avg_inf_rate1 BL_interest_free 
			global table1_b BL_ecstat_wt BL_ecstat2_wt BL_ecstat3_wt BL_real_tot_cons_pa

		** Baseline differences in Caste, Mean levels
			est clear
			foreach var in $table1_a $table1_b {
			eststo `var': mean `var' if hh_data==1, over(tar_group) vce(cluster panch_code)
			}
			esttab using "$output/Table1_Means.csv", b(%10.2f) se csv mtitles append title("`var'") nostar
			
		** Baseline differences in Caste, Regressions
			eststo clear
			est clear
			foreach var in $table1_a $table1_b {	
			eststo `var': reg `var' tar_group if hh_data==1, vce(cluster panch_code)
			}
		
			esttab using "$output/Table1_Reg.csv", b(%10.2f) drop(_cons) se star(* 0.10 ** 0.05 *** 0.01) csv mtitles append title("`var'")
		
