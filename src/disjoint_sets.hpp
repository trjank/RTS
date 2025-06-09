#ifndef DISJOINT_SETS_HPP
#define DISJOINT_SETS_HPP

#include <godot_cpp/templates/vector.hpp>

namespace godot {

struct DisjointSets {
   int count_num_sets();
   int new_set();
   int find_root(int set);
   void merge(int A, int B);
private:
   int num_sets = 0;
   Vector<int> parents;
   Vector<int> sizes;
};

}

#endif // DISJOINT_SETS_HPP