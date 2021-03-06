/* ----------------------------------------------------------------------------
 * This file was automatically generated by SWIG (http://www.swig.org).
 * Version 3.0.2
 *
 * Do not make changes to this file unless you know what you are doing--modify
 * the SWIG interface file instead.
 * ----------------------------------------------------------------------------- */

package fr.limsi.wapiti;

public class Wapiti {
  public static opt_s getOpt_defaults() {
    long cPtr = WapitiJNI.opt_defaults_get();
    return (cPtr == 0) ? null : new opt_s(cPtr, false);
  }

  public static void opt_parse(int argc, SWIGTYPE_p_p_char argv, opt_s opt) {
    WapitiJNI.opt_parse(argc, SWIGTYPE_p_p_char.getCPtr(argv), opt_s.getCPtr(opt), opt);
  }

  public static SWIGTYPE_p_mdl_t loadModel(String args) {
    long cPtr = WapitiJNI.loadModel(args);
    return (cPtr == 0) ? null : new SWIGTYPE_p_mdl_t(cPtr, false);
  }

  public static int runWapiti(String args) {
    return WapitiJNI.runWapiti(args);
  }

  public static String labelFromModel(SWIGTYPE_p_mdl_t mdl, String data) {
    return WapitiJNI.labelFromModel(SWIGTYPE_p_mdl_t.getCPtr(mdl), data);
  }

  public static void freeModel(SWIGTYPE_p_mdl_t mdl) {
    WapitiJNI.freeModel(SWIGTYPE_p_mdl_t.getCPtr(mdl));
  }

  public static void printModelPath(SWIGTYPE_p_mdl_t mdl) {
    WapitiJNI.printModelPath(SWIGTYPE_p_mdl_t.getCPtr(mdl));
  }

}
