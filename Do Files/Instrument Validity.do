******************************************************************************************************************************************************************************************
** Relief from Usury: Impact of a Self-Help Group Lending Program in Rural India
** Vivian Hoffmann, Vijayendra Rao, Vaishnavi Surendra, Upamanyu Datta
**
** Replication Do-file
******************************************************************************************************************************************************************************************

** Instrument Validity
				
** Loan level household interest rates for health
				
	tempvar Mean0Temp mean	
	
	eststo loan1: reghdfe loan_int health ln_amt time tar_group BL_landless [pweight=wt] if hh_data==4 & informal==1 & when_took<=1 & loan_int!=0 & status==0, absorb(srl) vce(cluster srl panch_code) nocons
				mean loan_int if e(sample) & time==0
					matrix `Mean0Temp' = e(b)
					scalar `mean' = `Mean0Temp'[1,1]
					estadd scalar wt_mean `mean': loan1

	tempvar Mean0Temp mean				
	eststo loan11: reghdfe loan_int health ln_amt time tar_group BL_landless [pweight=wt] if hh_data==4 & informal==1 & when_took<=1 & loan_int!=0 & status==0, absorb(panch_code) vce(cluster srl panch_code) nocons
				mean loan_int if e(sample) & time==0
					matrix `Mean0Temp' = e(b)
					scalar `mean' = `Mean0Temp'[1,1]
					estadd scalar wt_mean `mean': loan11
					
	tempvar Mean0Temp mean	
	eststo loan2: reghdfe loan_int health##tar_group ln_amt time BL_landless if hh_data==4 & informal==1 & when_took<=1 & loan_int!=0 & status==0, absorb(srl) vce(cluster srl panch_code) nocons
				mean loan_int if e(sample) & time==0 & tar_group==0
					matrix `Mean0Temp' = e(b)
					scalar `mean' = `Mean0Temp'[1,1]
					estadd scalar wt_mean `mean': loan2

	tempvar Mean0Temp mean	
	eststo loan21: reghdfe loan_int health##tar_group ln_amt time BL_landless if hh_data==4 & informal==1 & when_took<=1 & loan_int!=0 & status==0, absorb(panch_code) vce(cluster srl panch_code) nocons
				mean loan_int if e(sample) & time==0 & tar_group==0
					matrix `Mean0Temp' = e(b)
					scalar `mean' = `Mean0Temp'[1,1]
					estadd scalar wt_mean `mean': loan21
					
		esttab loan1 loan11 loan2 loan21 using "$output/Instrument.csv", b(%10.2f)  se ///
		scalars("N Observations" "N_clust Number of clusters" "r2 R-squared" "wt_mean Mean") ///
		sfmt(%9.0f %9.0f %9.2f %9.2f) star(* 0.10 ** 0.05 *** 0.01) csv mtitles append title("Instrument Validity")
