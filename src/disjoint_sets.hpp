#ifndef DISJOINT_SETS_HPP
#define DISJOINT_SETS_HPP

#include <godot_cpp/templates/vector.hpp>
#include "defaults.hpp"

namespace godot {

/*------------------------------------------------------|
| This is a standard implementation of a disjoint sets  |
| data structure. Here, sets are represented as         |
| integers, with each set assigned an index. Great for  |
| set unions and lookup, but does not support removal.  |
|------------------------------------------------------*/
struct DisjointSets {
   int count_num_sets() const;
   NO_ERROR_CHECK int get_set_size(int S) const;
   NO_ERROR_CHECK int find_root(int S) const;
   void reset();
   int new_set();
   /*------------------------------------------------------|
   | We have the choice to merge by size or by rank (tree  |
   | height). Since set size is generally more useful, we  |
   | keep the larger size set as the parent.               |
   |------------------------------------------------------*/
   NO_ERROR_CHECK void merge(int A, int B);
protected:
   int num_sets = 0;
   Vector<int> parents;
   Vector<int> sizes;
};

}

#endif // DISJOINT_SETS_HPP