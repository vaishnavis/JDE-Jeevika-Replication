******************************************************************************************************************************************************************************************
** Relief from Usury: Impact of a Self-Help Group Lending Program in Rural India
** Vivian Hoffmann, Vijayendra Rao, Vaishnavi Surendra, Upamanyu Datta
**
** Replication Do-file
******************************************************************************************************************************************************************************************

** Variation in Interest Rates at Baseline cross-tabs
				
	preserve
		keep if hh_data==4 & when_took<=1 & loan_int!=0 & time==0
		gen loan_int2 = loan_int
		gen loan_int3 = loan_int
		
		** informal
		gen loan_source = 1 if informal==1
	
		** formal
		replace loan_source = 2 if formal==1
		
		** SHG
		replace loan_source = 3 if shg==1
		
		collapse (sd) loan_int (min) loan_int2 (max) loan_int3, by(vill_code loan_source tar_group)
		
		cap drop mat summ var
				
				** Informal - SC/ST
				su loan_int if tar_group==1 & loan_source==1
					mat summ = (1, 1, r(mean))
					
				su loan_int2 if tar_group==1 & loan_source==1
					mat summ = (summ, r(mean))
					
				su loan_int3 if tar_group==1 & loan_source==1
					mat summ = (summ, r(mean))
					
				mat var = (summ)
				cap drop mat summ

				** Informal - non-SC/ST
				su loan_int if tar_group==0 & loan_source==1
					mat summ = (1, 0, r(mean))
					
				su loan_int2 if tar_group==0 & loan_source==1
					mat summ = (summ, r(mean))
					
				su loan_int3 if tar_group==0 & loan_source==1
					mat summ = (summ, r(mean))
					
				mat var = (var\summ)
				cap drop mat summ				
				
				** Formal - SC/ST
				su loan_int if tar_group==1 & loan_source==2
					mat summ = (2, 1, r(mean))
					
				su loan_int2 if tar_group==1 & loan_source==2
					mat summ = (summ, r(mean))
					
				su loan_int3 if tar_group==1 & loan_source==2
					mat summ = (summ, r(mean))
					
				mat var = (var\summ)
				cap drop mat summ
				
				** Formal - non-SC/ST
				su loan_int if tar_group==0 & loan_source==2
					mat summ = (2, 0, r(mean))
					
				su loan_int2 if tar_group==0 & loan_source==2
					mat summ = (summ, r(mean))
					
				su loan_int3 if tar_group==0 & loan_source==2
					mat summ = (summ, r(mean))
					
				mat var = (var\summ)
				cap drop mat summ
				
				** SHG - SC/ST
				su loan_int if tar_group==1 & loan_source==3
					mat summ = (3, 1, r(mean))
					
				su loan_int2 if tar_group==1 & loan_source==3
					mat summ = (summ, r(mean))
					
				su loan_int3 if tar_group==1 & loan_source==3
					mat summ = (summ, r(mean))
					
				mat var = (var\summ)
				cap drop mat summ
				
				** SHG - non-SC/ST
				su loan_int if tar_group==0 & loan_source==3
					mat summ = (3, 0, r(mean))
					
				su loan_int2 if tar_group==0 & loan_source==3
					mat summ = (summ, r(mean))
					
				su loan_int3 if tar_group==0 & loan_source==3
					mat summ = (summ, r(mean))
					
				mat var = (var\summ)
				cap drop mat summ
				
				mat colnames var = "Source" "SC/ST" "SD" "Min" "Max"  
				mat rownames var = "Informal SC/ST" "Informal Gen" "Formal SC/ST" "Formal Gen" "SHG SC/ST" "SHG Gen"

				esttab mat(var, fmt(a3)) using "$output/Summar_Int_Table.csv", replace csv nomtitle

	restore
