#! /usr/bin/gawk -f

BEGIN {
	PROCINFO["sorted_in"] = "@ind_num_asc";

	switch (output) {
		case "input": 
			OUTPUT = "input"; break;
		case "dzn":
			OUTPUT = "dzn"; break;
		case "":
			OUTPUT = "dzn"; break;
		default:
			print "ERROR: Output option '" output "' does not exist!";
			exit 1;
	}

	n_res     = 0;		# The number of machines
	n_tasks   = 0;	# The number of tasks
	n_tasks_0 = 0;

	status = "none";
	ot = 0;
}

/RESOURCES/ {
	status = "resources";
}

/renewable/ {
	n_res += $4 + 0;
}

/doubly constrained/ {
	if ($5 + 0 > 0) {
		print "Doubly constrained resource!!!!";
		exit 1;
	}
}

/^jobs/ {
	n_tasks_0 = $5 + 0;
	n_tasks = n_tasks_0 - 2;
}

/^[[:space:]]*[0-9]+/ {
	if (status == "precrel") {
		i = $1 + 0;
		a_nmode[i] = $2 + 0;
		a_nsucc[i] = $3 + 0;
		for (j = 1; j <= a_nsucc[i]; j++) {
			idx = 3 + j;
			k = $idx + 0;
			a2_succ[i][k] = 1;
		}
	} else if (status == "tasks") {
		if (NF == n_res + 3) {
			cur_task = $1 + 0;
		}
		ot++;
		a_dur[ot] = $(NF - n_res) + 0;
		for (r = 1; r <= n_res; r++) {
			idx = NF - n_res + r;
			a2_rreq[r, ot] = $idx + 0;
		}
		a2_mode[cur_task][ot] = 1;
	} else if (status == "rcaps") {
		for (r = 1; r <= n_res; r++) {
			a_rcap[r] = $r + 0;
		}
	}
}

/^[[:space:]]*[DNR][[:space:]]+[0-9]+/ {
	for (r = 1; r <= n_res; r++) {
		idx = 2 * r - 1;
		if ($idx == "R") {
			a_rtype[r] = 1;
		} else if ($idx == "N") {
			a_rtype[r] = 2;
		} else {
			print "Unknown Resource Type";
			exit 1;
		}
	}
}

/PRECEDENCE RELATIONS/ {
	status = "precrel";
}

/REQUESTS\/DURATIONS/ {
	status = "tasks";
}

/RESOURCEAVAILABILITIES/ {
	status = "rcaps";
}


END {
	switch(OUTPUT) {
	case "input":
		print_input(); break;
	case "dzn":
		print_in_dzn(); break;
	}
}

function print_input() {
}

function print_in_dzn() {
	# Number of resources
	printf "n_res = " n_res ";\n";
	# Resource capacities
	printf "rcap = [";
	for (r = 1; r <= n_res; r++) {
		if (r > 1) printf ", ";
		printf a_rcap[r];
	}
	printf "];\n";
	# Resource types
	printf "rtype = [";
	for (r = 1; r <= n_res; r++) {
		if (r > 1) printf ", ";
		printf a_rtype[r];
	}
	printf "];\n";

	# Number of tasks
	printf "n_tasks = " n_tasks ";\n";
	# Tasks' modes
	printf "modes = [ ";
	for (i = 2; i < n_tasks_0; i++) {
		if (i > 2) printf ", ";
		b = 0;
		printf "{";
		for (j in a2_mode[i]) {
			if (b) printf ", ";
			printf "%d", (j - 1);
			b = 1;
		}
		printf "}";
	}
	printf " ];\n";
	# Successors
	printf "succ = [ ";
	for (i = 2; i < n_tasks_0; i++) {
		if (i > 2) printf ", ";
		b = 0;
		printf "{";
		for (j in a2_succ[i]) {
			if (j != 1 && j != n_tasks_0) {
				if (b) printf ", ";
				printf "%d", (j - 1);
				b = 1;
			}
		}
		printf "}";
	}
	printf " ];\n";
	# Number of optional tasks
	printf "n_opt = %d;\n", (ot - 2);
	# Durations
	printf "dur = [";
	for (i = 2; i < ot; i++) {
		if (i > 2) printf ", ";
		printf "%d", a_dur[i];
	}
	printf "];\n";
	# Resource requirements
	printf "rreq = [| ";
	for (r = 1; r <= n_res; r++) {
		if (r > 1) printf "\n        | ";
		for (i = 2; i < ot; i++) {
			if (i > 2) printf ", ";
			printf "%2d", a2_rreq[r, i];
		}
	}
	printf " |];\n";
}
