******************************************************************************************************************************************************************************************
** Relief from Usury: Impact of a Self-Help Group Lending Program in Rural India
** Vivian Hoffmann, Vijayendra Rao, Vaishnavi Surendra, Upamanyu Datta
**
** Replication Do-file
******************************************************************************************************************************************************************************************

** RW step-up method

** Bootstrap replicates

foreach var in primary downstream1 downstream2{
bootstrap _b[status] _se[status], cluster(panch_code) idcluster(newid) strata(strat_dum) seed(101) rep(5000) force saving("$path/reps_`var'.dta"): reg EL_`var' status BL_`var' Imp_`var' $primary_controls_wt $missing_dummies_wt tar_group $base_controls [pweight=wt] if hh_data==1, vce(cluster panch_code)
bootstrap _b[1.status#1.tar_group] _se[1.status#1.tar_group], cluster(panch_code) idcluster(newid) strata(strat_dum) seed(101) rep(5000) force saving("$path/reps_`var'1.dta"): reg EL_`var' status##tar_group BL_`var' Imp_`var' $primary_controls $missing_dummies $base_controls if hh_data==1, vce(cluster panch_code)
}

bootstrap _b[status] _se[status], cluster(panch_code) idcluster(newid) strata(strat_dum) seed(101) rep(5000) force saving("$path/reps_fgd_index.dta"): reg EL_fgd_index BL_fgd_index status $FGD_cont $base_controls if hh_data==0, vce(cluster panch_code)
	
	cap drop prob x x2 x3 x4
	probit EL_any_informal_loan status BL_any_informal_loan tar_group EL_Health_Incident $primary_controls_wt $missing_dummies_wt $base_controls if hh_data==1, vce(cluster panch_code)
		predict prob, xb
		gen x = (2*normprob(prob))-1
		gen x2 = x^2
		gen x3 = x^3
		gen x4 = x^4			

bootstrap _b[1.status#1.tar_group] _se[1.status#1.tar_group], cluster(panch_code) idcluster(newid) strata(strat_dum) seed(101) rep(5000) force saving("$path/reps_wt_inf_rate1.dta"): reg EL_wt_inf_rate status##tar_group BL_wt_inf_rate Imp_wt_inf_rate x x2 x3 x4 $base_controls $primary_controls $missing_dummies if hh_data==1, vce(cluster panch_code)

		** Merge all files
		use "$path/reps_primary.dta", clear
		ren _bs_1 primary
		ren _bs_2 primary_se
		sort primary
		gen id = _n
		order id
		save "$path/reps_primary.dta", replace

		use "$path/reps_downstream1.dta", clear
		ren _bs_1 downstream1
		ren _bs_2 downstream1_se
		sort downstream1
		gen id = _n
		order id
		save "$path/reps_downstream1.dta", replace

		use "$path/reps_downstream2.dta", clear
		ren _bs_1 downstream2
		ren _bs_2 downstream2_se
		sort downstream2
		gen id = _n
		order id
		save "$path/reps_downstream2.dta", replace

		use "$path/reps_fgd_index.dta", clear
		ren _bs_1 secondary
		ren _bs_2 secondary_se
		sort secondary
		gen id = _n
		order id
		save "$path/reps_fgd_index.dta", replace

		use "$path/reps_primary1.dta", clear
		ren _bs_1 primary_scst
		ren _bs_2 primary_scst_se
		sort primary_scst
		gen id = _n
		order id
		save "$path/reps_primary1.dta", replace

		use "$path/reps_downstream11.dta", clear
		ren _bs_1 downstream1_scst
		ren _bs_2 downstream1_scst_se
		sort downstream1_scst
		gen id = _n
		order id
		save "$path/reps_downstream11.dta", replace

		use "$path/reps_downstream21.dta", clear
		ren _bs_1 downstream2_scst
		ren _bs_2 downstream2_scst_se
		sort downstream2_scst
		gen id = _n
		order id
		save "$path/reps_downstream21.dta", replace

		use "$path/reps_wt_inf_rate1.dta", clear
		ren _bs_1 secondary_scst
		ren _bs_2 secondary_scst_se
		sort secondary_scst
		gen id = _n
		order id
		save "$path/reps_wt_inf_rate1.dta", replace

		use "$path/reps_primary.dta", clear
		merge 1:1 id using "$path/reps_downstream1.dta"
		drop _merge
		merge 1:1 id using "$path/reps_downstream2.dta"
		drop _merge
		merge 1:1 id using "$path/reps_fgd_index.dta"
		drop _merge
		merge 1:1 id using "$path/reps_primary1.dta"
		drop _merge
		merge 1:1 id using "$path/reps_downstream11.dta"
		drop _merge
		merge 1:1 id using "$path/reps_downstream21.dta"
		drop _merge
		merge 1:1 id using "$path/reps_wt_inf_rate1.dta"
		drop _merge
		save "$path/RW_reps.dta", replace

		cap mat drop temp
		rwolf primary downstream1 downstream2 secondary primary_scst downstream1_scst downstream2_scst secondary_scst, noboot ///
		stdests(primary_se downstream1_se downstream2_se secondary_se primary_scst_se downstream1_scst_se downstream2_scst_se secondary_scst_se) ///
		pointestimates(.727503 -.0046776 .0144834 -.2358948 .1929263 .0730413 -.0062854 -.2248608) ///		
		stderrs(.0294861 .0164276 .0178585 .07299 .0497759 .029283 .0288521 .10752002)

		mat temp = e(RW)
		
		mat colnames temp = "Model p-val" "Resample p-val" "RW p-val"
		mat rownames temp = "primary" "downstream1" "downstream2" "secondary" "primary_scst" "downstream1_scst" "downstream2_scst" "secondary_scst"

		esttab mat(temp, fmt(a3)) using "$output/RWpval.csv", replace csv nomtitle
