bind fp_mul fp_mul_checker chk (
//señales output-input 
  .r_mode     (r_mode),
  .fp_X       (fp_X),
  .fp_Y       (fp_Y),
  .fp_Z       (fp_Z),
  .ovrf       (ovrf),
  .udrf       (udrf),
//señales internas
  .frc_Z_full (fp_mul.frc_Z_full),
  .frc_X      (fp_mul.frc_X), 
  .frc_Y      (fp_mul.frc_Y),
  .frc_Z_norm (fp_mul.frc_Z_norm),
  .norm_n     (fp_mul.norm_n),
  .sign_Z     (fp_mul.sign_Z),
  .norm_r     (fp_mul.norm_r),
  .frc_Z      (fp_mul.frc_Z)
);

