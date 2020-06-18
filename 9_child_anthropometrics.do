
******************************
*** Child anthropometrics ****
******************************

*c_stunted: Child under 5 stunted
    foreach var in hc70 hc71 {
    replace `var'=. if `var'>900
    replace `var'=`var'/100
    }
    replace hc70=. if hc70<-6 | hc70>6
    replace hc71=. if hc71<-6 | hc71>5

    gen c_stunted=hc70<-2 if  hc70!=.
*c_underweight: Child under 5 underweight
    gen c_underweight=hc71<-2 if hc71!=.

*ant_sampleweight Child anthropometric sampling weight
    gen ant_sampleweight = hv005/10e6 



	
