#ifndef DEFAULT_HPP
#define DEFAULT_HPP

#include <godot_cpp/classes/ref.hpp>

namespace godot {

// Data defaults ensure data is never null (no need to check null case)
template<typename T>
Ref<T> get_default() {
	static Ref<T> default_data = memnew(T);
	return default_data;
}

}

#endif