# --- 1. To use these predictive models, you should have a database (named data) with at least these following variables: ------------------

## --- 1.1 For M1-G-Lasso and M1-XGBoost models: -----------------------------
# - age (continuous variable)
# - sex (continuous variable: 1 for males, 0 for females)
# -  diploma (continuous variable: 
#             without diploma ~ 8,
#             DNB ~ 12,
#             CAP ~ 14,
#             BAC ~ 15,
#             BAC+2 or +3 ~ 18,
#             BAC+4 ~ 19,
#             BAC+5 or more ~ 23)
# - height (continuous variable)
# - BMI (continuous variable)

## --- 1.2  For M2-G-Lasso (143 variables): -----------------------------------
# age (continuous variable)
# sex (continuous variable: 1 for males, 0 for females)
# diploma (continuous variable: 
#             without diploma ~ 8,
#             DNB ~ 12,
#             CAP ~ 14,
#             BAC ~ 15,
#             BAC+2 or +3 ~ 18,
#             BAC+4 ~ 19,
#             BAC+5 or more ~ 23)
# height (continuous variable)
# BMI (continuous variable)
# DENTISTE   
# MEDECIN4    
# MEDECIN_31 
# MEDECIN_32  
# MEDECIN_4   
# PODOLOGUE   
# ATC_A02A    
# ATC_A03A   
# ATC_A07D   
# ATC_A07X   
# ATC_B02A    
# ATC_B03A   
# ATC_D01A   
# ATC_D01B   
# ATC_D07A   
# ATC_D07X   
# ATC_D08A   
# ATC_D10A   
# ATC_D10B   
# ATC_G01A    
# ATC_G02B  
# ATC_G03A  
# ATC_H02A  
# ATC_J01A  
# ATC_J01C  
# ATC_J01E  
# ATC_J01F  
# ATC_J01R  
# ATC_J01X    
# ATC_J07B  
# ATC_M02A  
# ATC_N01B  
# ATC_P01A  
# ATC_R01B  
# ATC_R05C  
# ATC_R05D  
# ATC_S01A  
# ATC_S01B    
# ATC_S01C   
# ATC_S01F   
# ATC_S01G   
# ATC_V04C   
# ATC_V08A   
# ATC_V08C   
# CvCoron    
# TOTAL_SSR  
# PAddict     
# TOTAL_A_CCAM 
# TOTAL_B_CCAM 
# TOTAL_C_CCAM
# TOTAL_D_CCAM
# TOTAL_E_CCAM
# TOTAL_G_CCAM
# TOTAL_H_CCAM
# TOTAL_J_CCAM
# TOTAL_L_CCAM
# TOTAL_M_CCAM
# TOTAL_N_CCAM 
# TOTAL_P_CCAM
# TOTAL_Q_CCAM
# TOTAL_Z_CCAM
# TOTAL_D_LPP 
# TOTAL_K_LPP 
# TOTAL_S_LPP 
# INFIRMIER   
# KINE        
# MEDECIN     
# MEDECIN_33 
# MEDECIN_5  
# ATC_A02B   
# ATC_A10B   
# ATC_A11C   
# ATC_A12B   
# ATC_C01D    
# ATC_C03C   
# ATC_C07A   
# ATC_C08C  
# ATC_C09B  
# ATC_C09C  
# ATC_C09D  
# ATC_G04B  
# ATC_H03A  
# ATC_M01A    
# ATC_M05B  
# ATC_M09A   
# ATC_N02A  
# ATC_N02B  
# ATC_N02C  
# ATC_N03A  
# ATC_N05A  
# ATC_N05B  
# ATC_N05C    
# ATC_N06A  
# ATC_N07C   
# ATC_R01A   
# ATC_R03A    
# ATC_R06A   
# ATC_S01E   
# TOTAL_H_LPP
# TOTAL_R_LPP
# TOTAL_T_LPP 
# MEDECIN_3   
# ATC_A03E    
# ATC_D02A    
# ATC_D06A    
# ATC_D06B   
# ATC_J01D   
# ATC_J01M   
# ATC_J02A   
# ATC_M03B    
# ATC_P02C   
# ATC_S02A   
# ATC_S02C   
# OB         
# TOTAL_K_CCAM
# TOTAL_O_LPP 
# ATC_A06A    
# ATC_A12A    
# ATC_B01A    
# ATC_C01E    
# ATC_C09A   
# ATC_N07B   
# ATC_R03B   
# TOTAL_A_LPP 
# ATC_A03F   
# ATC_J07A   
# ATC_S01K    
# TOTAL_MCO   
# TOTAL_F_CCAM 
# ATC_B03B     
# ATC_C01B     
# ATC_C10A     
# ATC_G02C    
# ATC_G03C    
# ATC_G04C  
# ATC_J05A  
# ATC_R03D    
# ATC_V03A    


## --- 1.3  For M3-G-Lasso (147 variables): -----------------------------------
# age (continuous variable)
# sex (continuous variable: 1 for males, 0 for females) 
# DENTISTE   
# MEDECIN4    
# MEDECIN_3   
# MEDECIN_32  
# MEDECIN_4   
# PODOLOGUE  
# ATC_A01A   
# ATC_A03A   
# ATC_A07B   
# ATC_A07D   
# ATC_A07X   
# ATC_B02A   
# ATC_B03A  
# ATC_D01A    
# ATC_D01B   
# ATC_D02A   
# ATC_D07A   
# ATC_D07X   
# ATC_D08A   
# ATC_D10A  
# ATC_D10B  
# ATC_G01A  
# ATC_G02B    
# ATC_G03A  
# ATC_J01A  
# ATC_J01D  
# ATC_J01E  
# ATC_J01F  
# ATC_J01R  
# ATC_J01X  
# ATC_J07B  
# ATC_M02A    
# ATC_M03B  
# ATC_N01B   
# ATC_P01A   
# ATC_R01B   
# ATC_R05C   
# ATC_S01A  
# ATC_S01F  
# ATC_S01G  
# ATC_S02C    
# ATC_V04C  
# ATC_V08A    
# ATC_V08C    
# CvCoron     
# HYPERU      
# OB          
# TOTAL_MCO   
# TOTAL_SSR  
# PAddict     
# TOTAL_A_CCAM
# TOTAL_B_CCAM
# TOTAL_C_CCAM
# TOTAL_E_CCAM
# TOTAL_F_CCAM
# TOTAL_G_CCAM
# TOTAL_H_CCAM
# TOTAL_J_CCAM
# TOTAL_L_CCAM
# TOTAL_M_CCAM
# TOTAL_N_CCAM
# TOTAL_P_CCAM
# TOTAL_Q_CCAM
# TOTAL_Z_CCAM
# TOTAL_D_LPP 
# TOTAL_K_LPP 
# TOTAL_S_LPP
# INFIRMIER   
# KINE       
# MEDECIN    
# MEDECIN_33 
# MEDECIN_5   
# ATC_A02B   
# ATC_A06A   
# ATC_A10B   
# ATC_A11C   
# ATC_A12B    
# ATC_B03B  
# ATC_C01D 
# ATC_C01E 
# ATC_C03C 
# ATC_C07A 
# ATC_C08C  
# ATC_C09B  
# ATC_C09C  
# ATC_C09D    
# ATC_C10A  
# ATC_G03C  
# ATC_G03D 
# ATC_G04B   
# ATC_H03A  
# ATC_J05A  
# ATC_M01A  
# ATC_M04A  
# ATC_M09A    
# ATC_N02A  
# ATC_N02B  
# ATC_N02C  
# ATC_N03A 
# ATC_N05A   
# ATC_N05B   
# ATC_N05C   
# ATC_N06A  
# ATC_N07C    
# ATC_R01A  
# ATC_R03A  
# ATC_R03D  
# ATC_S01E  
# ATC_S01X   
# ATC_V03A   
# TOTAL_H_LPP
# TOTAL_R_LPP
# TOTAL_T_LPP 
# ATC_A02A  
# ATC_A03E   
# ATC_B05X  
# ATC_D06B  
# ATC_H02A  
# ATC_J01C   
# ATC_J01M   
# ATC_J02A   
# ATC_J07C    
# ATC_P02C   
# ATC_R05D   
# ATC_S01B   
# ATC_S01C    
# ATC_S02A   
# TOTAL_D_CCAM 
# TOTAL_K_CCAM
# TOTAL_O_LPP 
# ATC_A12A    
# ATC_C01B    
# ATC_C09A    
# ATC_M05B   
# ATC_N07B  
# ATC_R03B  
# TOTAL_A_LPP
# MEDECIN_31 
# ATC_A03F    
# ATC_D06A    
# ATC_S01K  
# ARYTHM      
# ATC_G02C    
# ATC_G03F    
# ATC_G04C    

## --- 1.4 For M2-XGBoost (75 variables): -------------------------------------
# - age (continuous variable)
# - sex (continuous variable: 1 for males, 0 for females)
# -  diploma (continuous variable: 
#             without diploma ~ 8,
#             DNB ~ 12,
#             CAP ~ 14,
#             BAC ~ 15,
#             BAC+2 or +3 ~ 18,
#             BAC+4 ~ 19,
#             BAC+5 or more ~ 23)
# - height (continuous variable)
# - BMI (continuous variable)
# - ATC_N02B 
# - ATC_N02A 
# - ATC_N05B   
# - MEDECIN_1
# - ATC_N06A  
# - INFIRMIER   
# - ATC_A10B   
# - KINE       
# - DENTISTE  
# - ATC_A02B  
# - ATC_C07A   
# - ATC_J07B  
# - ATC_R05D    
# - ATC_C10A  
# - TOTAL_N_CCAM 
# - MEDECIN_32 
# - TOTAL_O_LPP  
# - TOTAL_D_LPP  
# - ATC_M01A   
# - TOTAL_M_CCAM 
# - ATC_A07X  
# - ATC_N03A  
# - TOTAL_P_CCAM 
# - TOTAL_S_LPP 
# - ATC_N05A   
# - ATC_C09D  
# - ATC_M02A  
# - ATC_G04C  
# - TOTAL_MCO 
# - ATC_H03A    
# - TOTAL_J_CCAM 
# - TOTAL_K_LPP
# - ATC_N05C  
# - ATC_M09A  
# - ATC_R01A  
# - ATC_B01A  
# - TOTAL_R_LPP
# - ATC_A11C  
# - ATC_C03C    
# - ATC_R03A  
# - ATC_M04A 
# - TOTAL_D_CCAM
# - ATC_C08C    
# - ATC_S01A
# - ATC_M03B  
# - ATC_S01G   
# - ATC_R06A  
# - TOTAL_H_CCAM
# - ATC_D10B    
# - ATC_N07C  
# - MEDECIN_33  
# - MEDECIN_14  
# - HYPERU     
# - TOTAL_G_CCAM 
# - TOTAL_B_CCAM
# - TOTAL_SSR  
# - ATC_A01A    
# - ATC_A06A    
# - TOTAL_A_CCAM 
# - PODOLOGUE   
# - ATC_J01R   
# - ATC_C09A    
# - ATC_H02A  
# - TOTAL_Q_CCAM 
# - ATC_S01E   
# - TOTAL_L_CCAM
# - ATC_C09B   
# - ATC_N07B  
# - TOTAL_G_LPP 
# - ATC_A03F 


## --- 1.5 For M3-XGBoost (159 variables): -------------------------------------
# age (continuous variable)
# sex (continuous variable: 1 for males, 0 for females)
# DENTISTE   
# INFIRMIER 
# KINE      
# MEDECIN_1 
# MEDECIN_14  
# MEDECIN_3 
# MEDECIN_31
# MEDECIN_32 
# MEDECIN_33 
# MEDECIN_4 
# MEDECIN_5 
# PODOLOGUE   
# ATC_A01A  
# ATC_A02A   
# ATC_A02B  
# ATC_A03A  
# ATC_A03E  
# ATC_A03F  
# ATC_A04A    
# ATC_A06A  
# ATC_A07B   
# ATC_A07D   
# ATC_A07X   
# ATC_A10B   
# ATC_A11C  
# ATC_A12A    
# ATC_A12B 
# ATC_A12C   
# ATC_B01A  
# ATC_B02A  
# ATC_B03A 
# ATC_B03B 
# ATC_B05X    
# ATC_C01B    
# ATC_C01D  
# ATC_C01E  
# ATC_C03C 
# ATC_C05A  
# ATC_C07A   
# ATC_C08C    
# ATC_C09A  
# ATC_C09B   
# ATC_C09C  
# ATC_C09D  
# ATC_C10A  
# ATC_D01A   
# ATC_D01B    
# ATC_D02A   
# ATC_D05A   
# ATC_D06A   
# ATC_D06B   
# ATC_D07A  
# ATC_D07X  
# ATC_D08A    
# ATC_D10A    
# ATC_D10B   
# ATC_G01A   
# ATC_G02B  
# ATC_G02C   
# ATC_G03A   
# ATC_G03C    
# ATC_G03D   
# ATC_G03F   
# ATC_G04B   
# ATC_G04C  
# ATC_H02A  
# ATC_H03A  
# ATC_J01A    
# ATC_J01C  
# ATC_J01D  
# ATC_J01E  
# ATC_J01F  
# ATC_J01M  
# ATC_J01R  
# ATC_J01X    
# ATC_J02A   
# ATC_J05A   
# ATC_J07A  
# ATC_J07B   
# ATC_J07C  
# ATC_M01A  
# ATC_M02A    
# ATC_M03B  
# ATC_M04A  
# ATC_M05B  
# ATC_M09A  
# ATC_N01B  
# ATC_N02A  
# ATC_N02B    
# ATC_N02C  
# ATC_N03A   
# ATC_N05A  
# ATC_N05B  
# ATC_N05C  
# ATC_N06A  
# ATC_N07B    
# ATC_N07C   
# ATC_P01A  
# ATC_P02C  
# ATC_R01A  
# ATC_R01B  
# ATC_R03A  
# ATC_R03B    
# ATC_R03D  
# ATC_R05C 
# ATC_R05D  
# ATC_R06A  
# ATC_S01A  
# ATC_S01B  
# ATC_S01C    
# ATC_S01E  
# ATC_S01F   
# ATC_S01G    
# ATC_S01K   
# ATC_S01X  
# ATC_S02A  
# ATC_S02C    
# ATC_S02D  
# ATC_V03A  
# ATC_V04C  
# ATC_V08A   
# ATC_V08C 
# ARYTHM    
# CvCoron   
# HYPERU    
# OB        
# SOLIDTUM   
# TOTAL_MCO  
# TOTAL_SSR  
# AUTRCARDIO 
# PAddict     
# PDepNev    
# TOTAL_A_CCAM
# TOTAL_B_CCAM
# TOTAL_C_CCAM
# TOTAL_D_CCAM
# TOTAL_E_CCAM 
# TOTAL_F_CCAM
# TOTAL_G_CCAM
# TOTAL_H_CCAM
# TOTAL_J_CCAM 
# TOTAL_K_CCAM 
# TOTAL_L_CCAM 
# TOTAL_M_CCAM
# TOTAL_N_CCAM
# TOTAL_P_CCAM 
# TOTAL_Q_CCAM
# TOTAL_Z_CCAM
# TOTAL_A_LPP 
# TOTAL_D_LPP 
# TOTAL_G_LPP 
# TOTAL_H_LPP 
# TOTAL_K_LPP 
# TOTAL_O_LPP 
# TOTAL_R_LPP
# TOTAL_S_LPP  
# TOTAL_T_LPP 



# --- 2. The code below explains the signification these variables from a typical SNDS and/or cohort export, and how to construct them -----------------

## --- 2.1 SNDS Variables ----------------------------------------------------
# These variables were constructed over a 5y retrospective period prior to inclusion by 
# counting the number of times these services were used during that period. 

### --- 2.1.1 CCAM -----------------------------------------------------------
# They correspond to medical procedures (e.g., brain imaging, electrocardiogram, dental procedures,...)
# They are grouped by anatomical site (by first letter)
var_A_ccam <- data %>% dplyr::select(starts_with("CCAM_A"))
data$TOTAL_A_CCAM <- rowSums(var_A_ccam)
var_B_ccam <- data %>% dplyr::select(starts_with("CCAM_B"))
data$TOTAL_B_CCAM <- rowSums(var_B_ccam)
var_C_ccam <- data %>% dplyr::select(starts_with("CCAM_C"))
data$TOTAL_C_CCAM <- rowSums(var_C_ccam)
var_D_ccam <- data %>% dplyr::select(starts_with("CCAM_D"))
data$TOTAL_D_CCAM <- rowSums(var_D_ccam)
var_E_ccam <- data %>% dplyr::select(starts_with("CCAM_E"))
data$TOTAL_E_CCAM <- rowSums(var_E_ccam)
var_F_ccam <- data %>% dplyr::select(starts_with("CCAM_F"))
data$TOTAL_F_CCAM <- rowSums(var_F_ccam)
var_G_ccam <- data %>% dplyr::select(starts_with("CCAM_G"))
data$TOTAL_G_CCAM <- rowSums(var_G_ccam)
var_H_ccam <- data %>% dplyr::select(starts_with("CCAM_H"))
data$TOTAL_H_CCAM <- rowSums(var_H_ccam)
var_J_ccam <- data %>% dplyr::select(starts_with("CCAM_J"))
data$TOTAL_J_CCAM <- rowSums(var_J_ccam)
var_K_ccam <- data %>% dplyr::select(starts_with("CCAM_K"))
data$TOTAL_K_CCAM <- rowSums(var_K_ccam)
var_L_ccam <- data %>% dplyr::select(starts_with("CCAM_L"))
data$TOTAL_L_CCAM <- rowSums(var_L_ccam)
var_M_ccam <- data %>% dplyr::select(starts_with("CCAM_M"))
data$TOTAL_M_CCAM <- rowSums(var_M_ccam)
var_N_ccam <- data %>% dplyr::select(starts_with("CCAM_N"))
data$TOTAL_N_CCAM <- rowSums(var_N_ccam)
var_P_ccam <- data %>% dplyr::select(starts_with("CCAM_P"))
data$TOTAL_P_CCAM <- rowSums(var_P_ccam)
var_Q_ccam <- data %>% dplyr::select(starts_with("CCAM_Q"))
data$TOTAL_Q_CCAM <- rowSums(var_Q_ccam)
var_Z_ccam <- data %>% dplyr::select(starts_with("CCAM_Z"))
data$TOTAL_Z_CCAM <- rowSums(var_Z_ccam)

### 2.1.2 LPP -----------------------------------------------------------------
# They correspond to health care services and products (e.g., wheelchair, canes, glasses, blood glucose monitors, injection equipment...)
# They are grouped by subtype available in the file codage_lpp.csv
codage_lpp <- read.csv2("models_predictions/fast_ws/infos_models/codage_lpp.csv")
codage_lpp$Code.lpp <- paste0("LPP_", codage_lpp$Code.lpp)
codage_lpp <- codage_lpp[which(codage_lpp$Code.lpp %in% names(data)),]
codage_lpp$TSCOD1 <- as.factor(codage_lpp$TSCOD1)

var_A_lpp_names <- codage_lpp$Code.lpp[which(codage_lpp$TSCOD1=="A")]
var_A_lpp <- data %>% dplyr::select(var_A_lpp_names)
data$TOTAL_A_LPP <- rowSums(var_A_lpp)
var_C_lpp_names <- codage_lpp$Code.lpp[which(codage_lpp$TSCOD1=="C")]
var_C_lpp <- data %>% dplyr::select(var_C_lpp_names)
data$TOTAL_C_LPP <- rowSums(var_C_lpp)
var_D_lpp_names <- codage_lpp$Code.lpp[which(codage_lpp$TSCOD1=="D")]
var_D_lpp <- data %>% dplyr::select(var_D_lpp_names)
data$TOTAL_D_LPP <- rowSums(var_D_lpp)
var_E_lpp_names <- codage_lpp$Code.lpp[which(codage_lpp$TSCOD1=="E")]
var_E_lpp <- data %>% dplyr::select(var_E_lpp_names)
data$TOTAL_E_LPP <- rowSums(var_E_lpp)
var_G_lpp_names <- codage_lpp$Code.lpp[which(codage_lpp$TSCOD1=="G")]
var_G_lpp <- data %>% dplyr::select(var_G_lpp_names)
data$TOTAL_G_LPP <- rowSums(var_G_lpp)
var_GAO_lpp_names <- codage_lpp$Code.lpp[which(codage_lpp$TSCOD1=="GAO")]
var_GAO_lpp <- data %>% dplyr::select(var_GAO_lpp_names)
var_H_lpp_names <- codage_lpp$Code.lpp[which(codage_lpp$TSCOD1=="H")]
var_H_lpp <- data %>% dplyr::select(var_H_lpp_names)
data$TOTAL_H_LPP <- rowSums(var_H_lpp)
var_K_lpp_names <- codage_lpp$Code.lpp[which(codage_lpp$TSCOD1=="K")]
var_K_lpp <- data %>% dplyr::select(var_K_lpp_names)
data$TOTAL_K_LPP <- rowSums(var_K_lpp)
var_M_lpp_names <- codage_lpp$Code.lpp[which(codage_lpp$TSCOD1=="M")]
var_M_lpp <- data %>% dplyr::select(var_M_lpp_names)
data$TOTAL_M_LPP <- rowSums(var_M_lpp)
var_N_lpp_names <- codage_lpp$Code.lpp[which(codage_lpp$TSCOD1=="N")]
var_N_lpp <- data %>% dplyr::select(var_N_lpp_names)
data$TOTAL_N_LPP <- rowSums(var_N_lpp)
var_O_lpp_names <- codage_lpp$Code.lpp[which(codage_lpp$TSCOD1=="O")]
var_O_lpp <- data %>% dplyr::select(var_O_lpp_names)
data$TOTAL_O_LPP <- rowSums(var_O_lpp) +  rowSums(var_GAO_lpp)
var_R_lpp_names <- codage_lpp$Code.lpp[which(codage_lpp$TSCOD1=="R")]
var_R_lpp <- data %>% dplyr::select(var_R_lpp_names)
data$TOTAL_R_LPP <- rowSums(var_R_lpp)
var_S_lpp_names <- codage_lpp$Code.lpp[which(codage_lpp$TSCOD1=="S")]
var_S_lpp <- data %>% dplyr::select(var_S_lpp_names)
data$TOTAL_S_LPP <- rowSums(var_S_lpp)
var_T_lpp_names <- codage_lpp$Code.lpp[which(codage_lpp$TSCOD1=="T")]
var_T_lpp <- data %>% dplyr::select(var_T_lpp_names)
data$TOTAL_T_LPP <- rowSums(var_T_lpp)

data$TOTAL_O_LPP <- data$TOTAL_O_LPP + data$TOTAL_M_LPP # ORTHOPEDIC

### --- 2.1.3 Healthcare consultations ---------------------------------------
# MEDECIN_1: General practitioner
# MEDECIN_4: Surgery/intensive care/anesthesiology (excluding dental)
# MEDECIN_32: Neurology/geriatrics
# MEDECIN_31: Physical and rehabilitation medicine
# MEDECIN_14: Rheumatology
# MEDECIN_33: Psychiatry/psychology
# MEDECIN_5: Other medical specialties
# MEDECIN_3: Cardiovascular disease
# PODOLOGUE: Podiatrist
# DENTISTE: Dental
# KINE: Physiotherapy
# INFIRMIER: Nursing

### --- 2.1.4 Hospitalizations ----------------------------------------------
# TOTAL_MCO: Total number in acute care
# TOTAL_SSR: Total number in rehabilitation care
# CvCoron: Ischaemic heart disease
# HYPERU: Hypertension
# PAddict: Addiction disorders
# OB: obesity
# ARYTHM: Cardiac arrhythmias
# SOLIDTUM: Solid tumor without metastasis
# AUTRCARDIO: Other heart conditions
# PDepNev: Neurotic Disorders

### --- 2.1.5 Medication use -------------------------------------------------
# ATC codes, level 4


