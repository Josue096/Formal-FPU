bind fp_mul fp_mul_checker chk (
//señales output-input 
  .r_mode     (r_mode),
  .fp_X       (fp_X),
  .fp_Y       (fp_Y),
  .fp_Z       (fp_Z),
  .ovrf       (ovrf),
  .udrf       (udrf),
//señales internas
  .frc_Z_full (FPM.frc_Z_full),
  .frc_X      (FPM.frc_X), 
  .frc_Y      (FPM.frc_Y),
  .frc_Z_norm (FPM.frc_Z_norm),
  .norm_n     (FPM.norm_n),
  .sign_Z     (FPM.sign_Z),
  .norm_r     (FPM.norm_r),
  .frc_Z      (FPM.frc_Z),
  .exp_Z      (FPM.exp_Z),
  .nan        (FPM.nan), 
  .inf        (FPM.inf), 
  .zer        (FPM.zer),
  .z          (FPM.Z)
);

