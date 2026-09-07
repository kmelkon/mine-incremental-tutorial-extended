class_name Utils


func format_number(value: float) -> String:
	if abs(value) < 1000:
		return str(int(value))
	
	var suffixes: Array = ["K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc"]
	var suffix_index: int = -1
	while abs(value) >= 1000 and suffix_index < suffixes.size() - 1:
		value /= 1000.0
		suffix_index += 1

	var formatted := String.num(value, 1).trim_suffix(".0")
	return formatted + suffixes[suffix_index] if suffix_index >= 0 else formatted
