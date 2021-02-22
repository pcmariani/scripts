# prev: https://stackoverflow.com/questions/44575730/awk-get-the-nextline

BEGIN {
	FS="=";
	#print "Alias##Command## Comment";
}

{
	# col1
	col1 = substr($1, 6, length($1));

	# col2
	max_length = 50;
	start = $2 ~ /^'|^"/ ? 2 : 1;
	col2 = "";
	if (length($2) < max_length-1) {
		from_end = $2 ~ /'$|"$/ ? 2 : 0;
		col2 = substr($2, start, length($2) - from_end);
	}
	else {
		col2 = substr($2, start, max_length)"…";
	}

	# main
	sep = "##"
	if (NR > 0) {
		# if ~ /^alias/
			# if has inline comment
			# else has comment on previous line
		if ($0 ~ /^alias/ && prev ~ /^##/)
			print col1 sep col2 sep substr(prev, 3, length(prev));
		else if ($0 ~ /^alias/)
			print col1 sep col2;
		else if ($0 ~ /^# /)
			print "`\n" substr($0, 3, length($0));
		prev = $0;
	}
}
