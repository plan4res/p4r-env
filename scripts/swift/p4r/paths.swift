/* Path settings available to all scripts */
import sys;
import files;
import io;

/* global constants -- and sanity check */
string PLAN4RESROOT = getenv("PLAN4RESROOT");

if(file_type_string(PLAN4RESROOT)!="directory") {
	printf("Missing PLAN4RESROOT environment variable setting\n");
}

string P4R_ADDONSROOT = getenv("ADDONS_INSTALLDIR");

string P4R_SCRATCHDIR = dircat(PLAN4RESROOT,"data/scratch");
string P4R_STAGINGDIR = dircat(PLAN4RESROOT,"data/staging");


