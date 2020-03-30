	/*PROC TMODEL SEIR APPROACH*/
		%IF &HAVE_SASETS = YES %THEN %DO;
			/*DATA FOR PROC TMODEL APPROACHES*/
				DATA DINIT(Label="Initial Conditions of Simulation"); 
						DO TIME = 0 TO &N_DAYS; 
						S_N = &S. - (&I/&DIAGNOSED_RATE) - &R;
						E_N = &E;
						I_N = &I/&DIAGNOSED_RATE;
						R_N = &R;
						R0  = &R_T;
						IF TIME >= (&ISO_Change_Date - "&DAY_ZERO"D) then R0  = &R_T_Change;
						IF TIME >= (&ISO_Change_Date_Two - "&DAY_ZERO"D) then R0  = &R_T_Change_Two;
						OUTPUT; 
					END; 
				RUN;
			%IF &HAVE_V151 = YES %THEN %DO; PROC TMODEL DATA = DINIT NOPRINT; %END;
			%ELSE %DO; PROC MODEL DATA = DINIT NOPRINT; %END;
				/* PARAMETER SETTINGS */ 
				PARMS N &S. R0 &R_T. ; 
				GAMMA = &GAMMA.;
				SIGMA = &SIGMA;
				BETA = R0*GAMMA/N;
				/* DIFFERENTIAL EQUATIONS */ 
				/* a. Decrease in healthy susceptible persons through infections: number of encounters of (S,I)*TransmissionProb*/
				DERT.S_N = -BETA*S_N*I_N;
				/* b. inflow from a. -Decrease in Exposed: alpha*e "promotion" inflow from E->I;*/
				DERT.E_N = BETA*S_N*I_N-SIGMA*E_N;
				/* c. inflow from b. - outflow through recovery or death during illness*/
				DERT.I_N = SIGMA*E_N-GAMMA*I_N;
				/* d. Recovered and death humans through "promotion" inflow from c.*/
				DERT.R_N = GAMMA*I_N;           
				/* SOLVE THE EQUATIONS */ 
				SOLVE S_N E_N I_N R_N / OUT = TMODEL_SEIR; 
			RUN;
			QUIT;

			DATA TMODEL_SEIR;
				FORMAT ModelType $30. Scenarioname $30. DATE ADMIT_DATE DATE9.;
				ModelType="TMODEL - SEIR";
				ScenarioName="&Scenario";
				ScenarioIndex=&ScenarioIndex.;
				ScenarionNameUnique=cats("&Scenario.",' (',ScenarioIndex,')');
				LABEL HOSPITAL_OCCUPANCY="Hospital Occupancy" ICU_OCCUPANCY="ICU Occupancy" VENT_OCCUPANCY="Ventilator Utilization"
					ECMO_OCCUPANCY="ECMO Utilization" DIAL_OCCUPANCY="Dialysis Utilization";
				RETAIN LAG_S LAG_I LAG_R LAG_N CUMULATIVE_SUM_HOSP CUMULATIVE_SUM_ICU CUMULATIVE_SUM_VENT CUMULATIVE_SUM_ECMO CUMULATIVE_SUM_DIAL Cumulative_sum_fatality
					CUMULATIVE_SUM_MARKET_HOSP CUMULATIVE_SUM_MARKET_ICU CUMULATIVE_SUM_MARKET_VENT CUMULATIVE_SUM_MARKET_ECMO CUMULATIVE_SUM_MARKET_DIAL cumulative_Sum_Market_Fatality;
				LAG_S = S_N; 
				LAG_E = E_N; 
				LAG_I = I_N; 
				LAG_R = R_N; 
				LAG_N = N; 
				SET TMODEL_SEIR(RENAME=(TIME=DAY) DROP=_ERRORS_ _MODE_ _TYPE_);
				N = SUM(S_N, E_N, I_N, R_N);
				SCALE = LAG_N / N;
/*				NEWINFECTED=LAG&IncubationPeriod(SUM(LAG(SUM(S_N,E_N)),-1*SUM(S_N,E_N)));*/
/*				IF NEWINFECTED < 0 THEN NEWINFECTED=0;*/
/*				HOSP = NEWINFECTED * &HOSP_RATE * &MARKET_SHARE;*/
/*				ICU = NEWINFECTED * &ICU_RATE * &MARKET_SHARE * &HOSP_RATE;*/
/*				VENT = NEWINFECTED * &VENT_RATE * &MARKET_SHARE * &HOSP_RATE;*/
/*				ECMO = NEWINFECTED * &ECMO_RATE * &MARKET_SHARE * &HOSP_RATE;*/
/*				DIAL = NEWINFECTED * &DIAL_RATE * &MARKET_SHARE * &HOSP_RATE;*/
/*				Fatality = NEWINFECTED * &Fatality_Rate * &MARKET_SHARE*&Hosp_rate;*/
/*				MARKET_HOSP = NEWINFECTED * &HOSP_RATE;*/
/*				MARKET_ICU = NEWINFECTED * &ICU_RATE * &HOSP_RATE;*/
/*				MARKET_VENT = NEWINFECTED * &VENT_RATE * &HOSP_RATE;*/
/*				MARKET_ECMO = NEWINFECTED * &ECMO_RATE * &HOSP_RATE;*/
/*				MARKET_DIAL = NEWINFECTED * &DIAL_RATE * &HOSP_RATE;*/
/*				Market_Fatality = NEWINFECTED * &Fatality_Rate *&Hosp_rate;*/
/*				CUMULATIVE_SUM_HOSP + HOSP;*/
/*				CUMULATIVE_SUM_ICU + ICU;*/
/*				CUMULATIVE_SUM_VENT + VENT;*/
/*				CUMULATIVE_SUM_ECMO + ECMO;*/
/*				CUMULATIVE_SUM_DIAL + DIAL;*/
/*				Cumulative_sum_fatality + Fatality;*/
/*				CUMULATIVE_SUM_MARKET_HOSP + MARKET_HOSP;*/
/*				CUMULATIVE_SUM_MARKET_ICU + MARKET_ICU;*/
/*				CUMULATIVE_SUM_MARKET_VENT + MARKET_VENT;*/
/*				CUMULATIVE_SUM_MARKET_ECMO + MARKET_ECMO;*/
/*				CUMULATIVE_SUM_MARKET_DIAL + MARKET_DIAL;*/
/*				cumulative_Sum_Market_Fatality + Market_Fatality;*/
/*				CUMADMITLAGGED=ROUND(LAG&HOSP_LOS(CUMULATIVE_SUM_HOSP),1) ;*/
/*				CUMICULAGGED=ROUND(LAG&ICU_LOS(CUMULATIVE_SUM_ICU),1) ;*/
/*				CUMVENTLAGGED=ROUND(LAG&VENT_LOS(CUMULATIVE_SUM_VENT),1) ;*/
/*				CUMECMOLAGGED=ROUND(LAG&ECMO_LOS(CUMULATIVE_SUM_ECMO),1) ;*/
/*				CUMDIALLAGGED=ROUND(LAG&DIAL_LOS(CUMULATIVE_SUM_DIAL),1) ;*/
/*				CUMMARKETADMITLAG=ROUND(LAG&HOSP_LOS(CUMULATIVE_SUM_MARKET_HOSP));*/
/*				CUMMARKETICULAG=ROUND(LAG&ICU_LOS(CUMULATIVE_SUM_MARKET_ICU));*/
/*				CUMMARKETVENTLAG=ROUND(LAG&VENT_LOS(CUMULATIVE_SUM_MARKET_VENT));*/
/*				CUMMARKETECMOLAG=ROUND(LAG&ECMO_LOS(CUMULATIVE_SUM_MARKET_ECMO));*/
/*				CUMMARKETDIALLAG=ROUND(LAG&DIAL_LOS(CUMULATIVE_SUM_MARKET_DIAL));*/
/*				ARRAY FIXINGDOT _NUMERIC_;*/
/*				DO OVER FIXINGDOT;*/
/*					IF FIXINGDOT=. THEN FIXINGDOT=0;*/
/*				END;*/
/*				HOSPITAL_OCCUPANCY= ROUND(CUMULATIVE_SUM_HOSP-CUMADMITLAGGED,1);*/
/*				ICU_OCCUPANCY= ROUND(CUMULATIVE_SUM_ICU-CUMICULAGGED,1);*/
/*				VENT_OCCUPANCY= ROUND(CUMULATIVE_SUM_VENT-CUMVENTLAGGED,1);*/
/*				ECMO_OCCUPANCY= ROUND(CUMULATIVE_SUM_ECMO-CUMECMOLAGGED,1);*/
/*				DIAL_OCCUPANCY= ROUND(CUMULATIVE_SUM_DIAL-CUMDIALLAGGED,1);*/
/*				Deceased_Today = Fatality;*/
/*				Total_Deaths = Cumulative_sum_fatality;*/
/*				MedSurgOccupancy=Hospital_Occupancy-ICU_Occupancy;*/
/*				MARKET_HOSPITAL_OCCUPANCY= ROUND(CUMULATIVE_SUM_MARKET_HOSP-CUMMARKETADMITLAG,1);*/
/*				MARKET_ICU_OCCUPANCY= ROUND(CUMULATIVE_SUM_MARKET_ICU-CUMMARKETICULAG,1);*/
/*				MARKET_VENT_OCCUPANCY= ROUND(CUMULATIVE_SUM_MARKET_VENT-CUMMARKETVENTLAG,1);*/
/*				MARKET_ECMO_OCCUPANCY= ROUND(CUMULATIVE_SUM_MARKET_ECMO-CUMMARKETECMOLAG,1);*/
/*				MARKET_DIAL_OCCUPANCY= ROUND(CUMULATIVE_SUM_MARKET_DIAL-CUMMARKETDIALLAG,1);	*/
/*				Market_Deceased_Today = Market_Fatality;*/
/*				Market_Total_Deaths = cumulative_Sum_Market_Fatality;*/
/*				Market_MEdSurg_Occupancy=Market_Hospital_Occupancy-MArket_ICU_Occupancy;*/
/*				DATE = "&DAY_ZERO"D + DAY;*/
/*				ADMIT_DATE = SUM(DATE, &DAYS_TO_HOSP.);*/
X_IMPORT: postprocess.sas
				DROP LAG: CUM: ;
			RUN;
			%IF &PLOTS. = YES %THEN %DO;
				PROC SGPLOT DATA=TMODEL_SEIR;
					where ModelType='TMODEL - SEIR' and ScenarioIndex=&ScenarioIndex.;
					TITLE "Daily Occupancy - PROC TMODEL SEIR Approach";
					TITLE2 "Scenario: &Scenario., Initial R0: %SYSFUNC(round(&R_T,.01)) with Initial Social Distancing of %SYSEVALF(&SocialDistancing*100)%";
					TITLE3 "Adjusted R0 after &ISOChangeDate: %SYSFUNC(round(&R_T_Change,.01)) with Adjusted Social Distancing of %SYSEVALF(&SocialDistancingChange*100)%";
					TITLE4 "Adjusted R0 after &ISOChangeDateTwo: %SYSFUNC(round(&R_T_Change_Two,.01)) with Adjusted Social Distancing of %SYSEVALF(&SocialDistancingChangeTwo*100)%";
					SERIES X=DATE Y=HOSPITAL_OCCUPANCY / LINEATTRS=(THICKNESS=2);
					SERIES X=DATE Y=ICU_OCCUPANCY / LINEATTRS=(THICKNESS=2);
					SERIES X=DATE Y=VENT_OCCUPANCY / LINEATTRS=(THICKNESS=2);
					SERIES X=DATE Y=ECMO_OCCUPANCY / LINEATTRS=(THICKNESS=2);
					SERIES X=DATE Y=DIAL_OCCUPANCY / LINEATTRS=(THICKNESS=2);
					XAXIS LABEL="Date";
					YAXIS LABEL="Daily Occupancy";
				RUN;
				TITLE; TITLE2; TITLE3; TITLE4;
			%END;
			PROC APPEND base=store.MODEL_FINAL data=TMODEL_SEIR; run;
			PROC SQL; drop table TMODEL_SEIR; drop table DINIT; QUIT;
		%END;