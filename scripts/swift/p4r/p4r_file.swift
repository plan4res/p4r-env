/* standardized file name support */
import string;
import unix;

# A filename that conforms to the P4R filename specification:
# can be used as string, but cannot be constructed without explicit constructor
type p4r_filename string;

# PROVIDERID__DATASETID__DATADATE__DOWNLOADDATE[__SERIAL][__SLICEID][.FT]

@pure
(p4r_filename f) make_p4r_filename (string providerid, string datasetid,
				    string datadate, string downloaddate,
				    string serial = "",
				    string sliceid = "",
				    string filetype = "") 
# type creation requires TCL help
				"turbine" "0.0.2" [
"""
	set <<f>> [string cat <<providerid>> __ <<datasetid>> __ <<datadate>> __ <<downloaddate>>]
	if {! [string equal <<serial>>   ""]} {
		 append <<f>> [string cat  __ <<serial>> ]
	}
	if {! [string equal <<sliceid>>  ""]} { 
		append <<f>> [string cat  __ <<sliceid>> ]
	}
	if {! [string equal <<filetype>> ""]} {
		append <<f>> [string cat  . <<filetype>> ]
	}
"""
];
