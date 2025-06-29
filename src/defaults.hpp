#ifndef DEFAULTS_HPP
#define DEFAULTS_HPP

#include <godot_cpp/classes/ref.hpp>

// This is just a decorator to tell you that pointers are safe to use
#define NEVER_NULL

namespace godot {

// Data defaults ensure data is never null (no need to check null case)
template<typename T>
NEVER_NULL Ref<T> get_default() {
	static Ref<T> default_data = memnew(T);
	return default_data;
}

}

#endif