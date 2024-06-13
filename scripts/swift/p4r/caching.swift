/* An interface to the caching infrastructure in PLAN4RESROOT/data */
import p4r.paths;
import string;
import unix;

string P4R_CACHEDIR=dircat(PLAN4RESROOT,"data/cache");

mkdir(P4R_CACHEDIR);
	

