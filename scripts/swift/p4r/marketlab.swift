# Marketlab access

import p4r.paths;
import sys;
import io;
import python;
import string;
import files;

file P4R_MKL_SECRETS=input(dircat(
			dircat(PLAN4RESROOT,"config"),
			getenv("P4R_MARKETLAB_SECRETS")));

string P4R_MKL_USER;
string P4R_MKL_PASSWORD;
(P4R_MKL_USER, P4R_MKL_PASSWORD) = p4r_mkl_get_credentials();
string P4R_MKL_URLBASE="https://marketlab.pam-retd.fr/plan4res/get?data=";



(string username, string password) p4r_mkl_get_credentials() {
	string conf[] = file_lines(P4R_MKL_SECRETS);
	string A[string];
	foreach row in conf {
		colonpos = find(row,":",0,-1);
		if(colonpos>0) {
		  if(substring(row,0,length("user"))=="user") {
			#printf("username row: %s", row);
			A["username"] = substring(row,colonpos+1,
					length(row)-(colonpos+1));
		  }
		  if(substring(row,0,length("pass"))=="pass") {
			#printf("pwd row: %s", row);
			A["password"] = substring(row,colonpos+1,
					length(row)-(colonpos+1));
		  }
		}
	  }
	  username = A["username"];
	  password = A["password"];
} 

# invoke curl(1)
app (file result) curl (string credentials, string url) {
    "curl" "--fail" "-u" credentials url @stdout=result
}

# create all directories along PATH
(string res) mkdirhier (string path) {
	if(""==path || "/" == path) {
		res="";
	} else {
		mkdirhier(dirname_string(path))
		 => mkdir(path)
		 => res = path;
	}
}

(string cachedfile) mkl_download (string destdir, string fname) {
    # ensure destination can be written, in particular if filename has path
    # components
    string base = basename_string(fname);
    string subdir = dirname_string(fname);
    string fulldir = mkdirhier(dircat(destdir,subdir));
    string dst = dircat(fulldir,base);
    file res <dst> = curl(strcat(P4R_MKL_USER,":",P4R_MKL_PASSWORD),
		    	     strcat(P4R_MKL_URLBASE,fname));
    cachedfile = filename(res);
}

global const string mkl_python_code = 
"""
import argparse
import requests
import base64
import sys
import time
import os
import http
# https://toolbelt.readthedocs.io/en/latest/uploading-data.html
from requests_toolbelt import MultipartEncoder, MultipartEncoderMonitor

# Default values
url='https://marketlab.pam-retd.fr/plan4res/'

def uploadurl(url, directory, login, password):
    return url+"uploadFiles?currentWorkspace="+directory+"&securityToken="+b64login(login, password)

##################

def create_callback(encoder):
    totalSize = encoder.len

    def callback(monitor):
        progress_bar(monitor.bytes_read, totalSize)

    return callback

##################
def create_callback(encoder):
    totalSize = encoder.len

    def callback(monitor):
        progress_bar(monitor.bytes_read, totalSize)

    return callback

def py_mkl_upload(url, destdir, sourcedir, filename, login, password):
    try:
        sourcefile=sourcedir
        if len(sourcefile)>0:
            sourcefile+='/'
        sourcefile+=filename

        print("Uploading %s to %s" % (sourcefile, url+destdir))

        with open(sourcefile, 'rb') as f:
            # Open stream for upload
            encoder = MultipartEncoder(fields={filename : (filename , f)})
            callback = create_callback(encoder)
            monitor = MultipartEncoderMonitor(encoder, callback)
            req = requests.post(uploadurl(url, destdir, login, password), data=monitor,
                                headers={'Content-Type': monitor.content_type})

    except requests.exceptions.RequestException as err:
        print(err)
        sys.exit(1)

    except IOError as err:
        print("I/O error({0}): {1}".format(err.errno, err.strerror))
        sys.exit(1)


""";


# until we have a proper python module that we can call from turbine/python we use the 
# external mkl script:
app (void signal_done) run_mkl_py (string dstdir, string file) {
	"mkl" "-l" P4R_MKL_USER "-p" P4R_MKL_PASSWORD
		"-y"
		"-w" dstdir
		"-u"
		file
}

(void signal_done) mkl_upload (string dstdir, string file) {
	signal_done = run_mkl_py(dstdir, file);
}
#(string cachedfile) mkl_upload (string dstfname, string file) {
#    # ensure destination can be written, in particular if filename has path
#    # components
#    string pycmd = sprintf("py_mkl_upload(\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\")", 
#		   "https://marketlab.pam-retd.fr/plan4res/",
#		   "Shared",
#		   ".",
#		   file,
#		   P4R_MKL_USER, P4R_MKL_PASSWORD
#		   );
#    python(mkl_python_code, pycmd);
#
##	   sprintf("py_mkl_upload(\"%s\", \"%s\", \"%s\", \"%s\", \"%s\", \"%s\")",
##		   "https://marketlab.pam-retd.fr/plan4res/"
##		   "Shared",
##		   ".",
##		   file,
##		   P4R_MKL_USER, P4R_MKL_PASSWORD));
#
#    cachedfile="foo";
##    string base = basename_string(fname);
##    string subdir = dirname_string(fname);
##    string fulldir = mkdirhier(dircat(destdir,subdir));
##    string dst = dircat(fulldir,base);
##    file res <dst> = curl(strcat(P4R_MKL_USER,":",P4R_MKL_PASSWORD),
##		    	     strcat(P4R_MKL_URLBASE,fname));
##    cachedfile = filename(res);
#}
