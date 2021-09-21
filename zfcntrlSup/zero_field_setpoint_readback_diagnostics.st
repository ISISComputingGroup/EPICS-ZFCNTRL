program zero_field_setpoint_readback_diagnostics("P")

#include "seqPVmacros.h"
#include "zf_pv_definitions.h"
%% #include "seq_snc.h"
%% #include "epicsTime.h"
%% #include "string.h"
%% #include "math.h"
%% #include "errlog.h"
%% #include "alarm.h"

option +d;
option +r;
option +s;


%{
  static const char* const PROGRAM_NAME = "zero_field_setpoint_readback_diagnostics.st";

  /* Some necessary function forward-declarations - for implementations see end of file. */
  static int is_within_tolerance(double setpoint, double readback, double tolerance);
  static void report_tolerance_error(const char* axis, double sp, double sp_rpv, double tolerance, double timeout);
}%

ss zero_field_setpoint_readback_diagnostics
{
  
  state idle {
    entry {
      PVPUT(check_psu_tolerance, 0);
    }

    when(check_psu_tolerance == 1) { 

    } state check_psu_writes

  }

  state check_psu_writes {  
    when(
        is_within_tolerance(output_psu_x_sp, output_psu_x_sp_rbv, output_psu_tolerance) &&
        is_within_tolerance(output_psu_y_sp, output_psu_y_sp_rbv, output_psu_tolerance) &&
        is_within_tolerance(output_psu_z_sp, output_psu_z_sp_rbv, output_psu_tolerance)
      ) {

        // if (_output_on_limit) {
        //   PVPUT(status, ZF_STAT_PSU_ON_LIMITS);
        // } else {
        //   /* If we get to this state, there has been no error */
        //   PVPUT(status, ZF_STAT_NO_ERROR);   
        // }
        errlogSevPrintf(errlogInfo, "%s: power supply writes successful X=%f, Y=%f, Z=%f\n",
		                  PROGRAM_NAME, output_psu_x_sp_rbv, output_psu_y_sp_rbv, output_psu_z_sp_rbv);
        
        if (debug) {
          errlogSevPrintf(errlogInfo, "%s: power supply writes successful X=%f, Y=%f, Z=%f\n",
		                  PROGRAM_NAME, output_psu_x_sp_rbv, output_psu_y_sp_rbv, output_psu_z_sp_rbv);
        }
      } state idle
      
      when(delay(read_timeout)) {
          errlogSevPrintf(errlogInfo, "read timeout\n");
          PVPUT(tolerance_errors, pvGet(tolerance_errors) + 1);
		      report_tolerance_error("X", output_psu_x_sp, output_psu_x_sp_rbv, output_psu_tolerance, read_timeout);
		      report_tolerance_error("Y", output_psu_y_sp, output_psu_y_sp_rbv, output_psu_tolerance, read_timeout);
		      report_tolerance_error("Z", output_psu_z_sp, output_psu_z_sp_rbv, output_psu_tolerance, read_timeout);
      } state idle
  }

}


%{ 
  /**
   * Returns 1 if the first two arguments are within tolerance of each other, else 0.
   */
  static int is_within_tolerance(double setpoint, double readback, double tolerance) {
    return fabs(setpoint - readback) <= tolerance;
  }
  
  /**
   * Report error if axis out of tolerance
   */
    static void report_tolerance_error(const char* axis, double sp, double sp_rbv, double tolerance, double timeout)
    {
        if (!is_within_tolerance(sp, sp_rbv, tolerance)) {
            errlogSevPrintf(errlogMajor, "%s: %s Power supply write failed to get within tolerance %f: SP=%f SP:RBV=%f error=%f Timeout=%f\n",
                          PROGRAM_NAME, axis, tolerance, sp, sp_rbv, sp - sp_rbv, timeout);
        }
    }
}%
