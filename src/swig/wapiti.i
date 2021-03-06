%module Wapiti
%include exception.i

%include "std_string.i"
%include "../options.h"

%exception {
  try { $action }
  catch (char *e) { SWIG_exception (SWIG_RuntimeError, e); }
  catch (const char *e) { SWIG_exception (SWIG_RuntimeError, (char*)e); }
}

//MAIN INTERFACE
mdl_t* loadModel(char *args);
int runWapiti(char *args);
%typemap(newfree) char * "free($1);";
%newobject labelFromModel;
char* labelFromModel(mdl_t* mdl, char* data);
void freeModel(mdl_t* mdl);
void printModelPath(mdl_t* mdl);
//END - MAIN INTERFACE

%{
  extern "C" {
    #include <ctype.h>
    #include <inttypes.h>
    #include <stdbool.h>
    #include <stddef.h>
    #include <stdint.h>
    #include <stdlib.h>
    #include <stdio.h>
    #include <string.h>

    #include "../decoder.h"
    #include "../model.h"
    #include "../options.h"
    #include "../progress.h"
    #include "../quark.h"
    #include "../reader.h"
    #include "../sequence.h"
    #include "../tools.h"
    #include "../trainers.h"
    #include "../wapiti.h"
    #include "fmemopen.h"

    #define BUF_SIZE 8192
    #define PACKAGE "wapiti"
      


    mdl_t* get_params_obj_var(int argc, char** argv);
    void printModelPath(mdl_t* mdl);

    mdl_t* loadModel(const char *arg) {
      char str[BUF_SIZE];
      strncpy(str, arg, sizeof(str));

      char* ptr[64];
      unsigned int size = 1;
      ptr[0] = PACKAGE;

      for (char *p = str; *p;) {
        while (isspace(*p)) *p++ = '\0';
        if (*p == '\0') break;
        ptr[size++] = p;
        if (size == sizeof(ptr)) break;
        while (*p && !isspace(*p)) p++;
      }

      char* arr[64];
      for (int i =0; i < size;i++) {
        char *ss = new char[BUF_SIZE];
        strcpy(ss, ptr[i]);
        arr[i] =ss;
      }

      mdl_t* mdl = get_params_obj_var(size, arr);
      printModelPath(mdl);
      return mdl;
    }


    int main(int argc, char **argv);
    int runWapiti(char *arg) {
              char str[BUF_SIZE];
              strncpy(str, arg, sizeof(str));
              char* ptr[64];
              int size = 1;
              ptr[0] = PACKAGE;

              for (char *p = str; *p;) {
                while (isspace(*p)) *p++ = '\0';
                if (*p == '\0') break;
                ptr[size++] = p;
                if (size == sizeof(ptr)) break;
                while (*p && !isspace(*p)) p++;
              }
            return main(size, ptr);
    }

    opt_t* get_default_opt() {
        opt_t *opt = new opt_t();

    	opt->mode    = -1;
    	opt->input   = NULL;     opt->output  = NULL;
    	opt->type    = "crf";
    	opt->maxent  = false;
    	opt->algo    = "l-bfgs"; opt->pattern = NULL;  opt->model   = NULL; opt->devel   = NULL;
    	opt->rstate  = NULL;     opt->sstate  = NULL;
    	opt->compact = false;    opt->sparse  = false;
    	opt->nthread = 1;        opt->jobsize = 64;    opt->maxiter = 0;
    	opt->rho1    = 0.5;      opt->rho2    = 0.0001;
    	opt->objwin  = 5;        opt->stopwin = 5;     opt->stopeps = 0.02;

    	opt->label   = false;    opt->check   = false; opt->outsc = false;
    	opt->lblpost = false;    opt->nbest   = 1;     opt->force = false;
    	opt->prec    = 5;
        opt->all     = false;


        opt->lbfgs.clip   = false;
        opt->lbfgs.histsz = 5;
        opt->lbfgs.maxls = 40;

        opt->sgdl1.eta0   = 0.8;
        opt->sgdl1.alpha  = 0.85;


        opt->bcd.kappa  = 1.5;

        opt->rprop.stpmin = 1e-8;
        opt->rprop.stpmax = 50.0;
        opt->rprop.stpinc = 1.2;
        opt->rprop.stpdec = 0.5,
        opt->rprop.cutoff = false;


        return opt;
    }

    mdl_t* get_params_obj_var(int argc, char** argv) {
            opt_t *opt = get_default_opt();

            opt_parse(argc, argv, opt);
            mdl_t *mdl = mdl_new(rdr_new(opt->maxent));
            mdl->opt = opt;
            if (mdl->opt->model == NULL)
                fatal("you must specify a model");
            info("[Wapiti] Loading model: \"%s\"\n", mdl->opt->model);
            FILE *file = fopen(mdl->opt->model, "r");
            if (file == NULL) {
                pfatal("cannot open input model file: %s", mdl->opt->model);
            }
            mdl_load(mdl, file);

            return mdl;
    }


    char* labelFromModel(mdl_t *mdl, char* inBuf) {
        int bufSize = strlen(inBuf) * 2;
        char* outBuf = new char[bufSize];
        memset(outBuf, 0, bufSize);

    	// Open input and output files
    	FILE *fin, *fout;

        fin = fmemopen(inBuf, strlen(inBuf), "r");
        if (fin == NULL) {
            pfatal("Cannot open input data buffer: %s\n", inBuf);
        }

        fout = fmemopen(outBuf, bufSize, "w");
        if (fout == NULL) {
            pfatal("Cannot open output data buffer");
        }

    	// Do the labelling
    	//info("* Label sequences\n");
    	if (!tag_label(mdl, fin, fout)) {
            warning("Cannot apply patterns, most likely wrong input data\n");
            return NULL;
        }
    	//info("* Done\n");
    	// And close files
//    	if (mdl->opt->input != NULL)
    		fclose(fin);
  //  	if (mdl->opt->output != NULL)
    		fclose(fout);

        return outBuf;
    }

    void printModelPath(mdl_t* mdl) {
        info("Model path: %s\n", mdl->opt->model);
    }

    void freeModel(mdl_t* mdl) {
        free(mdl->opt);
        mdl_free(mdl);
    }

  }

%}

