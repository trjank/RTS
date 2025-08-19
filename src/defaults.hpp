#ifndef DEFAULTS_HPP
#define DEFAULTS_HPP

#include <godot_cpp/classes/ref.hpp>

// These are decorators to tell you about a variable's or function's safety
#define NEVER_NULL
#define NEVER_EMPTY
#define NO_ERROR_CHECK
#define SAFE_PTR
#define UNSAFE_PTR

namespace godot {

// This can help avoid the need for null checks
template<typename T>
NEVER_NULL Ref<T> get_default() {
	static Ref<T> default_data = memnew(T);
	return default_data;
}

}

#endif