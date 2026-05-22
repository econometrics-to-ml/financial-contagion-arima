clear
clear matrix
clear mata
estimates clear
*set memory 900m
*set maxvar 8000
set matsize 4000


cd d:\...
set more off
use "D:\....dta", clear
set maxiter 10



* Go to the year
foreach year of numlist 2008/2016 {
	display " "
	display "*******************************year:" `year'
	capture local drop `listvar'
	capture local drop `depend'
	unab allvars : var*
	capture unab estimated : *_e
	capture local listvar : list allvars - estimated	

	*if `year' == 2013 {
	*	 local depend = "vardep7244- vardep7923"
	*}
	*else {
	*	local depend = `listvar'
	*}
	
* Define the matrix

matrix y`year' = J(1,1,.)
matrix colname y`year' = `year'
matrix rowname y`year' = variables

	
	foreach var of varlist `listvar' {
		di "`var'"
		
		
		 capture reg `var' L.`var' if inrange(edate, td(30jan`year'), td(31dec`year'))
		 qui estat bgodfrey, lags(2)
		 matrix a = r(p)
		 scalar alpha = a[1,1]
		 matrix drop a
		 
			
		if alpha < .1 {
			di "1. Non-Stationary"
			qui pperron `var' if inrange(edate, td(30jan`year'), td(31dec`year')), trend regress lags(1)
			qui local pperron0 `r(p)'
			
			
			*************************** TREND PART ******************************************************
			if `pperron0' < 0.1 {
				di "2. Trend type"
				qui reg `var' edate if inrange(edate, td(30jan`year'), td(31dec`year'))
				qui predict ehat if inrange(edate, td(30jan`year'), td(31dec`year'))
				gen residreturn_`var' =  ehat
				drop ehat
				qui regress residreturn_`var' L.residreturn_`var' if inrange(edate, td(30jan`year'), td(31dec`year'))
				qui estat bgodfrey, lags(2)
				matrix c = r(p)
				scalar gamma = c[1,1]
				matrix drop c
				
					
				if gamma < 0.1 {
					di "3. Non-stationary after trend extraction"
					
					qui summarize D.residreturn_`var' if inrange(edate, td(30jan`year'), td(31dec`year'))
					local a = `=r(min)' - `=r(max)'
					if `a' == 0 {
						drop `var'
						capture drop `var'_e
						capture drop residreturn_`var'
						local drop `pperron0'
						scalar drop gamma
						local drop `a'
						continue
					}
					local drop `a'
					
					qui regress D1.residreturn_`var' L.D1.residreturn_`var' if inrange(edate, td(30jan`year'), td(31dec`year'))
					qui estat bgodfrey, lags(2)
					matrix d = r(p)
					scalar delta = d[1,1]
					matrix drop d
					
						
						if delta < .1 {
									di "Non-stationary after trend extraction and difference taking"
									qui reg D2.residreturn_`var' L.D2.residreturn_`var' if inrange(edate, td(30jan`year'), td(31dec`year'))
									qui estat bgodfrey, lags(2)
									matrix e = r(p)
									scalar epsilon = e[1,1]
									matrix drop e
										
										if epsilon < .1 {
											di "Non-Stationary after the trend extraction and 2nd difference"
											qui reg D3.residreturn_`var' L.D3.residreturn_`var' if inrange(edate, td(30jan`year'), td(31dec`year'))
											qui estat bgodfrey, lags(2)
											matrix f = r(p)
											scalar feta = f[1,1]
											matrix drop f
											
												if feta < .1 {
												di "Non-Stationary after the trend extraction and 3nd difference"
												drop residreturn_`var'
												drop `var'
												local drop `pperron0'
												scalar drop gamma
												scalar drop feta
												scalar drop delta
												scalar drop epsilon
												capture drop `var'_e
												continue
											}
										
											else {
												di "Become stationary after trend extraction and 3nd difference"
												gen temp = D3.residreturn_`var' if inrange(edate, td(30jan`year'), td(31dec`year'))
												lagselect16 temp if inrange(edate, td(30jan`year'), td(31dec`year'))
												drop temp

												
												local drop `pperron0'
												
												matrix Q = J(1,1,`r(aic_k)')
												matrix rowname Q = `var'
												matrix colname Q = lag
												matrix y`year'=(y`year'\Q)
												matrix drop Q
												display "Selected ARMA(p,q) with AIC criterion = ARMA(`r(aic_k)',`r(aic_l)')"
												capture arima D3.residreturn_`var' if inrange(edate, td(30jan`year'), td(31dec`year')), arima(`r(aic_k)',0,`r(aic_l)')
												
												qui predict yhat if inrange(edate, td(30jan`year'), td(31dec`year')), resid
												
												
												capture confirm variable `var'_e
												
												if !_rc {
													replace `var'_e= yhat if inrange(edate, td(30jan`year'), td(31dec`year'))
												}
												
												else {
													gen `var'_e = yhat if inrange(edate, td(30jan`year'), td(31dec`year'))
													local lab: variable label `var'
													label variable `var'_e `lab'
													local drop `lab'
												}	
												
												capture drop yhat
												local drop `r(aic_l)'
												local drop `r(aic_k)'
												drop residreturn_`var'
											}
										
										}
									
										else {
											di "Become stationary after trend extraction and 2nd difference"
											gen temp = D2.residreturn_`var' if inrange(edate, td(30jan`year'), td(31dec`year'))
											lagselect16 temp if inrange(edate, td(30jan`year'), td(31dec`year'))
											drop temp

											
											local drop `pperron0'
											
											matrix Q = J(1,1,`r(aic_k)')
											matrix rowname Q = `var'
											matrix colname Q = lag
											matrix y`year'=(y`year'\Q)
											matrix drop Q
											display "Selected ARMA(p,q) with AIC criterion = ARMA(`r(aic_k)',`r(aic_l)')"
											capture arima D2.residreturn_`var' if inrange(edate, td(30jan`year'), td(31dec`year')), arima(`r(aic_k)',0,`r(aic_l)')
											
											qui predict yhat if inrange(edate, td(30jan`year'), td(31dec`year')), resid
											
											
											capture confirm variable `var'_e
											
											if !_rc {
												replace `var'_e= yhat if inrange(edate, td(30jan`year'), td(31dec`year'))
											}
											
											else {
												gen `var'_e = yhat if inrange(edate, td(30jan`year'), td(31dec`year'))
												local lab: variable label `var'
												label variable `var'_e `lab'
												local drop `lab'
											}	
											
											capture drop yhat
											local drop `r(aic_l)'
											local drop `r(aic_k)'
											drop residreturn_`var'
								}
						}
						
						else {
							di "Stationary after trend extraction and difference taking"
							
							capture gen temp = D1.residreturn_`var' if inrange(edate, td(30jan`year'), td(31dec`year'))
							capture lagselect16 temp if inrange(edate, td(30jan`year'), td(31dec`year'))
							capture drop temp
							
							
							local drop `pperron0'
							
							
							display "Selected ARMA(p,q) with AIC criterion = ARMA(`r(aic_k)',`r(aic_l)')"
							local lag = `r(aic_k)'
							capture arima D1.residreturn_`var' if inrange(edate, td(30jan`year'), td(31dec`year')), arima(0,0,`r(aic_l)')
							if _rc != 0 {
								drop `var'
								local drop `r(aic_l)'
								local drop `r(aic_k)'
								drop residreturn_`var'
								di "Excluded because of collinearity"
								continue
							}
							
							matrix Q = J(1,1,`lag')
							matrix rowname Q = `var'
							matrix colname Q = lag
							matrix y`year'=(y`year'\Q)
							matrix drop Q
							
							qui predict yhat if inrange(edate, td(30jan`year'), td(31dec`year')), resid
							
							
							capture confirm variable `var'_e
											
											if !_rc {
												replace `var'_e= yhat if inrange(edate, td(30jan`year'), td(31dec`year'))
											}
											
											else {
												gen `var'_e = yhat if inrange(edate, td(30jan`year'), td(31dec`year'))
												local lab: variable label `var'
												label variable `var'_e `lab'
												local drop `lab'
											}	
							
							capture drop yhat
							local drop `r(aic_l)'
							local drop `lag'
							capture drop residreturn_`var'
						}

					}
				
				else {
					di "Stationary after trend extraction"
					
					capture lagselect16 residreturn_`var' if inrange(edate, td(30jan`year'), td(31dec`year'))
					
					local drop `pperron0'
					
					matrix Q = J(1,1,`r(aic_k)')
					matrix rowname Q = `var'
					matrix colname Q = lag
					matrix y`year'=(y`year'\Q)
					matrix drop Q
					display "Selected ARMA(p,q) with AIC criterion = ARMA(`r(aic_k)',`r(aic_l)')"
					
					capture arima residreturn_`var' if inrange(edate, td(30jan`year'), td(31dec`year')), arima(0,0,`r(aic_l)')
					
					qui predict yhat if inrange(edate, td(30jan`year'), td(31dec`year')), resid
					
					
					capture confirm variable `var'_e
											
											if !_rc {
												replace `var'_e= yhat if inrange(edate, td(30jan`year'), td(31dec`year'))
											}
											
											else {
												gen `var'_e = yhat if inrange(edate, td(30jan`year'), td(31dec`year'))
												local lab: variable label `var'
												label variable `var'_e `lab'
												local drop `lab'
											}	
					
					capture drop yhat
					local drop `r(aic_l)'
					local drop `r(aic_k)'
					drop residreturn_`var'
				}
			}
				
			else {
				
			*************************************************** DIFFERENCE PART *******************************************		
				 di "2. Difference Type"
				 qui regress D1.`var' L.D1.`var' if inrange(edate, td(30jan`year'), td(31dec`year'))
				 qui estat bgodfrey, lags(2)
				 matrix b = r(p)
				 scalar beta = b[1,1]
				 matrix drop b
								 
				 if beta < 0.1 {
					di "Non-stationary after difference taking"
					qui regress D2.`var' L.D2.`var' if inrange(edate, td(30jan`year'), td(31dec`year'))
					qui estat bgodfrey, lags(2)
					matrix z = r(p)
					scalar zeta = z[1,1]
					matrix drop z
					
						if zeta < .1 {
							di "Non-Stationary after 2nd difference"
							drop `var'
							local drop `pperron0'
							capture drop `var'_e
							continue
							
						}
						
						else {
							di "Become stationary after 2nd difference"
							gen temp = D2.`var' if inrange(edate, td(30jan`year'), td(31dec`year'))
							capture lagselect16 temp if inrange(edate, td(30jan`year'), td(31dec`year'))
							drop temp
							
							
							local drop `pperron0'
							
							matrix Q = J(1,1,`r(aic_k)')
							matrix rowname Q = `var'
							matrix colname Q = lag
							matrix y`year'=(y`year'\Q)
							matrix drop Q
							display "Selected ARMA(p,q) with AIC criterion = ARMA(`r(aic_k)',`r(aic_l)')"
							capture arima D2.`var' if inrange(edate, td(30jan`year'), td(31dec`year')), arima(`r(aic_k)',0,`r(aic_l)')
							
							qui predict yhat if inrange(edate, td(30jan`year'), td(31dec`year')), resid 
							
							capture confirm variable `var'_e
											
											if !_rc {
												replace `var'_e= yhat if inrange(edate, td(30jan`year'), td(31dec`year'))
											}
											
											else {
												gen `var'_e = yhat if inrange(edate, td(30jan`year'), td(31dec`year'))
												local lab: variable label `var'
												label variable `var'_e `lab'
												local drop `lab'
											}	
							capture drop yhat
							local drop `r(aic_l)'
							local drop `r(aic_k)'
						}
				 }
				 
				 else {
					di "Become stationary after difference taking"
					
					gen temp = D1.`var'
					capture lagselect16 temp if inrange(edate, td(30jan`year'), td(31dec`year'))
					drop temp
					
					local drop `pperron0'
					
					matrix Q = J(1,1,`r(aic_k)')
					matrix rowname Q = `var'
					matrix colname Q = lag
					matrix y`year'=(y`year'\Q)
					matrix drop Q
					display "Selected ARMA(p,q) with AIC criterion = ARMA(`r(aic_k)',`r(aic_l)')"
					capture arima D1.`var' if inrange(edate, td(30jan`year'), td(31dec`year')), arima(0,0,`r(aic_l)')
					
					qui predict yhat if inrange(edate, td(30jan`year'), td(31dec`year')), resid
					
					capture confirm variable `var'_e
											
											if !_rc {
												replace `var'_e= yhat if inrange(edate, td(30jan`year'), td(31dec`year'))
											}
											
											else {
												gen `var'_e = yhat if inrange(edate, td(30jan`year'), td(31dec`year'))
												local lab: variable label `var'
												label variable `var'_e `lab'
												local drop `lab'
											}	
					capture drop yhat
					local drop `r(aic_l)'
					local drop `r(aic_k)'
				 }
			} 
		}
		
		*************************************************** STATIONARY PART *******************************************
				 
		else {
			di "1. Stationary"
			
			capture lagselect16 `var' if inrange(edate, td(30jan`year'), td(31dec`year'))
			
				capture matrix Q = J(1,1,`r(aic_k)')
				capture matrix rowname Q = `var'
				capture matrix colname Q = lag
				capture matrix y`year'=(y`year'\Q)
				capture matrix drop Q
				display "Selected ARMA(p,q) with AIC criterion = ARMA(`r(aic_k)',`r(aic_l)')"
				capture arima `var' if inrange(edate, td(30jan`year'), td(31dec`year')), arima(0,0,`r(aic_l)')
					
				qui predict yhat if inrange(edate, td(30jan`year'), td(31dec`year')), resid
				capture confirm variable `var'_e
											
											if !_rc {
												replace `var'_e= yhat if inrange(edate, td(30jan`year'), td(31dec`year'))
											}
											
											else {
												gen `var'_e = `var' if inrange(edate, td(30jan`year'), td(31dec`year'))
												local lab: variable label `var'
												label variable `var'_e `lab'
												local drop `lab'
											}	
				
			capture drop yhat	
			local drop `r(aic_l)'
			local drop `r(aic_k)'
			}
			 
			di "*********************************"
		
		scalar drop _all
	}
	
	local drop `listvar'
	local drop `depend'
	unab allvars : var*
	unab estimated : *_e
	local listvar : list allvars - estimated
	
	*if `year' == 2013 {
	*	 local depend = "vardep7244- vardep7923"
	*}
	*else {
	*	local depend = `listvar'
	*}
	
	gen str1 namevar_`year' = ""                
	local i 2                              
	foreach var of varlist `listvar' {  
        replace namevar_`year' = "`var'" in `i' 
        local ++i
	}
	
		
	svmat y`year', name(y`year'_)
	matrix drop y`year'
	xmlsave namevar_`year' y`year'_1 using "D:\...\Lags/`year'.xml", replace doctype(excel)
	save "D:\...\Ongoing\YEnd/R3`year'.dta", replace
	display "Stata finished year `year' in $S_TIME"
}

display "Stata finished in $S_TIME"
save "D:\...\allyears.dta", replace

